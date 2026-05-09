import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/request_controller/user_activity_model.dart';

const List<Color> _kColors = [Color(0xFF4A90D9),Color(0xFF7B61FF),Color(0xFF34C759),Color(0xFFFF3B30),Color(0xFFFF9500),Color(0xFF5AC8FA),Color(0xFFAF52DE),Color(0xFFFF2D55)];

class UserActivityDetailScreen extends StatefulWidget {
  final String empId, empName, designation;
  final String? picUrl;
  final List<UserActivityModel> records;
  const UserActivityDetailScreen({super.key, required this.empId, required this.empName, required this.designation, this.picUrl, required this.records});
  @override
  State<UserActivityDetailScreen> createState() => _State();
}

class _State extends State<UserActivityDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  int _activeMs = 0, _totalMs = 0;
  bool _online = false;
  final List<_Sess> _sessions = [];
  List<String> _topApps = [];
  final Map<String, Color> _cache = {};
  DateTime? _tlStart, _tlEnd;

  Color _c(String app) => _cache.putIfAbsent(app, () => _kColors[_cache.length % _kColors.length]);
  String _fmt(int ms) { final h = Duration(milliseconds: ms).inHours; final m = Duration(milliseconds: ms).inMinutes.remainder(60); return h > 0 ? '${h}h ${m}m' : '${m}m'; }
  String _t(DateTime d) { final h = d.hour % 12 == 0 ? 12 : d.hour % 12; return '$h:${d.minute.toString().padLeft(2,'0')} ${d.hour < 12 ? 'AM' : 'PM'}'; }
  Color _sc(int s) => s >= 75 ? const Color(0xFF34C759) : s >= 45 ? const Color(0xFFFF9500) : const Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, int> usage = {};
    for (final r in widget.records) {
      _activeMs += (r.body?.activeTimeMs as num?)?.toInt() ?? 0;
      _totalMs  += (r.body?.totalTimeMs  as num?)?.toInt() ?? 0;
      if (r.activitySession?.any((s) => s.endDate != null && (now - (s.endDate as num).toInt()) < 300000) ?? false) _online = true;
      // top apps from body
      for (final a in r.body?.mostUsedApps ?? []) usage[a] = (usage[a] ?? 0) + 1;
      // sessions
      for (final s in r.activitySession ?? []) {
        final app   = (s.app?.toString().isNotEmpty == true ? s.app.toString() : s.title?.toString() ?? 'Unknown');
        final title = s.title?.toString() ?? '';
        final bMs   = s.beginDate != null ? (s.beginDate as num).toInt() : null;
        final eMs   = s.endDate   != null ? (s.endDate   as num).toInt() : null;
        if (bMs == null) continue;
        final start = DateTime.fromMillisecondsSinceEpoch(bMs);
        final end   = eMs != null ? DateTime.fromMillisecondsSinceEpoch(eMs) : null;
        final dur   = end != null ? end.difference(start).inMilliseconds : 0;
        _sessions.add(_Sess(app: app, title: title, start: start, end: end, durMs: dur));
        usage[app] = (usage[app] ?? 0) + dur;
      }
    }
    _sessions.sort((a, b) => a.start.compareTo(b.start));
    final sorted = usage.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    _topApps = sorted.take(6).map((e) => e.key).toList();
    for (final a in _topApps) _c(a);
    for (final s in _sessions) _c(s.app);
    if (_sessions.isNotEmpty) { _tlStart = _sessions.first.start; _tlEnd = _sessions.last.end ?? _sessions.last.start; }
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  Widget _card(Widget child) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,2))]),
      child: child);

  @override
  Widget build(BuildContext context) {
    final score = _totalMs > 0 ? ((_activeMs / _totalMs) * 100).round() : 0;
    final sc = _sc(score);
    final range = _tlStart != null && _tlEnd != null ? _tlEnd!.difference(_tlStart!).inMilliseconds.toDouble() : 0.0;
    final labels = range > 0 ? List.generate(6, (i) => _tlStart!.add(Duration(milliseconds: (range / 5 * i).round()))) : <DateTime>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(child: Column(children: [
          // ── AppBar ──
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.employeeActivityDetail,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // ── Body ──
          Expanded(child: FadeTransition(opacity: CurvedAnimation(parent: _ac, curve: Curves.easeOut),
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 28), children: [
              // Score card
              _card(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppLocalizations.of(context)!.productivityScore, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text('$score%', style: GoogleFonts.inter(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.1)),
                    const SizedBox(width: 6),
                    Icon(score >= 50 ? Icons.arrow_outward_rounded : Icons.south_east_rounded, color: sc, size: 24),
                  ]),
                  const SizedBox(height: 4),
                  Text(widget.designation.isNotEmpty ? widget.designation : 'Employee', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500)),
                ])),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: _online ? const Color(0xFFE8FAF2) : Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.circle, size: 8, color: _online ? const Color(0xFF00C48C) : Colors.grey.shade400),
                        const SizedBox(width: 5),
                        Text(_online ? AppLocalizations.of(context)!.online : AppLocalizations.of(context)!.offline, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _online ? const Color(0xFF00C48C) : Colors.grey.shade500)),
                      ])),
                  const SizedBox(height: 8),
                  Text(widget.empId, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400)),
                ]),
              ])),

              // Tracked time card
              _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.totalTrackedTime, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                  Text(_fmt(_activeMs), style: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.1)),
                  Text('$score%', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                ]),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: score / 100, minHeight: 10, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(sc))),
              ])),

              // Most used apps
              if (_topApps.isNotEmpty) _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.mostUsedApps, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: _topApps.map((app) {
                  final c = _c(app);
                  return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.25))),
                      child: Text(app, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: c)));
                }).toList()),
              ])),

              // Timeline
              if (_sessions.isNotEmpty && range > 0) _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.activityTimeLine, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 14),
                ClipRRect(borderRadius: BorderRadius.circular(8),
                    child: SizedBox(height: 38, child: LayoutBuilder(builder: (_, bc) {
                      final w = bc.maxWidth;
                      return Stack(children: [
                        Container(width: w, height: 38, color: Colors.grey.shade200),
                        ..._sessions.where((s) => s.end != null).map((s) {
                          final left = s.start.difference(_tlStart!).inMilliseconds / range * w;
                          final sw   = s.end!.difference(s.start).inMilliseconds / range * w;
                          if (sw < 0.5) return const SizedBox.shrink();
                          return Positioned(left: left.clamp(0.0, w), width: sw.clamp(1.0, w - left.clamp(0.0, w)), top: 0, bottom: 0,
                              child: Container(color: _c(s.app)));
                        }),
                      ]);
                    }))),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels.map((t) => Text(_t(t), style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500))).toList()),
              ])),

              // Session details
              if (_sessions.isNotEmpty) _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context)!.sessionDetails, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 4),
                ..._sessions.asMap().entries.map((e) {
                  final s = e.value; final isLast = e.key == _sessions.length - 1; final col = _c(s.app);
                  final tr = s.end != null ? '${_t(s.start)} - ${_t(s.end!)}' : _t(s.start);
                  return Column(children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          SizedBox(width: 112, child: Text(tr, style: GoogleFonts.inter(fontSize: 10.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500))),
                          Container(width: 3, height: 38, decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              alignment: Alignment.center,
                              child: Text(s.app.isNotEmpty ? s.app[0].toUpperCase() : '?', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: col))),
                          const SizedBox(width: 9),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.app, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (s.title.isNotEmpty && s.title != s.app) Text(s.title, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                          const SizedBox(width: 6),
                          Text(_fmt(s.durMs), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
                        ])),
                    if (!isLast) Divider(height: 1, thickness: 0.7, color: Colors.grey.shade100),
                  ]);
                }),
              ])),

              // Empty
              if (_sessions.isEmpty && _topApps.isEmpty) _card(Padding(padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Column(children: [
                    Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.noData, style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade400)),
                  ])))),
            ]),
          )),
        ])),
      ),
    );
  }
}

class _Sess {
  final String app, title;
  final DateTime start;
  final DateTime? end;
  final int durMs;
  _Sess({required this.app, required this.title, required this.start, this.end, required this.durMs});
}