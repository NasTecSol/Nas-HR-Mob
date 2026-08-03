import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:http/http.dart' as http;
import '../request_controller/branch_model.dart';
import '../request_controller/team_clocking_model.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'dart:math' as math;

import '../widgets/loader.dart';

class TeamClocking extends StatefulWidget {
  const TeamClocking({super.key});

  @override
  State<TeamClocking> createState() => _TeamClockingState();
}

class _TeamClockingState extends State<TeamClocking>
    with SingleTickerProviderStateMixin {
  SingletonClass singletonClass = SingletonClass();
  late String reportingManagerId;
  List<Teams> filteredUnderTeams = [];
  List<TeamClockingData> filteredClockingDataList = [];
  String? selectedEmployeeId;
  bool _isTeamChecked = true;
  Set<String> selectedBranchIds = {};
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedDate;
  int? _selectedDateIndex;
  late List<DateTime> _dates;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool showDropdown = false;
  bool _isInitialLoading = true;
  bool _isLoadingBranchData = false;
  bool showTeamCheckbox = false;
  final ScrollController _scrollController = ScrollController();
  bool isDateRangeSelected = false;
  late AnimationController _fadeController;

  // ══════════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _isInitialLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _teamCheck();
        reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
        log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
        List<BranchData> branchDataList = singletonClass.branchDataList;
        var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
        filteredUnderTeams = filteredData['underTeams']!;
        log("🔍 Filtered ${filteredUnderTeams.length} underTeams");
        await loadData();
        if (mounted) _fadeController.forward();
      } catch (e, s) {
        log("❌ initState error: $e\n$s");
      } finally {
        if (mounted) setState(() => _isInitialLoading = false);
      }
    });
    final today = DateTime.now();
    _dates = List.generate(today.day, (index) {
      return DateTime(today.year, today.month, index + 1);
    });
    _setDefaultDates();
    _initDates(start: _startDate!, end: _endDate!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients && _selectedDateIndex! >= 0) {
      _scrollController.animateTo(
        _selectedDateIndex! * 60,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  ACCESS LOGIC
  // ══════════════════════════════════════════════════════════════════

  void _teamCheck() {
    /// Safely find the dashboard module
    final manageTimeModule = singletonClass
        .roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere(
            (e) => (e.title == "ManageTime" || e.name == "ManageTime"));
    final biometricMenu = manageTimeModule.subMenu!.firstWhere(
      (submenu) =>
          submenu.title == "Biometric Checkin`s" ||
          submenu.name == "Biometric Checkin`s",
    );

    /// Default flags
    showDropdown = false;
    showTeamCheckbox = false;
    _isTeamChecked = false;

    final access = biometricMenu.accessLevel;
    final companies = access?.companies ?? [];

    final hasCompanies = companies.isNotEmpty &&
        companies.any((c) =>
            c.companyId != null &&
            c.companyId!.isNotEmpty &&
            c.companyId != "");
    final hasBranches = hasCompanies &&
        companies.any((c) =>
            c.branches != null &&
            c.branches!.isNotEmpty &&
            c.branches!.any(
                (b) => b.branchId != null && b.branchId!.isNotEmpty && b.branchId != ""));
    final teamEnabled = access!.team == true;

    /// 🧩 CASE 1: Companies + branches + team == true
    if (hasCompanies && hasBranches && teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = true;
      if (singletonClass.branchID != null &&
          singletonClass.branchID!.isNotEmpty) {
        _isTeamChecked = false;
        extractAllEmployeeIdsForBranch(singletonClass.branchID);
        loadData();
      } else {
        _isTeamChecked = true;
      }
    }

    /// 🧩 CASE 2: Companies + branches + team == false
    else if (hasCompanies && hasBranches && !teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = false;
      _isTeamChecked = false;
      extractAllEmployeeIdsForBranch(singletonClass.branchID);
      loadData();
    }

    /// 🧩 CASE 3: No companies + no branches + team == true
    else if (!hasCompanies && !hasBranches && teamEnabled) {
      showDropdown = false;
      showTeamCheckbox = true;
      _isTeamChecked = true;
      extractAllEmployeeIdsForBranch(singletonClass.getJWTModel()?.branchId);
      loadData();
    }

    /// 🧩 CASE 4: No companies + no branches + team == false
    else {
      showDropdown = false;
      showTeamCheckbox = false;
      _isTeamChecked = false;
    }
  }

  void _extractTeams() {
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredUnderTeams = filteredData['underTeams']!;
    log("🔍 Filtered ${filteredUnderTeams.length} underTeams");
  }

  Future<void> extractAllEmployeeIdsForBranch(String? selectedBranchId) async {
    await singletonClass.getTeamBranchData();
    List<String> allEmployeeIds = [];
    selectedBranchIds.clear();

    if (selectedBranchId != null &&
        selectedBranchId.isNotEmpty &&
        singletonClass.teamBranchDataList.isNotEmpty) {
      for (var branchItem in singletonClass.teamBranchDataList) {
        final branchData = branchItem.data;
        if (branchData != null && branchData.employees != null) {
          for (var employee in branchData.employees!) {
            final employeeId = employee.id;
            if (employeeId != null &&
                employeeId.isNotEmpty &&
                employee.employeeInfo!.first.employeeStatus == 'Active') {
              allEmployeeIds.add(employeeId);
              selectedBranchIds.clear();
            }
          }
        }
      }
      selectedBranchIds = allEmployeeIds.toSet();
      loadData();
      if (kDebugMode) {
        debugPrint('✅ Total Employees Found: ${allEmployeeIds.length}');
        debugPrint('🔍 Unique Employee IDs: $selectedBranchIds');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ No valid branch ID or empty teamBranchDataList');
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  DATE HELPERS
  // ══════════════════════════════════════════════════════════════════

  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    log("📆 Default Date Range: $_startDate to $_endDate");
  }

  void _initDates({required DateTime start, required DateTime end}) {
    _dates.clear();
    final today = DateTime.now();
    for (var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      _dates.add(date);
    }
    _selectedDateIndex = _dates.indexWhere((d) =>
        d.year == today.year &&
        d.month == today.month &&
        d.day == today.day);
    if (_selectedDateIndex != -1) _selectedDate = today;
    log("📅 Generated ${_dates.length} dates");
    log("✅ Auto-selected today: $_selectedDate");
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;
    log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
    log("🔍 User grade: $userGrade");

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails
          in branchData.data?.branch!.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          log("🏢 Department: ${department.departmentName}");
          for (var supervisor in department.supervisors ?? []) {
            log("👨‍💼 Supervisor: ${supervisor.empId}, Team ID: ${supervisor.teamId}");
          }
          for (var team in department.teams ?? []) {
            log("🧑‍🤝‍🧑 Team: ${team.teamId}");
            for (var supervisor in department.supervisors ?? []) {
              if (supervisor.empId == reportingManagerId &&
                  supervisor.teamId == team.teamId) {
                log("✅ Match found — Supervisor: ${supervisor.empId}, Team: ${team.teamId}");
                underTeams.add(team);
              }
            }
          }
        }
      }
    }
    log("🔍 Filtered ${underTeams.length} underTeams");
    return {'underTeams': underTeams};
  }

  Future<void> loadData() async {
    log("📥 Starting data load...");
    if (selectedBranchIds.isEmpty && filteredUnderTeams.isEmpty) {
      debugPrint("[log] ⚠️ No employee IDs found to fetch clocking data");
      if (mounted) setState(() => _isInitialLoading = false);
      return;
    }
    await getTeamClockingAPI(startDate: _startDate!, endDate: _endDate!);
    filterAttendanceData(); // handles setState + fade animation
  }

  void filterAttendanceData() {
    if (singletonClass.teamClockingDataList.isEmpty ||
        singletonClass.teamClockingDataList.first.data == null ||
        singletonClass.teamClockingDataList.first.data!.isEmpty) {
      debugPrint("[log] ⚠️ No data to filter, skipping.");
      if (mounted) setState(() => filteredClockingDataList = []);
      return;
    }

    List<TeamClockingData> all =
        singletonClass.teamClockingDataList.first.data!;

    // Employee filter
    if (selectedEmployeeId != null) {
      all = all.where((e) => e.employeeId == selectedEmployeeId).toList();
    }

    // Date filter — only when a single date is selected (not a range)
    if (!isDateRangeSelected && _selectedDate != null) {
      all = all.where((item) {
        // Prefer the dedicated date field; fall back to updatedAt / createdAt
        final raw = item.date ?? item.updatedAt ?? item.createdAt;
        if (raw == null) return false;
        try {
          final d = DateTime.parse(raw);
          return d.year == _selectedDate!.year &&
              d.month == _selectedDate!.month &&
              d.day == _selectedDate!.day;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (mounted) {
      setState(() {
        filteredClockingDataList = all;
      });
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  LOCALE HELPERS
  // ══════════════════════════════════════════════════════════════════

  String _getDayOfWeek(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == "ar") {
      return [
        "الإثنين",
        "الثلاثاء",
        "الأربعاء",
        "الخميس",
        "الجمعة",
        "السبت",
        "الأحد",
      ][date.weekday - 1];
    } else {
      return [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun"
      ][date.weekday - 1];
    }
  }

  String formatDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == "ar") return _toArabicNumber(date.day);
    return date.day.toString();
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join('');
  }

  // ══════════════════════════════════════════════════════════════════
  //  DATE RANGE PICKER
  // ══════════════════════════════════════════════════════════════════

  Future<void> _pickDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: NasColors.darkBlue,
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: NasColors.darkBlue,
              onPrimary: Colors.white,
              secondaryContainer: NasColors.icons,
            ),
          ),
          child: child!,
        );
      },
      initialDateRange: DateTimeRange(
          start: now.subtract(const Duration(days: 7)), end: now),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        isDateRangeSelected = true;  // show all rows in the range — no day filter
      });
      _initDates(start: picked.start, end: picked.end);
      await loadData();             // re-fetch API for the new range
      _scrollToSelectedDate();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          _buildDateStrip(context),
          const SizedBox(height: 4),
          _buildActionRow(context),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.teamClocking,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _pickDateRange(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Date Strip ─────────────────────────────────────────────────────────

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
              filterAttendanceData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? NasColors.darkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: NasColors.darkBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDay(context, date),
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

  // ── Action Row (search + branch + team) ────────────────────────────────

  Widget _buildActionRow(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (isSearching) ...[
            Expanded(child: _buildSearchField(l)),
            const SizedBox(width: 4),
          ] else ...[
            if (showDropdown) _buildBranchDropdown(context),
            const Spacer(),
            if (showTeamCheckbox)
              _buildLabeledCheckbox(
                label: l.teams,
                value: _isTeamChecked,
                enabled: singletonClass.branchID != null,
                onChanged: (value) async {
                  try {
                    singletonClass.teamAttendanceDataList.clear();
                    _isTeamChecked = value ?? false;
                    selectedBranchIds.clear();
                    singletonClass.branchID = null;
                    singletonClass.branchName = null;
                    await singletonClass.getTeamBranchData();
                    _extractTeams();
                    await loadData();
                  } catch (e) {
                    log("❌ Error toggling team checkbox: $e");
                  } finally {
                    if (mounted) setState(() => isSearching = false);
                  }
                },
              ),
          ],
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (value) async {
          setState(() => _isLoadingBranchData = true);
          try {
            singletonClass.teamAttendanceDataList.clear();
            selectedBranchIds.clear();
            singletonClass.branchID = value;
            await singletonClass.getTeamBranchData();
            await extractAllEmployeeIdsForBranch(value);
            final selectedBranch = singletonClass.availableBranches
                .firstWhere(
                    (branch) => branch.branchId.toString() == value);
            singletonClass.branchName = selectedBranch.branchName ?? '';
            if (kDebugMode) {
              print('🏢 Selected Branch ID: $value');
              print(
                  '🏷️ Branch Name: ${singletonClass.branchName}');
              print('👥 Extracted IDs: $selectedBranchIds');
            }
            _isTeamChecked = false;
            await loadData();
          } catch (e) {
            log("❌ Error in branch selection: $e");
          } finally {
            if (mounted) setState(() => _isLoadingBranchData = false);
          }
        },
        itemBuilder: (_) {
          final branchList = singletonClass.availableBranches.isNotEmpty
              ? singletonClass.availableBranches
              : [];
          if (branchList.isEmpty) return [];
          return branchList
              .map((branch) => PopupMenuItem<String>(
                    value: branch.branchId,
                    child: Text(branch.branchName ?? '---',
                        style: GoogleFonts.inter(fontSize: 14)),
                  ))
              .toList();
        },
        child: Container(
          height: 44,
          constraints:
              const BoxConstraints(minWidth: 120, maxWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
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
                    Icon(Icons.location_on_rounded,
                        size: 16, color: NasColors.darkBlue),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        singletonClass.branchName != null &&
                                singletonClass.branchName!.isNotEmpty
                            ? singletonClass.branchName!
                            : singletonClass
                                    .branchDataList.first.data!.branch!
                                    .branchName ??
                                '---',
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
                color:
                    enabled ? NasColors.darkBlue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(
      {required IconData icon, required VoidCallback onTap}) {
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

  // ── Body ───────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (_isInitialLoading || _isLoadingBranchData) return const Loader();

    // Use the pre-filtered list (date + employee already applied by filterAttendanceData)
    // Apply search on top — same pattern as TeamAttendanceScreen
    final visible = filteredClockingDataList.where((team) {
      if (!isSearching || searchController.text.isEmpty) return true;
      final q = searchController.text.toLowerCase();
      return (team.employeeName?.toLowerCase().contains(q) ?? false) ||
          (team.empId?.toLowerCase().contains(q) ?? false);
    }).toList();

    if (visible.isEmpty) return _buildEmptyState(context);

    return FadeTransition(
      opacity: _fadeController,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final team = visible[index];
          return _buildClockingCard(context, team);
        },
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

  // ── Clocking Card ──────────────────────────────────────────────────────

  Widget _buildClockingCard(BuildContext context, TeamClockingData team) {
    final statusColor = getStatusColor(team.status.toString());

    return GestureDetector(
      onTap: () {
        if (team.rawBiometrics != null && team.rawBiometrics!.isNotEmpty) {
          _showBiometricsDialog(context, team);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NasColors.darkBlue.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ── Row 1: EmpID + Date ──────────────────────────────────
              Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: NasColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.badge_outlined,
                        size: 15, color: NasColors.darkBlue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${team.empId}",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: NasColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.today_rounded,
                        size: 15, color: NasColors.darkBlue),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    singletonClass.formatDate2(
                        team.createdAt.toString(), context),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 2: Name + Status Badge ───────────────────────────
              Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: NasColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person_rounded,
                        size: 15, color: NasColors.darkBlue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${team.employeeName}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _translateSecondaryStatus(
                          "${team.status}", context),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Divider ──────────────────────────────────────────────
              Container(
                height: 1,
                decoration: BoxDecoration(
                  color: NasColors.darkBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 12),

              // ── Row 3: Check-In + Location Type ─────────────────────
              Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: NasColors.onTime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Transform(
                      transform: Matrix4.rotationY(math.pi),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.exit_to_app_outlined,
                        size: 17,
                        color: NasColors.onTime,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    team.checkInTime != null
                        ? singletonClass.formatCheckInTime(
                            team.checkInTime!, context)
                        : '--:--',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: NasColors.onTime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on_rounded,
                        size: 15, color: NasColors.onTime),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${team.type}",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Row 4: Check-Out + Total Records ─────────────────────
              Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: NasColors.reds.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.exit_to_app_outlined,
                      size: 17,
                      color: NasColors.reds,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    team.checkOutTime != null
                        ? singletonClass.formatCheckInTime(
                            team.checkOutTime!, context)
                        : '--:--',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.totalRecord,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: (team.rawBiometrics!.length == 1 ||
                              team.rawBiometrics!.length == 2)
                          ? NasColors.onTime
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 28, minHeight: 28),
                    child: Text(
                      '${team.rawBiometrics!.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Biometrics Dialog ─────────────────────────────────────────────────

  void _showBiometricsDialog(BuildContext context, TeamClockingData team) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [NasColors.darkBlue, NasColors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 55,
                    child: Text(
                      AppLocalizations.of(context)!.srNo,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      AppLocalizations.of(context)!.timeStamp,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.type,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: team.rawBiometrics!.length,
              itemBuilder: (context, index) {
                final bio = team.rawBiometrics![index];
                final isEven = index % 2 == 0;
                return Container(
                  color: isEven
                      ? NasColors.darkBlue.withOpacity(0.03)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 55,
                          child: Text(
                            "${index + 1}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: NasColors.darkBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            singletonClass.formatCheckInTime(
                                bio.timestamp.toString(), context),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "${bio.type}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded,
                  color: NasColors.reds, size: 16),
              label: Text(
                AppLocalizations.of(context)!.close,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NasColors.reds,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  STATUS HELPERS
  // ══════════════════════════════════════════════════════════════════

  // Method to parse time from a string
  DateTime? parseTime(String timeString) {
    try {
      final timeOnlyString = timeString.contains('T')
          ? timeString.split('T')[1].split('.')[0]
          : timeString.split('.')[0];
      final timeFormat = DateFormat.Hms();
      DateTime now = DateTime.now();
      DateTime parsedTime = timeFormat.parse(timeOnlyString);
      return DateTime(now.year, now.month, now.day, parsedTime.hour,
          parsedTime.minute, parsedTime.second);
    } catch (e) {
      return null;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'ontime-in':
      case 'ontime-out':
        return NasColors.green;
      case 'absent':
        return NasColors.reds;
      case 'absent with approval':
      case 'pending':
        return NasColors.yellow;
      case 'early checkout':
        return NasColors.purple;
      case 'late':
        return NasColors.amber;
      case 'check-in':
        return NasColors.violet;
      case 'check-out':
        return NasColors.fuchsia;
      case 'oos-in':
      case 'oos-out':
        return NasColors.amber;
      case 'early-in':
      case 'early-out':
        return NasColors.rose;
      case 'late-in':
      case 'late-out':
        return NasColors.brightRed;
      case 'sm-in':
      case 'sm-out':
        return NasColors.indigo;
      case 'break-in':
      case 'break-out':
        return NasColors.zinc;
      case 'slot':
        return NasColors.warmGray;
      case 'no-checkin':
        return NasColors.darkGray;
      case 'on-leave':
      case 'casual leave':
        return NasColors.blue;
      default:
        return NasColors.orange;
    }
  }

  String _translateSecondaryStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return localizations.noData;
    switch (status) {
      case 'Absent': return localizations.absent;
      case 'Present': return localizations.present;
      case 'late': return localizations.late;
      case 'leave': return localizations.leave;
      case 'holiday': return localizations.holiday;
      case 'dayOFF': return localizations.dayOff;
      case 'training': return localizations.training;
      case 'absent with approval': return localizations.absentWithApproval;
      case 'Missing CheckIn/Out': return localizations.missingCheckInOut;
      case 'Late': return localizations.late;
      case 'Pending': return localizations.pending;
      case 'No-CheckIn': return localizations.noCheckIn;
      case 'Late-Penality': return localizations.latePenality;
      case 'Short-Hours': return localizations.shortHours;
      case 'Missing-CheckIn': return localizations.missingCheckIn;
      case 'Missing-CheckOut': return localizations.missingCheckOut;
      case 'Check-In': return localizations.checkIn;
      case 'Check-Out': return localizations.checkOut;
      case 'OOS-In': return localizations.oosIn;
      case 'OOS-Out': return localizations.oosOut;
      case 'Early-In': return localizations.earlyIn;
      case 'Early-Left': return localizations.earlyLeft;
      case 'OnTime-In': return localizations.onTimeIn;
      case 'OnTime-Out': return localizations.onTimeOut;
      case 'Late-In': return localizations.lateIn;
      case 'Late-Out': return localizations.lateOut;
      case 'SM-In': return localizations.smIn;
      case 'SM-Out': return localizations.smOut;
      case 'Break-In': return localizations.breakIn;
      case 'Break-Out': return localizations.breakOut;
      case 'slot': return localizations.slot;
      case 'Out-Off-Shift': return localizations.outOffShift;
      case 'Full-Day': return localizations.fullDay;
      default: return status;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  API CALL
  // ══════════════════════════════════════════════════════════════════

  Future<TeamClockingModel?> getTeamClockingAPI(
      {DateTime? startDate, DateTime? endDate}) async {
    singletonClass.teamClockingDataList.clear();
    Set<String> employeeIds = {};

    if (!_isTeamChecked && selectedBranchIds.isNotEmpty) {
      employeeIds = selectedBranchIds;
    } else {
      for (var team in filteredUnderTeams) {
        if (team.teamData != null) {
          for (var member in team.teamData!) {
            if (member.employeeId != null &&
                member.employeeId!.isNotEmpty) {
              employeeIds.add(member.employeeId!);
            }
          }
        }
      }
    }

    if (employeeIds.isEmpty) {
      log("⚠️ No employee IDs found to fetch clocking data");
      return null;
    }

    final ids = employeeIds.join(',');
    final now = DateTime.now();
    String startDateStr = startDate != null
        ? '${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}-${startDate.year}'
        : '${now.month.toString().padLeft(2, '0')}-01-${now.year}';
    String endDateStr = endDate != null
        ? '${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}-${endDate.year}'
        : '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-check-in-out/filter?employeeId=$ids&startDate=$startDateStr&endDate=$endDateStr');
    log("📡 Fetching Team Clocking: $uri");

    var response =
        await http.get(uri, headers: singletonClass.getHeaders());
    log("Team Clocking Response: ${response.body}");

    if (response.statusCode == 200) {
      var teamClocking =
          TeamClockingModel.fromJson(json.decode(response.body));
      singletonClass.teamClockingDataList.add(teamClocking);
      return teamClocking;
    }
    return null;
  }
}
