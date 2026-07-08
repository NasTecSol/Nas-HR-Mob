import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/screens/team_attendance_detail_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:http/http.dart' as http;
import '../request_controller/branch_model.dart';
import '../widgets/loader.dart';

class TeamAttendanceScreen extends StatefulWidget {
  const TeamAttendanceScreen({super.key});

  @override
  State<TeamAttendanceScreen> createState() => _TeamAttendanceScreenState();
}

class _TeamAttendanceScreenState extends State<TeamAttendanceScreen> with SingleTickerProviderStateMixin {


  /// ─────────────────────── Singleton & Data ────────────────────────
  final SingletonClass _singleton = SingletonClass();
  /// ─────────────────────── State Flags ─────────────────────────────
  bool _isChecked = false;
  bool _isTeamChecked = true;
  bool _isInitialLoading = true;
  bool _isLoadingBranchData = false;
  bool _isOnlyMeLoading = false;
  bool isSearching = false;
  bool isDateRangeSelected = false;
  bool showDropdown = false;
  bool showTeamCheckbox = false;
  bool showOnlyMeCheckbox = false;
  /// ─────────────────────── Filter State ────────────────────────────
  int _selectedOptionIndex = 0;
  String? selectedEmployeeId;
  Set<String> selectedBranchIds = {};
  DateTime? _selectedDate;
  int? _selectedDateIndex;
  DateTime? _startDate;
  DateTime? _endDate;
  late List<DateTime> _dates;
  /// ─────────────────────── Data ────────────────────────────────────
  late String reportingManagerId;
  late List<Teams> filteredUnderTeams;
  List<TeamAttendanceData> filteredAttendanceDataList = [];

  /// ─────────────────────── Controllers ─────────────────────────────
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;

  /// ══════════════════════════════════════════════════════════════════
  ///  LIFECYCLE
  /// ══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _setDefaultDates();
    _initDates(start: _startDate!, end: _endDate!);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialize();
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// ══════════════════════════════════════════════════════════════════
  /// INIT
  /// ══════════════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    try {
      _teamCheck();
      if (_singleton.getJWTModel()?.grade == 'L4') _isChecked = true;

      reportingManagerId = _singleton.getJWTModel()?.empId ?? '';
      log("🟢 Reporting Manager ID: $reportingManagerId");

      await _singleton.getTeamBranchData();
      await _singleton.getBranchData();

      final branchDataList = _singleton.branchDataList;
      final filteredData = _getFilteredTeams(branchDataList, reportingManagerId);
      filteredUnderTeams = filteredData['underTeams']!;
      log("🔍 Filtered ${filteredUnderTeams.length} underTeams");

      await _loadData();
      _fadeController.forward();
    } catch (e, s) {
      log("❌ initState error: $e\n$s");
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  DATE HELPERS
  /// ══════════════════════════════════════════════════════════════════

  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  void _initDates({required DateTime start, required DateTime end}) {
    _dates = [];
    final today = DateTime.now();
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      _dates.add(d);
    }
    _selectedDateIndex = _dates.indexWhere(
          (d) => d.year == today.year && d.month == today.month && d.day == today.day,
    );
    if (_selectedDateIndex != -1) _selectedDate = today;
  }

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients &&
        _selectedDateIndex != null &&
        _selectedDateIndex! >= 0) {
      _scrollController.animateTo(
        _selectedDateIndex! * 60.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  ACCESS LOGIC
  /// ══════════════════════════════════════════════════════════════════

  void _teamCheck() {
    final manageTimeModule =
    _singleton.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => e.title == "ManageTime" || e.name == "ManageTime");
    final attendanceHistoryMenu = manageTimeModule.subMenu!.firstWhere(
          (s) => s.title == "Attendance History" || s.name == "Attendance History",
    );
    final access = attendanceHistoryMenu.accessLevel;
    final companies = access?.companies ?? [];
    final hasCompanies = companies.isNotEmpty &&
        companies.any((c) => c.companyId != null && c.companyId!.isNotEmpty);
    final hasBranches = hasCompanies &&
        companies.any((c) =>
        c.branches != null &&
            c.branches!.any((b) => b.branchId != null && b.branchId!.isNotEmpty));
    final teamEnabled = access?.team == true;
    final hasBranchId =
        _singleton.branchID != null && _singleton.branchID!.isNotEmpty;

    // Reset flags
    showDropdown = showTeamCheckbox = showOnlyMeCheckbox = false;
    _isTeamChecked = _isChecked = false;

    if (hasCompanies && hasBranches && teamEnabled) {
      showDropdown = showTeamCheckbox = showOnlyMeCheckbox = true;
      if (hasBranchId) {
        extractAllEmployeeIdsForBranch(_singleton.branchID);
      } else {
        _isTeamChecked = true;
      }
    } else if (hasCompanies && hasBranches && !teamEnabled) {
      showDropdown = showOnlyMeCheckbox = true;
      if (!hasBranchId) _isChecked = true;
      else extractAllEmployeeIdsForBranch(_singleton.branchID);
    } else if (!hasCompanies && !hasBranches && teamEnabled) {
      showTeamCheckbox = showOnlyMeCheckbox = true;
      _isTeamChecked = true;
    } else {
      showOnlyMeCheckbox = true;
      _isChecked = true;
    }

    log('✅ _teamCheck → Dropdown:$showDropdown | Team:$showTeamCheckbox | '
        'OnlyMe:$showOnlyMeCheckbox | isTeam:$_isTeamChecked | isMe:$_isChecked');
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  BRANCH / TEAM DATA
  /// ══════════════════════════════════════════════════════════════════

  Future<void> extractAllEmployeeIdsForBranch(String? branchId) async {
    await _singleton.getTeamBranchData();
    selectedBranchIds.clear();

    if (branchId == null || branchId.isEmpty || _singleton.teamBranchDataList.isEmpty) {
      log('⚠️ Invalid branch or empty data');
      return;
    }

    final ids = <String>[];
    for (final branchItem in _singleton.teamBranchDataList) {
      final branchData = branchItem.data;
      if (branchData?.employees?.first.branchId != branchId) continue;
      for (final employee in branchData!.employees!) {
        if (employee.id != null &&
            employee.id!.isNotEmpty &&
            employee.employeeInfo?.first.employeeStatus == 'Active') {
          ids.add(employee.id!);
        }
      }
    }
    selectedBranchIds = ids.toSet();
    log('✅ Employees for branch ($branchId): ${selectedBranchIds.length}');
  }

  Map<String, List<Teams>> _getFilteredTeams(
      List<BranchData> branchDataList, String managerId) {
    final underTeams = <Teams>[];
    for (final branchData in branchDataList) {
      for (final deptDetails in branchData.data?.branch?.departmentDetails ?? []) {
        for (final dept in deptDetails.departments ?? []) {
          for (final team in dept.teams ?? []) {
            for (final supervisor in dept.supervisors ?? []) {
              if (supervisor.empId == managerId && supervisor.teamId == team.teamId) {
                underTeams.add(team);
              }
            }
          }
        }
      }
    }
    return {'underTeams': underTeams};
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  DATA LOADING  ← FIX: no more FutureBuilder re-fetching
  /// ══════════════════════════════════════════════════════════════════

  Future<void> _loadData() async {
    log("📥 Loading attendance data…");
    await _fetchTeamAttendanceData(startDate: _startDate!, endDate: _endDate!);
    _applyFilters();
  }

  Future<void> _fetchTeamAttendanceData({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10000,
    int page = 0,
  }) async {
    log("📡 Fetching attendance data…");
    final grade = _singleton.getJWTModel()?.grade;
    Set<String> employeeIds = {};

    final isLowerGrade = ['L0', 'L1', 'L2', 'L3'].contains(grade);

    if (isLowerGrade) {
      if (!_isChecked && _isTeamChecked &&
          (_singleton.branchID == null || _singleton.branchID!.isEmpty)) {
        // Team mode
        for (final team in filteredUnderTeams) {
          for (final member in team.teamData ?? []) {
            if (member.employeeId?.isNotEmpty == true) {
              employeeIds.add(member.employeeId!);
            }
          }
        }
      } else if (!_isChecked && !_isTeamChecked &&
          _singleton.branchID != null && _singleton.branchID!.isNotEmpty) {
        // Branch mode
        employeeIds = selectedBranchIds.isNotEmpty ? selectedBranchIds : {};
      } else {
        // Only-me mode
        final userId = _singleton.getJWTModel()?.employeeId;
        if (userId != null) employeeIds.add(userId);
      }
    } else {
      final userId = _singleton.getJWTModel()?.employeeId;
      if (userId != null) employeeIds.add(userId);
    }

    if (employeeIds.isEmpty) {
      log("❌ No employee IDs. Clearing data.");
      if (mounted) setState(() => filteredAttendanceDataList.clear());
      return;
    }

    final ids = employeeIds.join(',');
    final fmt = (DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}-${d.year}';

    final uri = Uri.parse(
      '${_singleton.baseURL}/c-emp-attendance/getDataByEmployeeId'
          '/$ids/${fmt(endDate)}/${fmt(startDate)}?limit=$limit&page=$page',
    );

    log("🌐 URL: $uri");

    try {
      final response = await http.get(uri, headers: _singleton.getHeaders());
      log("📨 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final attendance = TeamAttendanceModel.fromJson(body);
        _singleton.teamAttendanceDataList
          ..clear()
          ..add(attendance);
        log("✅ Fetched ${attendance.data?.data?.length ?? 0} records");
      } else {
        log("❌ API error ${response.statusCode}");
      }
    } catch (e) {
      log("❌ Network error: $e");
    }
  }

  /// Central filter — runs after any state change
  void _applyFilters() {
    if (_singleton.teamAttendanceDataList.isEmpty) {
      if (mounted) setState(() => filteredAttendanceDataList.clear());
      return;
    }

    List<TeamAttendanceData> all =
        _singleton.teamAttendanceDataList.first.data?.data ?? [];

    // Employee filter
    if (selectedEmployeeId != null) {
      all = all.where((e) => e.employeeId == selectedEmployeeId).toList();
    }

    // Date filter (only if not in date-range mode)
    if (!isDateRangeSelected && _selectedDate != null) {
      all = all.where((a) {
        final d = DateTime.tryParse(a.date ?? '');
        return d != null &&
            d.year == _selectedDate!.year &&
            d.month == _selectedDate!.month &&
            d.day == _selectedDate!.day;
      }).toList();
    }

    if (mounted) setState(() => filteredAttendanceDataList = all);
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  UI HELPERS
  /// ══════════════════════════════════════════════════════════════════

  String _getDayOfWeek(BuildContext context, DateTime date) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    const en = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const ar = ["الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد"];
    return isAr ? ar[date.weekday - 1] : en[date.weekday - 1];
  }

  String _formatDay(BuildContext context, DateTime date) {
    return Localizations.localeOf(context).languageCode == 'ar'
        ? _toArabicDigits(date.day)
        : date.day.toString();
  }

  String _toArabicDigits(int n) {
    const d = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  String _formatDate(String raw, BuildContext context) {
    try {
      final dt = DateTime.parse(raw);
      return Localizations.localeOf(context).languageCode == 'ar'
          ? DateFormat('dd-MM-yyyy', 'ar').format(dt)
          : DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return '--';
    }
  }

  String _formatMinutes(dynamic minutes) {
    if (minutes == null) return '---';
    try {
      final d = minutes is int ? minutes.toDouble() : double.parse(minutes.toString());
      return d.ceil().toString();
    } catch (_) {
      return '---';
    }
  }

  bool _matchesStatusFilter(TeamAttendanceData a) {
    final status = (a.status ?? '').toLowerCase().replaceAll('-', ' ');
    switch (_selectedOptionIndex) {
      case 0: return true;
      case 1: return status == 'present';
      case 2: return status == 'absent';
      case 3: return ['on leave', 'leave', 'annualleave'].contains(status);
      case 4: return ['missing checkin/out', 'missing checkin', 'missing checkout', 'pending'].contains(status);
      case 5: return (a.lateMinutes ?? 0) > 0;
      case 6: return (a.earlyCheckOut ?? 0) > 0;
      default: return false;
    }
  }

  bool _matchesSearch(TeamAttendanceData a) {
    if (!isSearching || searchController.text.isEmpty) return true;
    final q = searchController.text.toLowerCase();
    return (a.name?.toLowerCase().contains(q) ?? false) ||
        (a.empId?.toLowerCase().contains(q) ?? false);
  }

  int _getCountForOption(int index) {
    if (filteredAttendanceDataList.isEmpty) return 0;
    final prev = _selectedOptionIndex;
    _selectedOptionIndex = index;
    final count = filteredAttendanceDataList.where(_matchesStatusFilter).length;
    _selectedOptionIndex = prev;
    return count;
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  BUILD
  /// ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildFilterChips(context),
            _buildDateStrip(context),
            const SizedBox(height: 8),
            _buildActionRow(context),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  /// ──────────────────────── App Bar ────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.attendanceHistory,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NasColors.darkBlue,
            ),
          ),
          const Spacer(),
          _circleButton(
            icon: Icons.calendar_month_rounded,
            onTap: () => _pickDateRange(context),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: NasColors.darkBlue, size: 20),
      ),
    );
  }

  /// ──────────────────────── Date Range Picker ───────────────────────

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange:
      DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: NasColors.darkBlue),
          ),
          colorScheme: ColorScheme.light(
            primary: NasColors.darkBlue,
            onPrimary: Colors.white,
            secondaryContainer: NasColors.icons,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        isDateRangeSelected = true;
      });
      _initDates(start: picked.start, end: picked.end);
      await _loadData();
      _scrollToSelectedDate();
    }
  }

  Color _chipAccentColor(int index) {
    switch (index) {
      case 0: return NasColors.darkBlue;
      case 1: return NasColors.completed;
      case 2: return NasColors.red;
      case 3: return NasColors.darkBlue;
      case 4: return NasColors.pending;
      case 5: return NasColors.pending;
      case 6: return NasColors.onTime;
      default: return NasColors.darkBlue;
    }
  }

  Widget _buildFilterChips(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = [
      (l.all, 0),
      (l.present, 1),
      (l.absent, 2),
      (l.leave, 3),
      (l.missingCheckInOut, 4),
      (l.late, 5),
      (l.earlyCheckOut, 6),
    ];
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        itemBuilder: (ctx, i) {
          final (label, idx) = options[i];
          return _FilterChip(
            label: label,
            count: _getCountForOption(idx),
            selected: _selectedOptionIndex == idx,
            accentColor: _chipAccentColor(idx), // ← added
            onTap: () {
              setState(() => _selectedOptionIndex = idx);
              _applyFilters();
            },
          );
        },
      ),
    );
  }

  /// ──────────────────────── Date Strip ─────────────────────────────

  Widget _buildDateStrip(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: _dates.length,
        itemBuilder: (ctx, i) {
          final date = _dates[i];
          final selected = _selectedDateIndex == i;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = i;
                _selectedDate = date;
                isDateRangeSelected = false;
              });
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? NasColors.darkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [BoxShadow(color: NasColors.darkBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDay(context, date),
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getDayOfWeek(context, date),
                    style: GoogleFonts.inter(
                      fontSize: 11,
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

  // ──────────────────────── Action Row ─────────────────────────────

  Widget _buildActionRow(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Recompute visibility from access settings
    final manageTimeModule =
    _singleton.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => e.title == "ManageTime" || e.name == "ManageTime");
    final attendanceHistoryMenu = manageTimeModule.subMenu!.firstWhere(
          (s) => s.title == "Attendance History" || s.name == "Attendance History",
    );
    final access = attendanceHistoryMenu.accessLevel!;
    final companies = access.companies ?? [];
    final hasCompanies = companies.isNotEmpty &&
        companies.any((c) => c.companyId != null && c.companyId!.isNotEmpty);
    final hasBranches = hasCompanies &&
        companies.any((c) =>
        c.branches != null &&
            c.branches!.any((b) => b.branchId != null && b.branchId!.isNotEmpty));
    final teamEnabled = access.team == true;

    if (hasCompanies && hasBranches && teamEnabled) {
      showDropdown = showTeamCheckbox = showOnlyMeCheckbox = true;
    } else if (hasCompanies && hasBranches) {
      showDropdown = showOnlyMeCheckbox = true;
    } else if (teamEnabled) {
      showTeamCheckbox = showOnlyMeCheckbox = true;
    } else {
      showOnlyMeCheckbox = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Search field (expanded when active)
          if (isSearching) ...[
            Expanded(child: _buildSearchField(l)),
            const SizedBox(width: 4),
          ] else ...[
            if (!_isChecked && showDropdown) _buildBranchDropdown(context),
            const Spacer(),
            if (showTeamCheckbox && !_isChecked)
              _buildLabeledCheckbox(
                label: l.teams,
                value: _isTeamChecked,
                enabled: _singleton.branchID != null,
                onChanged: _onTeamCheckboxChanged,
              ),
            if (showOnlyMeCheckbox)
              _isOnlyMeLoading
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: NasColors.darkBlue),
                ),
              )
                  : _buildLabeledCheckbox(
                label: l.onlyMe,
                value: _isChecked,
                onChanged: (v) {
                  setState(() {
                    _isChecked = v ?? false;
                    _isOnlyMeLoading = true;
                  });
                  _handleOnlyMeChange(v ?? false);
                },
              ),
          ],
          // Search toggle
          _circleButton(
            icon: isSearching ? Icons.close_rounded : Icons.search_rounded,
            onTap: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  ///Search Bar
  Widget _buildSearchField(AppLocalizations l) {
    return TextField(
      controller: searchController,
      autofocus: true,
      cursorColor: Colors.grey,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: l.search,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: _onBranchSelected,
        itemBuilder: (_) => _singleton.availableBranches
            .map((b) => PopupMenuItem<String>(
          value: b.branchId,
          child: Text(b.branchName ?? '---',
              style: GoogleFonts.inter(fontSize: 14)),
        ))
            .toList(),
        child: Container(
          height: 44,
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ],
          ),
          child: _isLoadingBranchData
              ? Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: NasColors.darkBlue),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('images/site.png', height: 14, width: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _singleton.branchName?.isNotEmpty == true
                      ? _singleton.branchName!
                      : (_singleton.branchDataList.isNotEmpty
                      ? _singleton.branchDataList.first.data?.branch?.branchName ?? '---'
                      : '---'),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool enabled = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              activeColor: NasColors.onTime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: enabled ? onChanged : null,
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled ? NasColors.darkBlue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ──────────────────────── Checkbox handlers ───────────────────────

  Future<void> _onTeamCheckboxChanged(bool? value) async {
    try {
      _singleton.teamAttendanceDataList.clear();
      _isChecked = false;
      _isTeamChecked = value ?? false;
      selectedBranchIds.clear();

      // Recompute access
      final manageTimeModule =
      _singleton.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
          .firstWhere((e) => e.title == "ManageTime" || e.name == "ManageTime");
      final menu = manageTimeModule.subMenu!.firstWhere(
            (s) => s.title == "Attendance History" || s.name == "Attendance History",
      );
      final access = menu.accessLevel!;
      final companies = access.companies ?? [];
      final hasCompanies = companies.isNotEmpty &&
          companies.any((c) => c.companyId?.isNotEmpty == true);
      final hasBranches = hasCompanies &&
          companies.any((c) =>
          c.branches?.any((b) => b.branchId?.isNotEmpty == true) == true);

      if (hasCompanies && hasBranches && access.team == true) {
        _singleton.branchID = null;
        _singleton.branchName = null;
      }
      await _singleton.getTeamBranchData();
      await _loadData();
    } catch (e) {
      log("❌ Team checkbox error: $e");
    } finally {
      if (mounted) setState(() => isSearching = false);
    }
  }

  Future<void> _handleOnlyMeChange(bool isChecked) async {
    try {
      _singleton.teamAttendanceDataList.clear();
      selectedBranchIds.clear();

      if (!isChecked) {
        // Back to branch mode — pick first available branch
        if (_singleton.branchDataList.isNotEmpty) {
          final first = _singleton.branchDataList.first;
          _singleton.branchID = first.data?.branch?.id;
          _singleton.branchName = first.data?.branch?.branchName;
          await extractAllEmployeeIdsForBranch(_singleton.branchID);
        }
        _isTeamChecked = false;
      } else {
        _singleton.branchID = null;
        _singleton.branchName = null;
        _isTeamChecked = false;
      }

      _initDates(start: _startDate!, end: _endDate!);
      await Future.wait([_singleton.getTeamBranchData(), _loadData()]);
    } catch (e) {
      log("❌ Only-me change error: $e");
    } finally {
      if (mounted) setState(() => _isOnlyMeLoading = false);
    }
  }

  Future<void> _onBranchSelected(String value) async {
    setState(() => _isLoadingBranchData = true);
    try {
      _singleton.teamAttendanceDataList.clear();
      selectedBranchIds.clear();
      _singleton.branchID = value;

      await _singleton.getTeamBranchData();
      await extractAllEmployeeIdsForBranch(value);

      final branch = _singleton.availableBranches
          .firstWhere((b) => b.branchId.toString() == value);
      _singleton.branchName = branch.branchName ?? '';

      _isTeamChecked = false;
      _isChecked = false;
      await _loadData();
    } catch (e) {
      log("❌ Branch selection error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingBranchData = false);
    }
  }

  /// ──────────────────────── Body / List ────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (_isLoadingBranchData || _isInitialLoading) return const Loader();

    // Apply status + search filter for display
    final visible = filteredAttendanceDataList
        .where((a) => _matchesStatusFilter(a) && _matchesSearch(a))
        .toList();

    if (visible.isEmpty) return _buildEmptyState(context);

    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: visible.length,
        itemBuilder: (ctx, i) => _AttendanceCard(
          attendance: visible[i],
          singleton: _singleton,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TeamAttendanceDetailScreen(attendanceData: visible[i]),
            ),
          ),
          context: context,
          formatDate: _formatDate,
          formatMinutes: _formatMinutes,
          translateStatus: _translateStatus,
          translateSecondaryStatus: _translateSecondaryStatus,
          getStatusColor: getStatusColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: Lottie.asset('images/empty.json'),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noData,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: NasColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// ══════════════════════════════════════════════════════════════════
  ///  TRANSLATION / COLOR
  /// ══════════════════════════════════════════════════════════════════

  String _translateStatus(String? status, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (status) {
      case 'Absent': return l.absent;
      case 'Present': return l.present;
      case 'Quarterly': return l.quarterly;
      case 'Pending': return l.pending;
      case 'Missing CheckIn/Out': return l.missingCheckInOut;
      case 'On-Leave': return l.onLeaves;
      default: return status ?? l.noData;
    }
  }

  String _translateSecondaryStatus(String? status, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return l.noData;
    // Extended switch
    switch (status) {
      case 'Absent': return l.absent;
      case 'Present': return l.present;
      case 'late': case 'Late': return l.late;
      case 'leave': return l.leave;
      case 'holiday': return l.holiday;
      case 'dayOFF': return l.dayOff;
      case 'training': return l.training;
      case 'absent with approval': return l.absentWithApproval;
      case 'Missing CheckIn/Out': return l.missingCheckInOut;
      case 'Pending': return l.pending;
      case 'No-CheckIn': return l.noCheckIn;
      case 'Late-Penality': return l.latePenality;
      case 'Short-Hours': return l.shortHours;
      case 'Missing-CheckIn': return l.missingCheckIn;
      case 'Missing-CheckOut': return l.missingCheckOut;
      case 'Check-In': return l.checkIn;
      case 'Check-Out': return l.checkOut;
      case 'OOS-In': return l.oosIn;
      case 'OOS-Out': return l.oosOut;
      case 'Early-In': return l.earlyIn;
      case 'Early-Left': return l.earlyLeft;
      case 'OnTime-In': return l.onTimeIn;
      case 'OnTime-Out': return l.onTimeOut;
      case 'Late-In': return l.lateIn;
      case 'Late-Out': return l.lateOut;
      case 'SM-In': return l.smIn;
      case 'SM-Out': return l.smOut;
      case 'Break-In': return l.breakIn;
      case 'Break-Out': return l.breakOut;
      case 'slot': return l.slot;
      case 'Out-Off-Shift': return l.outOffShift;
      case 'Full-Day': return l.fullDay;
      case 'annualLeave': return l.annualLeave;
      default: return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'ontime-in':
      case 'ontime-out': return NasColors.green;
      case 'absent': return NasColors.reds;
      case 'absent with approval':
      case 'pending': return NasColors.yellow;
      case 'early checkout': return NasColors.purple;
      case 'late': return NasColors.amber;
      case 'check-in': return NasColors.violet;
      case 'check-out': return NasColors.fuchsia;
      case 'oos-in':
      case 'oos-out': return NasColors.amber;
      case 'early-in':
      case 'early-out': return NasColors.rose;
      case 'late-in':
      case 'late-out': return NasColors.brightRed;
      case 'sm-in':
      case 'sm-out': return NasColors.indigo;
      case 'break-in':
      case 'break-out': return NasColors.zinc;
      case 'slot': return NasColors.warmGray;
      case 'no-checkin': return NasColors.darkGray;
      case 'on-leave':
      case 'casual leave': return NasColors.blue;
      default: return NasColors.orange;
    }
  }
}

/// ══════════════════════════════════════════════════════════════════════
///  EXTRACTED WIDGETS
/// ══════════════════════════════════════════════════════════════════════

/// Filter chip pill shown in the horizontal options row
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.accentColor,
  });

  Color get _chipBg    => selected ? accentColor : Colors.white;
  Color get _textColor => selected ? Colors.white : accentColor;
  Color get _badgeBg   => selected
      ? Colors.white.withOpacity(0.25)
      : accentColor.withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: accentColor.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accentColor.withOpacity(0.35)
                  : Colors.black.withOpacity(0.06),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor)),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                  color: _badgeBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(count.toString(),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
/// Card widget for each attendance record
// ─────────────────────────────────────────────────────────────────────

class _AttendanceCard extends StatelessWidget {
  final TeamAttendanceData attendance;
  final SingletonClass singleton;
  final VoidCallback onTap;
  final BuildContext context;
  final String Function(String, BuildContext) formatDate;
  final String Function(dynamic) formatMinutes;
  final String Function(String?, BuildContext) translateStatus;
  final String Function(String?, BuildContext) translateSecondaryStatus;
  final Color Function(String) getStatusColor;

  const _AttendanceCard({
    required this.attendance,
    required this.singleton,
    required this.onTap,
    required this.context,
    required this.formatDate,
    required this.formatMinutes,
    required this.translateStatus,
    required this.translateSecondaryStatus,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lateMinutes = int.tryParse(attendance.lateMinutes.toString()) ?? 0;
    final earlyCheckOut = int.tryParse(attendance.earlyCheckOut.toString()) ?? 0;
    final breakTime = formatMinutes(attendance.breakTime);
    final date = formatDate(attendance.date ?? '', context);
    final isOnLeave = attendance.status == "On-Leave";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  _EmpIdBadge(empId: attendance.empId),
                  const Spacer(),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Name + Avatar + Status ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _Avatar(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      attendance.name ?? '---',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (attendance.status != null)
                        _StatusBadge(
                          label: translateStatus(attendance.status, context),
                          color: getStatusColor(attendance.status!),
                          tall: attendance.status == "Missing CheckIn/Out",
                        ),
                      if (attendance.secondaryStatus != null) ...[
                        const SizedBox(height: 4),
                        _StatusBadge(
                          label: translateSecondaryStatus(attendance.secondaryStatus, context),
                          color: getStatusColor(attendance.secondaryStatus!),
                          tall: attendance.secondaryStatus == "Missing CheckIn/Out",
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Shift info (non-leave) ───────────────────────────────
            if (!isOnLeave) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _WorkedHoursRow(attendance: attendance, l: l),
                    const SizedBox(height: 8),
                    _ShiftRow(
                      attendance: attendance,
                      singleton: singleton,
                      breakTime: breakTime,
                      context: context,
                      l: l,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // ── Footer ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: isOnLeave
                  ? _LeaveFooter(attendance: attendance, singleton: singleton, l: l, context: context)
                  : _AttendanceFooter(
                attendance: attendance,
                singleton: singleton,
                lateMinutes: lateMinutes,
                earlyCheckOut: earlyCheckOut,
                l: l,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────── Sub-widgets ─────────────────────────────────────────────────

class _EmpIdBadge extends StatelessWidget {
  final String? empId;
  const _EmpIdBadge({this.empId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: NasColors.darkBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        empId ?? '---',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: NasColors.darkBlue,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipOval(
        child: Image.asset('images/DP.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool tall;

  const _StatusBadge({required this.label, required this.color, this.tall = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 48 : 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _WorkedHoursRow extends StatelessWidget {
  final TeamAttendanceData attendance;
  final AppLocalizations l;

  const _WorkedHoursRow({required this.attendance, required this.l});

  @override
  Widget build(BuildContext context) {
    final worked = attendance.totalHoursWorked ?? 0;
    final total = 11 * 60;
    final progress = (worked / total).clamp(0.0, 1.0);

    return Row(
      children: [
        Text(l.shifts,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${worked ~/ 60}${l.h} ${worked % 60}${l.m}",
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 80,
                height: 6,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShiftRow extends StatelessWidget {
  final TeamAttendanceData attendance;
  final SingletonClass singleton;
  final String breakTime;
  final BuildContext context;
  final AppLocalizations l;

  const _ShiftRow({
    required this.attendance,
    required this.singleton,
    required this.breakTime,
    required this.context,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final shift = attendance.shiftInfo;
    Widget shiftDetail = const SizedBox.shrink();

    if (shift != null) {
      if (shift.shiftType == 'fullTime') {
        shiftDetail = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shift.timefrom != null && shift.timeTo != null)
              Text(
                "${singleton.formatCheckInTime(shift.timefrom.toString(), context)} - "
                    "${singleton.formatCheckInTime(shift.timeTo.toString(), context)}",
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            if (shift.shiftName != null)
              Text(shift.shiftName!,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          ],
        );
      } else if (shift.shiftType == 'flexibleShift' && shift.shiftName != null) {
        shiftDetail = Text(shift.shiftName!,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600));
      } else if (shift.shiftType == 'timeTableShift' &&
          attendance.slots != null) {
        shiftDetail = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: attendance.slots!.take(2).map((slot) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    "${singleton.formatCheckInTime(slot.slotStart, context)} - "
                        "${singleton.formatCheckInTime(slot.slotEnd, context)}",
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: shiftDetail),
        Row(
          children: [
            Text(
              "$breakTime ${l.minutes}",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade400),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.coffee_rounded, size: 16, color: Colors.brown),
          ],
        ),
      ],
    );
  }
}

class _AttendanceFooter extends StatelessWidget {
  final TeamAttendanceData attendance;
  final SingletonClass singleton;
  final int lateMinutes;
  final int earlyCheckOut;
  final AppLocalizations l;
  final BuildContext context;

  const _AttendanceFooter({
    required this.attendance,
    required this.singleton,
    required this.lateMinutes,
    required this.earlyCheckOut,
    required this.l,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final isLate = lateMinutes > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FooterCol(
          label: l.checkIn,
          value: singleton.formatCheckInTime(attendance.clockInTime, context),
          valueColor: isLate ? NasColors.pending : Colors.black87,
        ),
        _FooterCol(
          label: l.checkOut,
          value: singleton.formatCheckInTime(attendance.clockOutTime, context),
          valueColor: isLate ? NasColors.pending : Colors.black87,
        ),
        _FooterCol(
          label: l.late,
          value: "${lateMinutes ~/ 60}${l.h} ${lateMinutes % 60}${l.m}",
          valueColor: NasColors.pending,
        ),
        _FooterCol(
          label: l.earlyLeft,
          value: "${earlyCheckOut ~/ 60}${l.h} ${earlyCheckOut % 60}${l.m}",
          valueColor: NasColors.onTime,
        ),
      ],
    );
  }
}

class _LeaveFooter extends StatelessWidget {
  final TeamAttendanceData attendance;
  final SingletonClass singleton;
  final AppLocalizations l;
  final BuildContext context;

  const _LeaveFooter({
    required this.attendance,
    required this.singleton,
    required this.l,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final info = attendance.leaveDetails?.requestInfo;
    final reqData = info?.requestData?.first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FooterCol(label: l.leaveType, value: info?.subType ?? '---'),
        _FooterCol(
          label: l.startDate,
          value: singleton.formatDate2("${reqData?.startDate}", context),
        ),
        _FooterCol(
          label: l.endDate,
          value: singleton.formatDate2("${reqData?.endDate}", context),
        ),
        _FooterCol(label: l.duration, value: "${reqData?.duration ?? '---'}"),
      ],
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _FooterCol({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}