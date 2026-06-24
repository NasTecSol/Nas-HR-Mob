
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/request_controller/user_activity_detail_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/loader.dart';

// ── colour wheel ──────────────────────────────────────────────────────────────
const List<Color> _kColors = [
  Color(0xFF4A90D9), Color(0xFF34C759), Color(0xFFFF9500), Color(0xFF7B61FF),
  Color(0xFF5AC8FA), Color(0xFFAF52DE), Color(0xFFFF3B30), Color(0xFFFF2D55),
  Color(0xFF00BCD4), Color(0xFF8BC34A), Color(0xFFFFC107), Color(0xFF9C27B0),
];

// ── safe parsers (handle int / double / String-epoch / ISO-8601) ──────────────
DateTime? _ts(dynamic v) {
  if (v == null) return null;
  try {
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final ms = int.tryParse(s);
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
  } catch (_) {}
  return null;
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

String _s(dynamic v) => v?.toString().trim() ?? '';

// ─────────────────────────────────────────────────────────────────────────────
//  Data classes
// ─────────────────────────────────────────────────────────────────────────────
class _Session {
  final String app, title;
  final DateTime start;
  final DateTime? end;
  final int durMs;
  final bool isIdle;
  const _Session({
    required this.app,
    required this.title,
    required this.start,
    this.end,
    required this.durMs,
    this.isIdle = false,
  });
}

class _AppStat {
  final String app;
  int totalMs;
  int count;
  _AppStat({required this.app, required this.totalMs, required this.count});
}

// ─────────────────────────────────────────────────────────────────────────────
//  Parser — runs once in initState
// ─────────────────────────────────────────────────────────────────────────────
class _Parsed {
  final List<_Session> sessions;   // sorted oldest → newest
  final List<_AppStat> apps;       // sorted by totalMs desc
  final int activeMs;
  final int totalMs;
  final bool isOnline;
  final DateTime? tlStart;
  final DateTime? tlEnd;
  final Map<String, Color> _colors;

  const _Parsed._({
    required this.sessions,
    required this.apps,
    required this.activeMs,
    required this.totalMs,
    required this.isOnline,
    required this.tlStart,
    required this.tlEnd,
    required Map<String, Color> colors,
  }) : _colors = colors;

  Color colorOf(String app) =>
      _colors.putIfAbsent(app, () => _kColors[_colors.length % _kColors.length]);

  factory _Parsed.from(List<UserActivityDetailModel> records) {
    final Map<String, Color> colors = {};
    void seedColor(String app) =>
        colors.putIfAbsent(app, () => _kColors[colors.length % _kColors.length]);

    int activeMs = 0, totalMs = 0;
    bool isOnline = false;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final List<_Session> sessions = [];
    final Map<String, _AppStat> appMap = {};

    for (final r in records) {
      activeMs += _int(r.body?.activeTimeMs);
      totalMs  += _int(r.body?.totalTimeMs);

      for (final raw in r.activitySession ?? []) {
        final app   = _s(raw.app).isNotEmpty ? _s(raw.app) : (_s(raw.title).isNotEmpty ? _s(raw.title) : 'Unknown');
        final title = _s(raw.title).isNotEmpty ? _s(raw.title) : (_s(raw.taskName).isNotEmpty ? _s(raw.taskName) : '—');
        final start = _ts(raw.beginDate);
        final end   = _ts(raw.endDate);

        if (start == null) continue;

        // online if any session ended < 5 min ago OR has no end
        if (end == null || (nowMs - end.millisecondsSinceEpoch) < 300000) {
          isOnline = true;
        }

        final dur    = end != null ? end.difference(start).inMilliseconds : 0;
        final isIdle = app.toLowerCase() == 'idle' || title.toLowerCase() == 'idle';

        sessions.add(_Session(app: app, title: title, start: start, end: end, durMs: dur, isIdle: isIdle));

        appMap.update(
          app,
              (s) => _AppStat(app: s.app, totalMs: s.totalMs + dur, count: s.count + 1),
          ifAbsent: () => _AppStat(app: app, totalMs: dur, count: 1),
        );
        seedColor(app);
      }

      // fallback: body.mostUsedApps seeds the app list if activitySession is empty
      if (sessions.isEmpty) {
        for (final a in r.body?.mostUsedApps ?? []) {
          final app = _s(a);
          if (app.isEmpty) continue;
          appMap.putIfAbsent(app, () => _AppStat(app: app, totalMs: 0, count: 1));
          seedColor(app);
        }
      }
    }

    sessions.sort((a, b) => a.start.compareTo(b.start));

    final apps = appMap.values.toList()..sort((a, b) => b.totalMs.compareTo(a.totalMs));

    return _Parsed._(
      sessions: sessions,
      apps: apps,
      activeMs: activeMs,
      totalMs: totalMs,
      isOnline: isOnline,
      tlStart: sessions.isNotEmpty ? sessions.first.start : null,
      tlEnd:   sessions.isNotEmpty ? (sessions.last.end ?? sessions.last.start) : null,
      colors: colors,
    );
  }
}

class _HourGroup {
  final DateTime startTime;
  final List<_Session> sessions;

  _HourGroup({required this.startTime, required this.sessions});

  DateTime get endTime => startTime.add(const Duration(hours: 1));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Standalone timeline bar — drop into Attendance Detail page
// ─────────────────────────────────────────────────────────────────────────────
class ActivityTimelineBar extends StatelessWidget {
  final List<UserActivityDetailModel> records;
  const ActivityTimelineBar({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final p = _Parsed.from(records);
    if (p.sessions.isEmpty) return const SizedBox.shrink();
    return _TimelineWidget(parsed: p, compact: true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main screen
// ─────────────────────────────────────────────────────────────────────────────
class UserActivityDetailScreen extends StatefulWidget {
  final String empId, empName, designation;
  final String? picUrl;
  final DateTime startDate;
  final DateTime endDate;

  const UserActivityDetailScreen({
    super.key,
    required this.empId,
    required this.empName,
    required this.designation,
    this.picUrl,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<UserActivityDetailScreen> createState() => _State();
}

class _State extends State<UserActivityDetailScreen>
    with SingleTickerProviderStateMixin {

  // animation — initialized lazily after vsync is ready
  AnimationController? _ac;

  // parsed data — nullable so build never reads an uninitialized late field
  _Parsed? _data;

  // loading state
  bool _isLoading = true;
  String? _errorMessage;
  final SingletonClass _singleton = SingletonClass();

  // expanded hour slots
  final Set<DateTime> _expandedHours = {};

  // filter
  String _search = '';
  String _filterApp = 'All Apps';
  final TextEditingController _sc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fetchDetails();
  }

  List<_HourGroup> _groupSessions(List<_Session> sessions) {
    final Map<DateTime, List<_Session>> groups = {};
    for (final s in sessions) {
      final hourStart = DateTime(s.start.year, s.start.month, s.start.day, s.start.hour);
      groups.putIfAbsent(hourStart, () => []).add(s);
    }

    final sortedGroups = groups.entries.map((e) {
      return _HourGroup(startTime: e.key, sessions: e.value);
    }).toList();

    sortedGroups.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sortedGroups;
  }

  Future<void> _fetchDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final startStr = widget.startDate.toIso8601String().split('T').first;
      final endStr   = widget.endDate.toIso8601String().split('T').first;
      final uri = Uri.parse(
        '${_singleton.baseURL}/activity-session/fulldetails/$startStr/$endStr',
      );

      log('📡 POST Detail $uri | empId: ${widget.empId}');

      final response = await http.post(
        uri,
        body: json.encode({'empIds': [widget.empId]}),
        headers: _singleton.getHeaders(),
      );

      log('📥 Detail Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final List<UserActivityDetailModel> records = decoded is List
            ? decoded
                .map((e) => UserActivityDetailModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : [UserActivityDetailModel.fromJson(decoded as Map<String, dynamic>)];

        _data = _Parsed.from(records);
        
        // Auto-expand the newest hour group initially
        if (_expandedHours.isEmpty && _data != null && _data!.sessions.isNotEmpty) {
          final grouped = _groupSessions(_data!.sessions);
          if (grouped.isNotEmpty) {
            _expandedHours.add(grouped.first.startTime);
          }
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _ac?.forward();
        }
      } else {
        log('❌ Detail API error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e, s) {
      log('🚨 Detail Exception: $e\n$s');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred while loading data.';
        });
      }
    }
  }

  @override
  void dispose() {
    _ac?.dispose();
    _sc.dispose();
    super.dispose();
  }

  // ── filtered + reversed (newest first) ───────────────────────────────────
  List<_Session> get _filtered {
    final q = _search.toLowerCase();
    return (_data?.sessions ?? []).reversed.where((s) {
      final matchQ   = q.isEmpty || s.app.toLowerCase().contains(q) || s.title.toLowerCase().contains(q);
      final matchApp = _filterApp == 'All Apps' || s.app == _filterApp;
      return matchQ && matchApp;
    }).toList();
  }

  // ── shared helpers ────────────────────────────────────────────────────────
  static String _fmt(int ms) {
    if (ms <= 0) return '0m';
    final h = Duration(milliseconds: ms).inHours;
    final m = Duration(milliseconds: ms).inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  static String _clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  static Color _sfg(int s) =>
      s >= 75 ? const Color(0xFF16A34A) : s >= 45 ? const Color(0xFFD97706) : const Color(0xFFDC2626);

  // ── widget helpers ────────────────────────────────────────────────────────
  Widget _card(Widget child, {EdgeInsets pad = const EdgeInsets.all(16)}) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: pad,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: child,
      );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
  );

  Widget _appAvatar(String app, Color col, double size) => Container(
    width: size, height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(size * 0.28)),
    child: Text(
      app.isNotEmpty ? app[0].toUpperCase() : '?',
      style: GoogleFonts.inter(fontSize: size * 0.42, fontWeight: FontWeight.bold, color: col),
    ),
  );

  Widget _statusChip(_Session s) {
    if (s.isIdle) return _chip(AppLocalizations.of(context)!.idle, const Color(0xFF374151), const Color(0xFFF3F4F6));
    if (s.end == null || DateTime.now().difference(s.end!).inSeconds < 180) {
      return _chip(AppLocalizations.of(context)!.active, const Color(0xFF15803D), const Color(0xFFDCFCE7));
    }
    return _chip(AppLocalizations.of(context)!.done, const Color(0xFF6B7280), const Color(0xFFF3F4F6));
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
  );

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(child: Loader()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.empName,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NasColors.darkBlue),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NasColors.darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child:  Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(child: Loader()),
      );
    }
    final data   = _data!;
    final score  = data.totalMs > 0
        ? ((data.activeMs / data.totalMs) * 100).round().clamp(0, 100)
        : 0;
    final sfg    = _sfg(score);
    final fList  = _filtered;
    final appOpts = ['All Apps', ...data.apps.map((a) => a.app)];
    final grouped = _groupSessions(fList);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(child: Column(children: [

          // ══ AppBar ════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined, size: 18, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                    child: Text(AppLocalizations.of(context)!.liveSessions,
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF15803D))),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text('${AppLocalizations.of(context)!.employee}: ${widget.empId}',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                      overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 1),
                Text(widget.empName,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NasColors.darkBlue),
                    overflow: TextOverflow.ellipsis),
              ])),
              // online badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: data.isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.circle, size: 7,
                      color: data.isOnline ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF)),
                  const SizedBox(width: 5),
                  Text(data.isOnline ? AppLocalizations.of(context)!.online : AppLocalizations.of(context)!.offline,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800,
                          color: data.isOnline ? const Color(0xFF16A34A) : const Color(0xFF6B7280))),
                ]),
              ),
            ]),
          ),

          // ══ Scrollable body ═══════════════════════════════════════════════
          Expanded(child: FadeTransition(
            opacity: CurvedAnimation(parent: _ac!, curve: Curves.easeOut),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              children: [

                // ── 1. Activity Timeline ─────────────────────────────────────
                if (data.sessions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TimelineWidget(parsed: data, compact: false),
                  ),

                // ── 2. Stats row — Total Time · Score · Sessions ─────────────
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(AppLocalizations.of(context)!.performance),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              AppLocalizations.of(context)!.productivityScore,
                              '$score%',
                              sfg,
                              Icons.trending_up,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              AppLocalizations.of(context)!.totalTrackedTime,
                              _fmt(data.totalMs),
                              Colors.blue,
                              Icons.schedule,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              AppLocalizations.of(context)!.activeTime,
                              _fmt(data.activeMs),
                              Colors.green,
                              Icons.timer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              AppLocalizations.of(context)!.session,
                              '${data.sessions.length}',
                              Colors.orange,
                              Icons.list_alt,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── 3. App Usage Breakdown ────────────────────────────────────
                if (data.apps.isNotEmpty)
                  _card(
                    Row(
                      children: [
                        _appAvatar(
                          data.apps.first.app,
                          data.colorOf(data.apps.first.app),
                          50,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.mostUsedApps,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                data.apps.first.app,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _fmt(data.apps.first.totalMs),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── 4. Session Logs ───────────────────────────────────────────
                _card(
                  pad: EdgeInsets.zero,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: Row(children: [
                          Expanded(child: _sectionTitle(AppLocalizations.of(context)!.sessionDetails)),
                          Text('${fList.length} ${AppLocalizations.of(context)!.results}${fList.length != 1 ? 's' : ''}',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
                        ]),
                      ),

                      // search + filter row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                            children: [
                          Expanded(
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white,
                                  hint: Text(AppLocalizations.of(context)!.allApps),
                                  value: appOpts.contains(_filterApp) ? _filterApp : "All Apps",
                                  items: appOpts.map((a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a, style: GoogleFonts.inter(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (v) => setState(() => _filterApp = v ?? "All Apps"),
                                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF111827)),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),

                      // column headers
                      Container(
                        color: const Color(0xFFF9FAFB),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(children: [
                          _colH(AppLocalizations.of(context)!.timeRange,  w: 105),
                          _colH(AppLocalizations.of(context)!.application, flex: 2),
                          _colH(AppLocalizations.of(context)!.taskOrTitle, flex: 3),
                          _colH(AppLocalizations.of(context)!.dur,  w: 40, align: TextAlign.right),
                          const SizedBox(width: 8),
                          _colH(AppLocalizations.of(context)!.status, w: 52, align: TextAlign.right),
                        ]),
                      ),

                      // rows
                      if (grouped.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text(
                            _search.isNotEmpty || _filterApp != AppLocalizations.of(context)!.allApps
                                ? AppLocalizations.of(context)!.noSessionMatchYourFilter
                                : AppLocalizations.of(context)!.noSessionData,
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                          )),
                        )
                      else
                        ...grouped.map((g) => _hourGroupSection(g)),

                      const SizedBox(height: 8),
                    ])),
                ),

                // ── empty state (no records at all) ───────────────────────────
                if (data.sessions.isEmpty && data.apps.isEmpty)
                  _card(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Column(children: [
                      const Icon(Icons.bar_chart_outlined, size: 52, color: Color(0xFFD1D5DB)),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.noActivityDataAvailable,
                          style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF9CA3AF))),
                    ])),
                  )),

              ],
            ),
          )),
        ])),
      ),
    );
  }
  Widget _summaryCard(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  // ── session row ────────────────────────────────────────────────────────────
  Widget _sessionRow(_Session s, bool isLast) {
    final col   = _data?.colorOf(s.app) ?? const Color(0xFF4A90D9);
    final range = s.end != null ? '${_clock(s.start)} - ${_clock(s.end!)}' : _clock(s.start);
    final hour  = s.start.hour;
    final label = hour < 12 ? AppLocalizations.of(context)!.morningSession : hour < 17 ? AppLocalizations.of(context)!.afternoonSession : AppLocalizations.of(context)!.eveningSession;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // time + session label
          SizedBox(width: 105, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF), letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Text(range, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          ])),
          const SizedBox(width: 6),

          // app avatar + name
          Expanded(flex: 2, child: Row(children: [
            _appAvatar(s.app, col, 28),
            const SizedBox(width: 7),
            Expanded(child: Text(s.app,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ])),

          // task / title
          Expanded(flex: 3, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(s.title.isNotEmpty ? s.title : '—',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          )),

          // duration
          SizedBox(width: 40, child: Text(_fmt(s.durMs),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF374151)))),

          const SizedBox(width: 8),

          // status
          SizedBox(width: 52, child: Align(alignment: Alignment.centerRight, child: _statusChip(s))),
        ]),
      ),
      if (!isLast)
        Divider(height: 1, thickness: 0.5, color: const Color(0xFFF3F4F6), indent: 16, endIndent: 16),
    ]);
  }

  static String _monthName(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }

  Widget _hourGroupHeader(_HourGroup group, bool isExpanded, VoidCallback onTap) {
    final startStr = _clock(group.startTime);
    final endStr   = _clock(group.endTime);
    final dateStr  = '${group.startTime.day} ${_monthName(group.startTime.month)}';
    final l        = group.sessions.length;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFFF9FAFB) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled_rounded, size: 18, color: NasColors.darkBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$startStr ${AppLocalizations.of(context)!.to} $endStr',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateStr • $l ${AppLocalizations.of(context)!.sessionDetails}${l != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _hourGroupSection(_HourGroup group) {
    final isExpanded = _expandedHours.contains(group.startTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hourGroupHeader(group, isExpanded, () {
          setState(() {
            if (isExpanded) {
              _expandedHours.remove(group.startTime);
            } else {
              _expandedHours.add(group.startTime);
            }
          });
        }),
        if (isExpanded)
          Container(
            color: Colors.white,
            child: Column(
              children: group.sessions.asMap().entries.map((e) {
                return _sessionRow(e.value, e.key == group.sessions.length - 1);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _colH(String t, {double? w, int flex = 0, TextAlign align = TextAlign.left}) {
    final txt = Text(t, textAlign: align,
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
            color: const Color(0xFF6B7280), letterSpacing: 0.4));
    return w != null ? SizedBox(width: w, child: txt) : Expanded(flex: flex, child: txt);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Timeline widget (shared: compact = attendance bar, full = detail header)
// ─────────────────────────────────────────────────────────────────────────────
class _TimelineWidget extends StatelessWidget {
  final _Parsed parsed;
  final bool compact;
  const _TimelineWidget({required this.parsed, required this.compact});

  static String _clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final sessions = parsed.sessions;
    if (sessions.isEmpty) return const SizedBox.shrink();

    final tlStart = parsed.tlStart!;
    final tlEnd   = parsed.tlEnd!;
    final range   = tlEnd.difference(tlStart).inMilliseconds.toDouble();
    if (range <= 0) return const SizedBox.shrink();

    final labels = List.generate(
        6, (i) => tlStart.add(Duration(milliseconds: (range / 5 * i).round())));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // header row
        Row(children: [
          Text(AppLocalizations.of(context)!.activeTime,
              style: GoogleFonts.inter(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const Spacer(),
          if (parsed.isOnline && sessions.isNotEmpty) ...[
            Icon(Icons.circle, size: 8, color: parsed.colorOf(sessions.last.app)),
            const SizedBox(width: 5),
            Flexible(child: Text(sessions.last.app,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500,
                    color: parsed.colorOf(sessions.last.app)),
                overflow: TextOverflow.ellipsis)),
          ],
        ]),
        const SizedBox(height: 12),

        // coloured bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: compact ? 26 : 36,
            child: LayoutBuilder(builder: (_, bc) {
              final w = bc.maxWidth;
              return Stack(children: [
                Container(width: w, height: compact ? 26 : 36, color: const Color(0xFFF3F4F6)),
                ...sessions.where((s) => s.end != null).map((s) {
                  final left = s.start.difference(tlStart).inMilliseconds / range * w;
                  final sw   = s.end!.difference(s.start).inMilliseconds / range * w;
                  if (sw < 0.5) return const SizedBox.shrink();
                  final clampedLeft  = left.clamp(0.0, w);
                  final maxWidth     = (w - clampedLeft).clamp(1.0, double.infinity);
                  return Positioned(
                    left:   clampedLeft,
                    width:  sw.clamp(1.0, maxWidth),
                    top: 0, bottom: 0,
                    child: Container(color: s.isIdle ? const Color(0xFFE5E7EB) : parsed.colorOf(s.app)),
                  );
                }),
              ]);
            }),
          ),
        ),
        const SizedBox(height: 7),

        // time labels
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((t) => Text(_clock(t),
                style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF9CA3AF)))).toList()),

        // colour legend (full mode only)
        if (!compact && parsed.apps.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 6, children: parsed.apps.take(6).map((u) {
            final col = parsed.colorOf(u.app);
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text(u.app, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis),
            ]);
          }).toList()),
        ],
      ]),
    );
  }

}