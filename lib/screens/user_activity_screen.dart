import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/user_activity_model.dart';
import 'package:nashr/screens/user_activity_detail_screen.dart';
import '../widgets/loader.dart';

// ─── Data model ──────────────────────────────────────────────────────────────
class _ActivityRow {
  final String empId;
  final String date;
  final int activeMs;
  final int totalMs;
  final UserActivityModel raw;

  const _ActivityRow({
    required this.empId,
    required this.date,
    required this.activeMs,
    required this.totalMs,
    required this.raw,
  });

  int get score => totalMs > 0 ? ((activeMs / totalMs) * 100).round() : 0;
}

// ─── Filter mode ─────────────────────────────────────────────────────────────
enum _FilterMode { branch, team, onlyMe }

// ─────────────────────────────────────────────────────────────────────────────
class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen>
    with SingleTickerProviderStateMixin {

  final SingletonClass _singleton = SingletonClass();

  // ── Loading flags ─────────────────────────────────────────────────────────
  bool _isInitialLoading = true;
  bool _isLoadingBranch  = false;
  bool _isLoadingData    = false;

  // ── Filter state ──────────────────────────────────────────────────────────
  _FilterMode _filterMode = _FilterMode.branch;

  // ── Date state ────────────────────────────────────────────────────────────
  final List<DateTime> _dates       = [];
  int      _selectedDateIndex       = -1;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isDateRange                 = false;

  // ── Employee data ─────────────────────────────────────────────────────────
  Set<String>                            _branchEmpIds = {};
  final Map<String, Map<String, String?>> _empInfo     = {};

  // ── Rows ──────────────────────────────────────────────────────────────────
  List<_ActivityRow> _rows         = [];
  List<_ActivityRow> _filteredRows = [];

  // ── Controllers ───────────────────────────────────────────────────────────
  final ScrollController      _dateScrollCtrl = ScrollController();
  final TextEditingController _searchCtrl     = TextEditingController();
  late  AnimationController   _fadeCtrl;
  bool _isSearching = false;

  // ══════════════════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    final now = DateTime.now();
    _buildDateList(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day),
    );
    _startDate   = DateTime(now.year, now.month, now.day);
    _endDate     = DateTime(now.year, now.month, now.day);
    _isDateRange = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialize();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _dateScrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  INIT  ← FIX: ensure branchID is resolved before building emp info
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    try {
      // 1. Fetch all remote data first
      await _singleton.getTeamBranchData();
      await _singleton.getBranchData();

      final grade = _singleton.getJWTModel()?.grade ?? '';

      // 2. Set default filter mode
      if (grade == 'L4') {
        _filterMode = _FilterMode.onlyMe;
      } else if (grade == 'L3') {
        _filterMode = _FilterMode.team;
      } else {
        _filterMode = _FilterMode.branch;
      }

      // 3. FIX: seed branchID from the first available branch when it's
      //    empty so branch-mode init always has a valid ID to work with.
      if (_filterMode == _FilterMode.branch &&
          (_singleton.branchID == null || _singleton.branchID!.isEmpty)) {
        if (_singleton.branchDataList.isNotEmpty) {
          final first = _singleton.branchDataList.first;
          _singleton.branchID   = first.data?.branch?.id;
          _singleton.branchName = first.data?.branch?.branchName;
          log('🏢 Seeded branchID: ${_singleton.branchID}');
        }
      }

      // 4. Build emp info (now branchID is guaranteed non-null for branch mode)
      await _buildEmpInfo(grade);

      // 5. Fetch activity
      await _fetchActivity();
      _fadeCtrl.forward();
    } catch (e, s) {
      log('❌ _initialize error: $e\n$s');
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  EMP INFO CACHE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _buildEmpInfo(String grade) async {
    _empInfo.clear();

    if (grade == 'L4') {
      final jwt = _singleton.getJWTModel();
      final id  = jwt?.empId ?? '';
      if (id.isNotEmpty) {
        _empInfo[id] = {
          'name': (jwt?.userName ?? '').trim(),
          'pic': _singleton.employeeDataList.isNotEmpty
              ? _singleton.employeeDataList.first.data.first.profilePic?.toString()
              : null,
          'designation': _singleton.employeeDataList.isNotEmpty
              ? _singleton.employeeDataList.first.data.first
              .employeeInfo?.first.designation?.toString()
              : null,
        };
      }
      return;
    }

    if (grade == 'L3') {
      for (final bd in _singleton.branchDataList) {
        for (final dd in bd.data?.branch?.departmentDetails ?? []) {
          for (final dept in dd.departments ?? []) {
            for (final team in dept.teams ?? []) {
              for (final td in team.teamData ?? []) {
                final id = td.empId?.toString() ?? '';
                if (id.isNotEmpty) {
                  _empInfo[id] = {
                    'name':        td.userName?.toString() ?? '',
                    'pic':         null,
                    'designation': td.designation?.toString(),
                  };
                }
              }
            }
          }
        }
      }
      return;
    }

    // L0 / L1 / L2 — branch employees
    // branchID is guaranteed seeded in _initialize before this call
    await _extractBranchEmpIds(_singleton.branchID);
    _buildEmpInfoFromTeamBranchData();
  }

  /// Builds _empInfo map from already-loaded teamBranchDataList.
  void _buildEmpInfoFromTeamBranchData() {
    for (final item in _singleton.teamBranchDataList) {
      for (final emp in item.data?.employees ?? []) {
        final info = emp.employeeInfo?.isNotEmpty == true
            ? emp.employeeInfo!.first
            : null;
        final id = info?.empId?.toString() ?? '';
        if (id.isNotEmpty) {
          _empInfo[id] = {
            'name':        '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim(),
            'pic':         emp.profilePic?.toString(),
            'designation': info?.designation?.toString(),
          };
        }
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BRANCH HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _extractBranchEmpIds(String? branchId) async {
    await _singleton.getTeamBranchData();
    _branchEmpIds = {};

    if (branchId == null || branchId.isEmpty ||
        _singleton.teamBranchDataList.isEmpty) {
      log('⚠️ Invalid branch or empty data');
      return;
    }

    final ids = <String>[];
    for (final item in _singleton.teamBranchDataList) {
      final bd = item.data;
      if (bd?.employees?.first.branchId != branchId) continue;
      for (final emp in bd!.employees!) {
        for (final info in emp.employeeInfo ?? []) {
          if ((info.empId?.isNotEmpty ?? false) &&
              info.employeeStatus == 'Active') {
            ids.add(info.empId!);
          }
        }
      }
    }
    _branchEmpIds = ids.toSet();
    log('✅ Branch ($branchId): ${_branchEmpIds.length} employees');
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _buildDateList(DateTime start, DateTime end) {
    _dates.clear();
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      _dates.add(d);
    }
    final today = DateTime.now();
    _selectedDateIndex = _dates.indexWhere(
          (d) => d.year == today.year && d.month == today.month && d.day == today.day,
    );
    if (_selectedDateIndex == -1 && _dates.isNotEmpty) {
      _selectedDateIndex = _dates.length - 1;
    }
  }

  void _scrollToSelected() {
    if (!_dateScrollCtrl.hasClients || _selectedDateIndex < 0) return;
    final offset = (_selectedDateIndex * 62.0) - 100;
    _dateScrollCtrl.animateTo(
      offset.clamp(0.0, _dateScrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  String _dayLabel(DateTime d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  String _formatMs(int ms) {
    final h = ms ~/ 3600000;
    final m = (ms % 3600000) ~/ 60000;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESOLVE EMP IDS
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> _resolveEmpIds() async {
    final grade = _singleton.getJWTModel()?.grade ?? '';
    final myId  = _singleton.getJWTModel()?.empId  ?? '';

    if (grade == 'L4' || _filterMode == _FilterMode.onlyMe) {
      return myId.isNotEmpty ? [myId] : [];
    }

    if (_filterMode == _FilterMode.branch) {
      // FIX: if _branchEmpIds is stale/empty, re-extract before returning
      if (_branchEmpIds.isEmpty && (_singleton.branchID?.isNotEmpty ?? false)) {
        await _extractBranchEmpIds(_singleton.branchID);
      }
      return _branchEmpIds.toList();
    }

    // Team mode — L3
    if (grade == 'L3') {
      final ids = <String>[];
      for (final bd in _singleton.branchDataList) {
        for (final dd in bd.data?.branch?.departmentDetails ?? []) {
          for (final dept in dd.departments ?? []) {
            for (final supervisor in dept.supervisors ?? []) {
              if (supervisor.empId == myId) {
                for (final team in dept.teams ?? []) {
                  if (team.teamId == supervisor.teamId) {
                    for (final member in team.members ?? []) {
                      if (member.empId?.isNotEmpty ?? false) {
                        ids.add(member.empId!);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      return ids;
    }

    // L0/L1/L2 team mode
    if (_branchEmpIds.isEmpty && (_singleton.branchID?.isNotEmpty ?? false)) {
      await _extractBranchEmpIds(_singleton.branchID);
    }
    return _branchEmpIds.toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  FETCH
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _fetchActivity() async {
    if (mounted) setState(() => _isLoadingData = true);

    try {
      final empIds = await _resolveEmpIds();
      if (empIds.isEmpty) {
        if (mounted) {
          setState(() {
            _rows          = [];
            _filteredRows  = [];
            _isLoadingData = false;
          });
        }
        return;
      }

      final start = _startDate.toIso8601String().split('T').first;
      final end   = _endDate.toIso8601String().split('T').first;
      final uri   = Uri.parse(
        '${_singleton.baseURL}/activity-session/by-date-range/$start/$end',
      );

      log('📡 POST $uri | empIds: ${empIds.length}');

      final response = await http.post(
        uri,
        body:    json.encode({'empIds': empIds.toSet().toList()}),
        headers: _singleton.getHeaders(),
      );

      log('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final records = decoded is List
            ? decoded
            .map((e) => UserActivityModel.fromJson(e as Map<String, dynamic>))
            .toList()
            : [UserActivityModel.fromJson(decoded as Map<String, dynamic>)];

        _singleton.userActivityDataList
          ..clear()
          ..addAll(records);

        final rows = _buildRows(records);
        if (mounted) {
          setState(() {
            _rows          = rows;
            _filteredRows  = List.from(rows);
            _isLoadingData = false;
          });
        }
      } else {
        log('❌ API error: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _rows          = [];
            _filteredRows  = [];
            _isLoadingData = false;
          });
        }
      }
    } catch (e) {
      log('🚨 Exception: $e');
      if (mounted) {
        setState(() {
          _rows          = [];
          _filteredRows  = [];
          _isLoadingData = false;
        });
      }
    }
  }

  List<_ActivityRow> _buildRows(List<UserActivityModel> records) {
    return records
        .where((r) => (r.empId ?? '').isNotEmpty)
        .map((r) {
      return _ActivityRow(
        empId:    r.empId!,
        date:     r.date ?? '',
        activeMs: (r.body?.activeTimeMs as num?)?.toInt() ?? 0,
        totalMs:  (r.body?.totalTimeMs  as num?)?.toInt() ?? 0,
        raw:      r,
      );
    })
        .toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SEARCH
  // ══════════════════════════════════════════════════════════════════════════

  void _applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRows = List.from(_rows);
      } else {
        final q = query.toLowerCase();
        _filteredRows = _rows.where((r) {
          final name = (_empInfo[r.empId]?['name'] ?? '').toLowerCase();
          return r.empId.toLowerCase().contains(q) || name.contains(q);
        }).toList();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final grade = _singleton.getJWTModel()?.grade ?? '';

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildDateStrip(context),
            const SizedBox(height: 6),
            if (grade != 'L4') _buildActionRow(context),
            const SizedBox(height: 6),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          _iconButton(
            icon:  Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.userActivity,
              style: GoogleFonts.inter(
                fontSize:   18,
                fontWeight: FontWeight.w700,
                color:      NasColors.darkBlue,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _iconButton(
            icon:  Icons.calendar_month_rounded,
            onTap: () => _pickDateRange(context),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width:  42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color:        Colors.white,
          boxShadow: [
            BoxShadow(
              color:      Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: NasColors.darkBlue, size: 20),
      ),
    );
  }

  // ── Date Range Picker ─────────────────────────────────────────────────────

  Future<void> _pickDateRange(BuildContext context) async {
    final now    = DateTime.now();
    final picked = await showDateRangePicker(
      context:          context,
      firstDate:        DateTime(now.year - 2),
      lastDate:         now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end:   now,
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: NasColors.darkBlue),
          ),
          colorScheme: ColorScheme.light(
            primary:            NasColors.darkBlue,
            onPrimary:          Colors.white,
            secondaryContainer: NasColors.icons,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate         = picked.start;
        _endDate           = picked.end;
        _isDateRange       = true;
        _selectedDateIndex = -1;
        _buildDateList(picked.start, picked.end);
      });
      await _fetchActivity();
    }
  }

  // ── Date Strip ────────────────────────────────────────────────────────────

  Widget _buildDateStrip(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller:      _dateScrollCtrl,
        scrollDirection: Axis.horizontal,
        itemCount:       _dates.length,
        itemBuilder: (ctx, i) {
          final date     = _dates[i];
          final selected = !_isDateRange && _selectedDateIndex == i;

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDateIndex = i;
                _startDate         = date;
                _endDate           = date;
                _isDateRange       = false;
              });
              await _fetchActivity();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width:    58,
              margin:   const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                color:        selected ? NasColors.darkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color:      NasColors.darkBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset:     const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: GoogleFonts.inter(
                      fontSize:   17,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dayLabel(date),
                    style: GoogleFonts.inter(
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white70 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Action Row  ← FIX: overflow resolved with constrained layout ──────────

  Widget _buildActionRow(BuildContext context) {
    final l     = AppLocalizations.of(context)!;
    final grade = _singleton.getJWTModel()?.grade ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // ── Search mode: field expands to fill all space ─────────────
          if (_isSearching) ...[
            Expanded(child: _buildSearchField(l)),
            const SizedBox(width: 6),
          ] else ...[
            // Branch dropdown — lower grades only, constrained width
            if (grade != 'L3' && grade != 'L4')
              Flexible(
                flex: 2,
                child: _buildBranchDropdown(context),
              ),

            const Spacer(),

            // FIX: wrap chips in a Row that never overflows by using
            // IntrinsicWidth / minimal sizing; no Spacer between chips.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (grade == 'L3' || (grade != 'L4' && grade != 'L3'))
                  _buildFilterChip(
                    label:    l.teams,
                    selected: _filterMode == _FilterMode.team,
                    onTap: () async {
                      if (_filterMode == _FilterMode.team) return;
                      setState(() => _filterMode = _FilterMode.team);
                      await _fetchActivity();
                    },
                  ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label:    l.onlyMe,
                  selected: _filterMode == _FilterMode.onlyMe,
                  onTap: () async {
                    if (_filterMode == _FilterMode.onlyMe) return;
                    setState(() => _filterMode = _FilterMode.onlyMe);
                    await _fetchActivity();
                  },
                ),
              ],
            ),

            const SizedBox(width: 8),
          ],

          // Search toggle — always last
          _iconButton(
            icon:  _isSearching ? Icons.close_rounded : Icons.search_rounded,
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchCtrl.clear();
                  _filteredRows = List.from(_rows);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l) {
    return TextField(
      controller:  _searchCtrl,
      autofocus:   true,
      cursorColor: Colors.grey,
      onChanged:   _applySearch,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText:  l.search,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
        filled:    true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      color:  Colors.white,
      shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        setState(() {
          _isLoadingBranch = true;
          _filterMode      = _FilterMode.branch;
        });
        try {
          _singleton.teamAttendanceDataList.clear();
          _branchEmpIds.clear();
          _singleton.branchID = value;

          await _singleton.getTeamBranchData();
          await _extractBranchEmpIds(value);

          // Rebuild emp info for new branch
          _empInfo.clear();
          _buildEmpInfoFromTeamBranchData();

          final branch = _singleton.availableBranches
              .firstWhere((b) => b.branchId.toString() == value);
          _singleton.branchName = branch.branchName ?? '';

          log('🏢 Branch: $value | 👥 IDs: ${_branchEmpIds.length}');
          await _fetchActivity();
        } catch (e) {
          log('❌ Branch error: $e');
        } finally {
          if (mounted) setState(() => _isLoadingBranch = false);
        }
      },
      itemBuilder: (_) => _singleton.availableBranches
          .map((b) => PopupMenuItem<String>(
        value: b.branchId,
        child: Text(b.branchName ?? '---',
            style: GoogleFonts.inter(fontSize: 14)),
      ))
          .toList(),
      child: Container(
        height:      44,
        // FIX: drop fixed maxWidth constraint — let Flexible handle sizing
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _filterMode == _FilterMode.branch
              ? NasColors.darkBlue
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:      Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset:     const Offset(0, 3),
            )
          ],
        ),
        child: _isLoadingBranch
            ? Center(
          child: SizedBox(
            height: 18,
            width:  18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _filterMode == _FilterMode.branch
                  ? Colors.white
                  : NasColors.darkBlue,
            ),
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/site.png',
              height: 14,
              width:  14,
              color: _filterMode == _FilterMode.branch
                  ? Colors.white
                  : null,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _singleton.branchName?.isNotEmpty == true
                    ? _singleton.branchName!
                    : (_singleton.branchDataList.isNotEmpty
                    ? _singleton.branchDataList.first.data?.branch
                    ?.branchName ??
                    '---'
                    : '---'),
                style: GoogleFonts.inter(
                  fontSize:   13,
                  fontWeight: FontWeight.w600,
                  color: _filterMode == _FilterMode.branch
                      ? Colors.white
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size:  18,
              color: _filterMode == _FilterMode.branch
                  ? Colors.white
                  : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String       label,
    required bool         selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NasColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:      Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset:     const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height:   14,
              width:    14,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : NasColors.darkBlue,
                  width: 2,
                ),
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: selected
                  ? Center(
                child: Container(
                  height: 6,
                  width:  6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NasColors.darkBlue,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (_isInitialLoading || _isLoadingData) return const Loader();

    if (_filteredRows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child:
                Lottie.asset('images/empty.json'),
              ),
              Text(
                AppLocalizations.of(context)!.noData,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: NasColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeCtrl,
      child: ListView.separated(
        padding:          const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount:        _filteredRows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final row         = _filteredRows[i];
          final info        = _empInfo[row.empId];
          final name        = info?['name']?.isNotEmpty == true
              ? info!['name']!
              : row.empId;
          final picUrl      = info?['pic'];
          final designation = info?['designation'] ?? '';

          return _ActivityCard(
            row:         row,
            name:        name,
            picUrl:      picUrl,
            designation: designation,
            isDateRange: _isDateRange,
            formatMs:    _formatMs,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserActivityDetailScreen(
                  empId:       row.empId,
                  empName:     name,
                  picUrl:      picUrl,
                  designation: designation,
                  startDate:   _startDate,
                  endDate:     _endDate,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CARD WIDGET  (unchanged logic, no layout changes needed here)
// ══════════════════════════════════════════════════════════════════════════════

class _ActivityCard extends StatelessWidget {
  final _ActivityRow             row;
  final String                   name;
  final String?                  picUrl;
  final String                   designation;
  final bool                     isDateRange;
  final String Function(int)     formatMs;
  final VoidCallback             onTap;

  const _ActivityCard({
    required this.row,
    required this.name,
    required this.picUrl,
    required this.designation,
    required this.isDateRange,
    required this.formatMs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:      Colors.grey.withOpacity(0.12),
              blurRadius: 10,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:        NasColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      row.empId,
                      style: GoogleFonts.inter(
                        fontSize:   12,
                        fontWeight: FontWeight.w700,
                        color:      NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isDateRange && row.date.isNotEmpty)
                    Text(
                      row.date,
                      style: GoogleFonts.inter(
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                        color:      Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Name + avatar + online badge ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius:          24,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: (picUrl?.isNotEmpty ?? false)
                        ? NetworkImage(picUrl!)
                        : null,
                    child: (picUrl == null || picUrl!.isEmpty)
                        ? Image.asset(
                      'images/avatar.png',
                      fit:          BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.person, color: Colors.grey.shade400),
                    )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize:   15,
                            fontWeight: FontWeight.w700,
                            color:      Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (designation.isNotEmpty)
                          Text(
                            designation,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:    Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // ── Footer ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        formatMs(row.activeMs),
                        style: GoogleFonts.inter(
                          fontSize:   13,
                          fontWeight: FontWeight.w700,
                          color:      Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.activeTime,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color:    Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${row.score}%',
                        style: GoogleFonts.inter(
                          fontSize:   13,
                          fontWeight: FontWeight.w700,
                          color:      NasColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value:           row.score / 100,
                      minHeight:       6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        row.score >= 75
                            ? Colors.green
                            : row.score >= 40
                            ? Colors.orange
                            : NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.productivityScore,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color:    Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}