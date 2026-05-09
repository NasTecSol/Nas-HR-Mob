import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:http/http.dart' as http;
import '../request_controller/branch_model.dart';
import 'package:nashr/request_controller/user_activity_model.dart';
import 'package:nashr/screens/user_activity_detail_screen.dart';

/// Aggregated data for a single employee (merged across all date records)
class _AggregatedEmployee {
  final String empId;
  final int totalActiveMs;
  final int totalMs;
  final bool isOnline;
  final List<UserActivityModel> rawRecords;

  _AggregatedEmployee({
    required this.empId,
    required this.totalActiveMs,
    required this.totalMs,
    required this.isOnline,
    required this.rawRecords,
  });

  int get score => totalMs > 0 ? ((totalActiveMs / totalMs) * 100).round() : 0;
}

/// Filter mode — three mutually exclusive states
enum _FilterMode { branch, team, onlyMe }

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SingletonClass _singleton = SingletonClass();

  bool _isLoadingBranchData = false;
  bool _isLoading = false;
  bool isDateRangeSelected = false;

  /// Active filter mode — mutually exclusive
  _FilterMode _filterMode = _FilterMode.branch; // default, adjusted per grade in initState

  final List<DateTime> _dates = [];
  int? _selectedDateIndex;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  Set<String> selectedBranchIds = {};
  List<UserActivityModel> _allEmployees = [];

  /// Grouped & aggregated: one entry per empId
  List<_AggregatedEmployee> _aggregatedEmployees = [];
  List<_AggregatedEmployee> _filteredAggregated = [];

  // empId → {name, profilePic, designation}
  final Map<String, Map<String, String?>> _empInfoMap = {};

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
    _initDates(start: _startDate!, end: _endDate!);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _singleton.getTeamBranchData();
        await _singleton.getBranchData();
        final grade = _singleton.getJWTModel()?.grade ?? '';

        // ── Set default filter mode per grade ─────────────────────────────
        if (grade == 'L4') {
          // L4: always only self — no UI controls
          _filterMode = _FilterMode.onlyMe;
        } else if (grade == 'L3') {
          // L3: default to Team
          _filterMode = _FilterMode.team;
        } else {
          // L0/L1/L2: default to Branch
          _filterMode = _FilterMode.branch;
        }

        if (grade == 'L4') {
          final empId = _singleton.getJWTModel()?.empId ?? '';
          if (empId.isNotEmpty) {
            _empInfoMap[empId] = {
              'name': (_singleton.getJWTModel()?.userName ?? '').trim(),
              'pic': _singleton.employeeDataList.first.data.first.profilePic?.toString(),
              'designation': _singleton.employeeDataList.first.data.first.employeeInfo!.first.designation?.toString(),
            };
          }
        } else if (grade == 'L3') {
          for (BranchData bd in _singleton.branchDataList) {
            for (var dd in bd.data?.branch?.departmentDetails ?? []) {
              for (var dept in dd.departments ?? []) {
                for (var team in dept.teams ?? []) {
                  for (var td in team.teamData ?? []) {
                    final id = td.empId?.toString() ?? '';
                    if (id.isNotEmpty) {
                      _empInfoMap[id] = {
                        'name': td.userName?.toString() ?? '',
                        'pic': null,
                        'designation': td.designation?.toString(),
                      };
                    }
                  }
                }
              }
            }
          }
        } else {
          // L0/L1/L2 — default branch load
          await extractAllEmployeeIdsForBranch(_singleton.branchID);
          for (var item in _singleton.teamBranchDataList) {
            for (var emp in item.data?.employees ?? []) {
              final info = (emp.employeeInfo?.isNotEmpty ?? false) ? emp.employeeInfo!.first : null;
              final id = info?.empId?.toString() ?? '';
              if (id.isNotEmpty) {
                _empInfoMap[id] = {
                  'name': '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim(),
                  'pic': emp.profilePic?.toString(),
                  'designation': info?.designation?.toString(),
                };
              }
            }
          }
        }
        await _fetchActivity();
      } catch (e, s) {
        log("❌ initState error: $e\n$s");
      }
    });
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  void _initDates({required DateTime start, required DateTime end}) {
    _dates.clear();
    final today = DateTime.now();
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      _dates.add(d);
    }
    _selectedDateIndex = _dates.indexWhere(
            (d) => d.year == today.year && d.month == today.month && d.day == today.day);
    if (_selectedDateIndex != -1) _selectedDate = today;
  }

  String _dayLabel(DateTime d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  /// Groups raw [UserActivityModel] list by empId and sums up active/total ms.
  List<_AggregatedEmployee> _aggregateByEmployee(List<UserActivityModel> records,
      {bool combine = true}) {
    final Map<String, List<UserActivityModel>> grouped = {};
    for (final r in records) {
      final id = r.empId ?? '';
      if (id.isEmpty) continue;
      grouped.putIfAbsent(id, () => []).add(r);
    }

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    return grouped.entries.map((entry) {
      final empId = entry.key;
      final list = entry.value;

      if (!combine) {
        final r = list.first;
        final active = (r.body?.activeTimeMs as num?)?.toInt() ?? 0;
        final total = (r.body?.totalTimeMs as num?)?.toInt() ?? 0;
        final online = r.activitySession?.any(
              (s) => s.endDate != null && (nowMs - (s.endDate as num).toInt()) < 300000,
        ) ??
            false;
        return _AggregatedEmployee(
          empId: empId,
          totalActiveMs: active,
          totalMs: total,
          isOnline: online,
          rawRecords: list,
        );
      }

      int sumActive = 0;
      int sumTotal = 0;
      bool online = false;

      for (final r in list) {
        sumActive += (r.body?.activeTimeMs as num?)?.toInt() ?? 0;
        sumTotal += (r.body?.totalTimeMs as num?)?.toInt() ?? 0;
        if (r.activitySession?.any(
              (s) => s.endDate != null && (nowMs - (s.endDate as num).toInt()) < 300000,
        ) ??
            false) {
          online = true;
        }
      }

      return _AggregatedEmployee(
        empId: empId,
        totalActiveMs: sumActive,
        totalMs: sumTotal,
        isOnline: online,
        rawRecords: list,
      );
    }).toList();
  }

  /// Resolves the list of empIds to fetch based on grade + filter mode.
  Future<List<String>> _resolveEmpIds() async {
    final grade = _singleton.getJWTModel()?.grade ?? '';
    final myEmpId = _singleton.getJWTModel()?.empId ?? '';

    // ── L4: always only self ──────────────────────────────────────────────
    if (grade == 'L4') {
      return myEmpId.isNotEmpty ? [myEmpId] : [];
    }

    // ── "Only Me" mode ────────────────────────────────────────────────────
    if (_filterMode == _FilterMode.onlyMe) {
      return myEmpId.isNotEmpty ? [myEmpId] : [];
    }

    // ── "Branch" mode (L0/L1/L2) ─────────────────────────────────────────
    if (_filterMode == _FilterMode.branch) {
      return selectedBranchIds.toList();
    }

    // ── "Team" mode ───────────────────────────────────────────────────────
    if (grade == 'L3') {
      List<String> empIds = [];
      for (BranchData bd in _singleton.branchDataList) {
        for (var dd in bd.data?.branch?.departmentDetails ?? []) {
          for (var dept in dd.departments ?? []) {
            for (var supervisor in dept.supervisors ?? []) {
              if (supervisor.empId == myEmpId) {
                for (var team in dept.teams ?? []) {
                  if (team.teamId == supervisor.teamId) {
                    for (var member in team.members ?? []) {
                      if (member.empId?.isNotEmpty ?? false) empIds.add(member.empId!);
                    }
                  }
                }
              }
            }
          }
        }
      }
      return empIds;
    }

    // ── L0/L1/L2 team mode — same as branch employees ────────────────────
    return selectedBranchIds.toList();
  }

  Future<void> _fetchActivity() async {
    setState(() {
      _isLoading = true;
      _allEmployees = [];
      _aggregatedEmployees = [];
      _filteredAggregated = [];
    });
    try {
      final empIds = await _resolveEmpIds();

      final start = _startDate!.toIso8601String().split('T').first;
      final end = _endDate!.toIso8601String().split('T').first;

      final uri = Uri.parse('${_singleton.baseURL}/activity-session/by-date-range/$start/$end');
      log('📡 POST $uri | empIds: $empIds');
      final response = await http.post(
        uri,
        body: json.encode({'empIds': empIds.toSet().toList()}),
        headers: _singleton.getHeaders(),
      );
      log('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        final List<UserActivityModel> records = decoded is List
            ? decoded.map((e) => UserActivityModel.fromJson(e as Map<String, dynamic>)).toList()
            : [UserActivityModel.fromJson(decoded as Map<String, dynamic>)];

        _singleton.userActivityDataList
          ..clear()
          ..addAll(records);

        final bool isSingleDay = _startDate!.year == _endDate!.year &&
            _startDate!.month == _endDate!.month &&
            _startDate!.day == _endDate!.day;
        final aggregated = _aggregateByEmployee(records, combine: !isSingleDay);

        setState(() {
          _allEmployees = records;
          _aggregatedEmployees = aggregated;
          _filteredAggregated = List.from(aggregated);
          _isLoading = false;
        });
      } else {
        log('❌ Error: ${response.statusCode}');
        setState(() {
          _allEmployees = [];
          _aggregatedEmployees = [];
          _filteredAggregated = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      log('🚨 Exception: $e');
      setState(() {
        _allEmployees = [];
        _aggregatedEmployees = [];
        _filteredAggregated = [];
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAggregated = List.from(_aggregatedEmployees);
      } else {
        final q = query.toLowerCase();
        _filteredAggregated = _aggregatedEmployees.where((e) {
          final info = _empInfoMap[e.empId];
          final name = (info?['name'] ?? '').toLowerCase();
          return e.empId.toLowerCase().contains(q) || name.contains(q);
        }).toList();
      }
    });
  }

  Future<void> extractAllEmployeeIdsForBranch(String? selectedBranchId) async {
    await _singleton.getTeamBranchData();
    List<String> allEmployeeIds = [];
    selectedBranchIds.clear();
    if (selectedBranchId != null &&
        selectedBranchId.isNotEmpty &&
        _singleton.teamBranchDataList.isNotEmpty) {
      for (var branchItem in _singleton.teamBranchDataList) {
        final branchData = branchItem.data;
        if (branchData?.employees?.first.branchId != selectedBranchId) continue;
        for (var employee in branchData?.employees ?? []) {
          for (var info in employee.employeeInfo ?? []) {
            if ((info.empId?.isNotEmpty ?? false) && info.employeeStatus == 'Active') {
              allEmployeeIds.add(info.empId!);
            }
          }
        }
      }
      selectedBranchIds = allEmployeeIds.toSet();
      log('✅ Employees for branch ($selectedBranchId): ${selectedBranchIds.length}');
    } else {
      log('⚠️ Invalid branch or empty data');
    }
  }

  String _formatMs(int ms) {
    final total = Duration(milliseconds: ms);
    final h = total.inHours;
    final m = total.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ─── Controls Row: Branch Dropdown + Team + Only Me ─────────────────────
  Widget _buildControls(BuildContext context) {
    final grade = _singleton.getJWTModel()?.grade ?? '';
    final showBranchDropdown = grade != 'L4' && grade != 'L3';

    return Row(
      children: [
        // ── Branch Dropdown (L0/L1/L2) ──────────────────────────────────
        if (showBranchDropdown) ...[
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) async {
              setState(() {
                _isLoadingBranchData = true;
                // Branch selected → uncheck Team & Only Me
                _filterMode = _FilterMode.branch;
              });
              try {
                _singleton.teamAttendanceDataList.clear();
                selectedBranchIds.clear();
                _singleton.branchID = value;
                await _singleton.getTeamBranchData();
                await extractAllEmployeeIdsForBranch(value);
                _empInfoMap.clear();
                for (var item in _singleton.teamBranchDataList) {
                  for (var emp in item.data?.employees ?? []) {
                    final info = (emp.employeeInfo?.isNotEmpty ?? false)
                        ? emp.employeeInfo!.first
                        : null;
                    final id = info?.empId?.toString() ?? '';
                    if (id.isNotEmpty) {
                      _empInfoMap[id] = {
                        'name': '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim(),
                        'pic': emp.profilePic?.toString(),
                        'designation': info?.designation?.toString(),
                      };
                    }
                  }
                }
                final selectedBranch = _singleton.availableBranches
                    .firstWhere((b) => b.branchId.toString() == value);
                _singleton.branchName = selectedBranch.branchName ?? '';
                if (kDebugMode) {
                  print('🏢 Branch: $value | 👥 IDs: $selectedBranchIds');
                }
                await _fetchActivity();
              } catch (e) {
                log("❌ Branch selection error: $e");
              } finally {
                setState(() => _isLoadingBranchData = false);
              }
            },
            itemBuilder: (_) => _singleton.availableBranches
                .map((b) => PopupMenuItem<String>(
                value: b.branchId, child: Text(b.branchName ?? '---')))
                .toList(),
            child: Container(
              height: 40,
              constraints: const BoxConstraints(maxWidth: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // Highlighted when branch mode is active
                color: _filterMode == _FilterMode.branch
                    ? NasColors.darkBlue
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4))
                ],
              ),
              child: _isLoadingBranchData
                  ? Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _filterMode == _FilterMode.branch
                          ? Colors.white
                          : NasColors.darkBlue),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/site.png',
                      height: 14,
                      width: 14,
                      color: _filterMode == _FilterMode.branch
                          ? Colors.white
                          : null),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _singleton.branchName?.isNotEmpty == true
                          ? _singleton.branchName!
                          : (_singleton.branchDataList.isNotEmpty
                          ? _singleton.branchDataList.first.data
                          ?.branch?.branchName ??
                          ''
                          : ''),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: _filterMode == _FilterMode.branch
                              ? Colors.white
                              : Colors.black,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down,
                      color: _filterMode == _FilterMode.branch
                          ? Colors.white
                          : Colors.black,
                      size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],

        // ── Team chip ────────────────────────────────────────────────────
        _FilterChip(
          label: AppLocalizations.of(context)!.teams,
          selected: _filterMode == _FilterMode.team,
          onTap: () async {
            if (_filterMode != _FilterMode.team) {
              setState(() => _filterMode = _FilterMode.team);
              await _fetchActivity();
            }
          },
        ),
        const SizedBox(width: 8),

        // ── Only Me chip ─────────────────────────────────────────────────
        _FilterChip(
          label: AppLocalizations.of(context)!.onlyMe,
          selected: _filterMode == _FilterMode.onlyMe,
          onTap: () async {
            if (_filterMode != _FilterMode.onlyMe) {
              setState(() => _filterMode = _FilterMode.onlyMe);
              await _fetchActivity();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final grade = _singleton.getJWTModel()?.grade ?? '';

    // L4: show nothing; L3: show Team + Only Me (no branch); L0/L1/L2: show all three
    final showControls = grade != 'L4';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────────────
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
                    AppLocalizations.of(context)!.userActivity,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Calendar date range picker
                IconButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 2),
                      lastDate: now,
                      initialDateRange: DateTimeRange(
                          start: now.subtract(const Duration(days: 7)), end: now),
                      builder: (ctx, child) => Theme(
                        data: ThemeData.light().copyWith(
                          scaffoldBackgroundColor: Colors.white,
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: NasColors.darkBlue)),
                          colorScheme: ColorScheme.light(
                              primary: NasColors.darkBlue,
                              onPrimary: Colors.white,
                              secondaryContainer: NasColors.icons),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                        isDateRangeSelected = true;
                        _initDates(start: picked.start, end: picked.end);
                      });
                      await _fetchActivity();
                    }
                  },
                  icon: Icon(Icons.date_range, color: NasColors.darkBlue, size: 30),
                ),
              ],
            ),

            // ─── Date Strip ──────────────────────────────────────────────
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (ctx, i) {
                  final date = _dates[i];
                  final selected = _selectedDateIndex == i;
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _selectedDateIndex = i;
                        _selectedDate = date;
                        _startDate = date;
                        _endDate = date;
                        isDateRangeSelected = false;
                      });
                      await _fetchActivity();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected ? NasColors.darkBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : Colors.grey.shade600),
                          ),
                          Text(
                            _dayLabel(date),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─── Controls Row ─────────────────────────────────────────────
            if (showControls) ...[
              const SizedBox(height: 10),
              _buildControls(context),
            ],

            const SizedBox(height: 8),

            // ─── Employee List ────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: NasColors.darkBlue))
                  : _filteredAggregated.isEmpty
                  ? Center(
                child: Text(
                  AppLocalizations.of(context)!.noData,
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 15),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filteredAggregated.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final agg = _filteredAggregated[i];
                  final info = _empInfoMap[agg.empId];
                  final String name = (info?['name']?.isNotEmpty ?? false)
                      ? info!['name']!
                      : agg.empId;
                  final String? picUrl = info?['pic'];
                  final String designation = info?['designation'] ?? '';

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserActivityDetailScreen(
                          empId: agg.empId,
                          empName: name,
                          picUrl: picUrl,
                          designation: designation,
                          records: agg.rawRecords,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                            (picUrl != null && picUrl.isNotEmpty)
                                ? NetworkImage(picUrl)
                                : null,
                            child: (picUrl == null || picUrl.isEmpty)
                                ? Image.asset(
                              'images/avatar.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: Colors.grey.shade500),
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(children: [
                                      Icon(Icons.circle,
                                          size: 9,
                                          color: agg.isOnline
                                              ? const Color(0xFF00C48C)
                                              : Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        agg.isOnline
                                            ? AppLocalizations.of(context)!.online
                                            : AppLocalizations.of(context)!.offline,
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: agg.isOnline
                                                ? const Color(0xFF00C48C)
                                                : Colors.grey),
                                      ),
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  agg.empId,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                                if (designation.isNotEmpty)
                                  Text(
                                    designation,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 13,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatMs(agg.totalActiveMs),
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.activeTime,
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: agg.score / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            NasColors.darkBlue),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${agg.score}%',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: NasColors.darkBlue),
                                  ),
                                ]),
                                Text(
                                  AppLocalizations.of(context)!.productivityScore,
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ─── Reusable filter chip widget ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NasColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : NasColors.darkBlue,
                  width: 2,
                ),
                color: selected ? Colors.white : Colors.transparent,
              ),
              child: selected
                  ? Center(
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NasColors.darkBlue,
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}