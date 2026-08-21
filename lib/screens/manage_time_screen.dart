import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/branch_shift_model.dart';
import 'package:nashr/request_controller/time_table_shift.dart';
import 'package:nashr/screens/update_shift_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/branches_model.dart';
import '../singleton_class.dart';
import '../widgets/loader.dart';

class ManageTimeScreen extends StatefulWidget {
  const ManageTimeScreen({super.key});

  @override
  State<ManageTimeScreen> createState() => _ManageTimeScreenState();
}

class _ManageTimeScreenState extends State<ManageTimeScreen> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();
  bool _isTeamChecked = true;
  bool isSearching = false;
  int selectedEmployeeIndex = 0;
  String? selectedEMPID;
  Future<TimeTableShiftModel?>? timeTableFuture;
  TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> timeTableShiftEmployees = [];
  Future<void>? _shiftFuture;
  bool showDropdown = false;
  bool showTeamCheckbox = false;

  @override
  void initState() {
    super.initState();
    _teamCheck();
    _shiftFuture = fetchAndSetShiftDetails();
    getShiftsFromBranches();
  }

  void _teamCheck() {
    /// Safely find the dashboard module
    final manageTimeModule = singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => (e.title == "ManageTime" || e.name == "ManageTime"),
    );
    final manageShiftsMenu = manageTimeModule.subMenu!.firstWhere((submenu) =>
    submenu.title == "Manage Shifts" ||
        submenu.name == "Manage Shifts",
    );

    /// Default flags
    showDropdown = false;
    showTeamCheckbox = false;
    _isTeamChecked = false;

    final access = manageShiftsMenu.accessLevel;
    final companies = access?.companies ?? [];

    final hasCompanies = companies.isNotEmpty;
    final hasBranches =
        hasCompanies && companies.any((c) => (c.branches ?? []).isNotEmpty);
    final teamEnabled = access?.team == true;

    /// 🧩 CASE 1:
    /// Companies + branches available + team == true
    if (hasCompanies && hasBranches && teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = true;

      if (singletonClass.branchID != null &&
          singletonClass.branchID!.isNotEmpty) {
        _isTeamChecked = false;
      } else {
        _isTeamChecked = true;
      }
    }

    /// 🧩 CASE 2:
    /// Companies + branches available + team == false
    else if (hasCompanies && hasBranches && !teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = false;
      _isTeamChecked = false;
    }

    /// 🧩 CASE 3:
    /// No companies + no branches + team == true
    else if (!hasCompanies && !hasBranches && teamEnabled) {
      showDropdown = false;
      showTeamCheckbox = true;
      _isTeamChecked = true;
    }

    /// 🧩 CASE 4:
    /// No companies + no branches + team == false
    else {
      showDropdown = false;
      showTeamCheckbox = false;
      _isTeamChecked = false;
    }
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.manageShifts,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: NasColors.darkBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => setState(() {
                          isSearching = value.isNotEmpty;
                        }),
                        cursorColor: NasColors.darkBlue,
                        style: GoogleFonts.inter(fontSize: 14, color: NasColors.darkBlue),
                        decoration: InputDecoration(
                          hintText: '${AppLocalizations.of(context)!.search}...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          isSearching = false;
                          searchController.clear();
                        }),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Selector ──────────────────────────────────────────────────────────
  Widget _buildTabSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, AppLocalizations.of(context)!.shifts, Icons.work_history_rounded),
          _buildTab(1, AppLocalizations.of(context)!.timeTable, Icons.calendar_view_week_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final bool isSelected = _selectedOptionIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOptionIndex = index;
            if (index == 0) {
              _shiftFuture = fetchAndSetShiftDetails();
              getShiftsFromBranches();
              isSearching = false;
            } else {
              isSearching = true;
              if (timeTableShiftEmployees.isNotEmpty) {
                final employee = timeTableShiftEmployees[0];
                debugPrint(employee['employeeId']);
                selectedEMPID = employee['employeeId'];
                timeTableFuture = getTimeTable(selectedEMPID!);
              } else {
                debugPrint("⚠️ No employees found in timeTableShiftEmployees");
                selectedEMPID = null;
                timeTableFuture = null;
              }
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? NasColors.darkBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabSelector(context),
          // ── Filter Row ────────────────────────────────────────────────────
          if (_selectedOptionIndex == 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (isSearching == false) ...[
                    if (showDropdown)
                      PopupMenuButton<String>(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (value) {
                          setState(() {
                            timeTableShiftEmployees.clear();
                            singletonClass.branchID = value;
                            final selectedBranch = singletonClass.availableBranches
                                .firstWhere((branch) => branch.branchId.toString() == value);
                            singletonClass.branchName = selectedBranch.branchName ?? '';
                            _isTeamChecked = false;
                            _shiftFuture = fetchAndSetShiftDetails();
                            getShiftsFromBranches();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          final branchList = singletonClass.availableBranches.isNotEmpty
                              ? singletonClass.availableBranches : [];
                          if (branchList.isEmpty) return [];
                          return branchList.map((branch) => PopupMenuItem<String>(
                            value: branch.branchId,
                            child: Text(branch.branchName ?? "---"),
                          )).toList();
                        },
                        child: Container(
                          height: 44,
                          constraints: const BoxConstraints(maxWidth: 170),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: NasColors.darkBlue.withOpacity(0.12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, size: 16, color: NasColors.darkBlue),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  singletonClass.branchName != null &&
                                      singletonClass.branchName!.isNotEmpty
                                      ? singletonClass.branchName!
                                      : singletonClass.branchDataList.first.data!.branch!.branchName!,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.darkBlue,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 18),
                            ],
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (showTeamCheckbox)
                      Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: NasColors.darkBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.people_rounded, size: 18, color: NasColors.darkBlue),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.teams,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: _isTeamChecked,
                              activeColor: NasColors.darkBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (singletonClass.branchID != null) ? (bool? value) {
                                setState(() {
                                  _isTeamChecked = value ?? false;
                                  if (_isTeamChecked == true) {
                                    timeTableShiftEmployees.clear();
                                    singletonClass.branchID = null;
                                    singletonClass.branchName = null;
                                    _shiftFuture = fetchAndSetShiftDetails();
                                    getShiftsFromBranches();
                                  }
                                });
                              } : null,
                            ),
                          ),
                        ],
                      ),
                  ],

                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _selectedOptionIndex == 0
                ? _buildShiftsTab()
                : _buildTimeTableTab(),
          ),
        ],
      ),
    );
  }

  // ── Shifts Tab ─────────────────────────────────────────────────────────────
  Widget _buildShiftsTab() {
    return FutureBuilder(
      future: _shiftFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return Center(
            child: SizedBox(height: 200, width: 200, child: Lottie.asset('images/error.json')),
          );
        } else {
          final employees = singletonClass.branchShiftsDataList.first.data?.employees ?? [];
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 200, width: 200, child: Lottie.asset('images/empty.json')),
                  Text(
                    AppLocalizations.of(context)!.noData,
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: NasColors.darkBlue),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: employees.length,
            itemBuilder: (ctx, i) {
              final employee = employees[i];
              final searchText = searchController.text.toLowerCase();
              if (isSearching &&
                  !((employee.userName?.toLowerCase().contains(searchText) ?? false) ||
                      (employee.employeeInfo!.first.empId?.toLowerCase().contains(searchText) ?? false))) {
                return const SizedBox.shrink();
              }

              final shiftType = employee.shiftInfo?.shiftType ?? '';
              final IconData shiftIcon = shiftType == 'fullTime'
                  ? Icons.access_time_filled_rounded
                  : shiftType == 'flexibleShift'
                      ? Icons.tune_rounded
                      : Icons.calendar_view_week_rounded;

              return Container(
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
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        backgroundColor: NasColors.darkBlue.withOpacity(0.08),
                        radius: 26,
                        child: Image.asset('images/DP.png', fit: BoxFit.cover, width: 52, height: 52),
                      ),
                      const SizedBox(width: 12),
                      // Name + time info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${employee.userName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: NasColors.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: NasColors.darkBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Icon(shiftIcon, size: 14, color: NasColors.darkBlue),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _translateShifts(shiftType, context),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (employee.shiftInfo != null && employee.shiftInfo!.shiftType == 'fullTime')
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${formatIsoTime(employee.shiftInfo?.timeFrom)} – ${formatIsoTime(employee.shiftInfo?.timeTo)}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Edit button
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () async {
                              final RenderBox button = context.findRenderObject() as RenderBox;
                              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                              final RelativeRect position = RelativeRect.fromRect(
                                Rect.fromPoints(
                                  button.localToGlobal(Offset.zero, ancestor: overlay),
                                  button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                ),
                                Offset.zero & overlay.size,
                              );
                              await showMenu(
                                context: context,
                                position: position,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                color: Colors.white,
                                items: [
                                  PopupMenuItem(
                                    padding: EdgeInsets.zero,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => UpdateShiftScreen(employees: employee)),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, size: 16, color: NasColors.darkBlue),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!.update,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: NasColors.darkBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.more_vert_rounded, color: NasColors.darkBlue, size: 20),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // ── Time Table Tab ──────────────────────────────────────────────────────────
  Widget _buildTimeTableTab() {
    return Column(
      children: [
        // Employee selector
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: timeTableShiftEmployees.length,
            itemBuilder: (context, index) {
              final employee = timeTableShiftEmployees[index];
              final isSelected = index == selectedEmployeeIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedEmployeeIndex = index;
                    selectedEMPID = employee['employeeId'];
                    timeTableFuture = getTimeTable(selectedEMPID!);
                  });
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? NasColors.darkBlue.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? NasColors.darkBlue.withOpacity(0.3) : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: Image.asset('images/DP.png', fit: BoxFit.cover, width: 48, height: 48),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          employee['employeeName'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? NasColors.darkBlue : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 3,
                            width: 30,
                            decoration: BoxDecoration(
                              color: NasColors.darkBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Timetable content
        Expanded(
          child: FutureBuilder(
            future: timeTableFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapshot.hasError) {
                return Center(
                  child: SizedBox(height: 200, width: 200, child: Lottie.asset('images/error.json')),
                );
              } else if (!snapshot.hasData ||
                  singletonClass.timeTableShiftsDataList.isEmpty ||
                  singletonClass.timeTableShiftsDataList.first.data == null ||
                  singletonClass.timeTableShiftsDataList.first.data!.isEmpty ||
                  singletonClass.timeTableShiftsDataList.first.data!.first.shifts == null ||
                  singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.isEmpty ||
                  singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.first.shiftDates == null ||
                  singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.first.shiftDates!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 200, width: 200, child: Lottie.asset('images/empty.json')),
                      Text(
                        AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: NasColors.darkBlue),
                      ),
                    ],
                  ),
                );
              }

              final shiftDates = singletonClass.timeTableShiftsDataList
                  .first.data!.first.shifts!.first.shiftDates!;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: NasColors.darkBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.calendar_view_week_rounded, size: 16, color: NasColors.darkBlue),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.timeTable,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shiftDates.length,
                      itemBuilder: (ctx, i) {
                        final timeTable = shiftDates[i];
                        final slots = timeTable.slots ?? [];

                        String formatDateWithDay(String updatedAt) {
                          try {
                            final updatedAtDateTime = DateTime.parse(updatedAt);
                            final formattedDate = DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                            final dayName = DateFormat('EEEE').format(updatedAtDateTime);
                            return "$formattedDate ($dayName)";
                          } catch (e) {
                            return '';
                          }
                        }

                        final String date = formatDateWithDay(timeTable.date ?? '');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NasColors.darkBlue.withOpacity(0.06)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: NasColors.darkBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.today_rounded, size: 15, color: NasColors.darkBlue),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    date,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: slots.map((slot) {
                                  final Color baseColor = parseColor(slot.color)?.withOpacity(0.85) ?? Colors.orange.shade400;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: baseColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: baseColor.withOpacity(0.4)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.login_rounded, size: 14, color: baseColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          slot.start != null ? formatOnlyTime(slot.start!) : '--:--',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: baseColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Icon(Icons.arrow_forward_rounded, size: 13, color: baseColor.withOpacity(0.6)),
                                        ),
                                        Icon(Icons.logout_rounded, size: 14, color: baseColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          slot.end != null ? formatOnlyTime(slot.end!) : '--:--',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: baseColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// API CALLS
  Future<void> fetchAndSetShiftDetails() async {
    String? branchId;
    if (_isTeamChecked == false) {
      branchId = singletonClass.branchID?.isNotEmpty == true
          ? singletonClass.branchID
          : singletonClass.getJWTModel()?.branchId;
    } else {
      branchId = singletonClass.getJWTModel()?.branchId;
    }

    if (branchId == null) return;

    final uri = Uri.parse('${singletonClass.baseURL}/branches/branchEmplyeesInfo/$branchId');
    final response = await http.get(uri, headers: singletonClass.getHeaders());

    debugPrint("Shifts uri $uri");
    debugPrint("Shift data: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final branch = BranchShiftModel.fromJson(responseBody);

      singletonClass.branchShiftsDataList.clear();
      singletonClass.branchShiftsDataList.add(branch);

      final employees = branch.data?.employees;
      timeTableShiftEmployees.clear();

      if (employees != null) {
        for (var emp in employees) {
          final shiftType = emp.shiftInfo?.shiftType;
          if (shiftType != null && shiftType.toLowerCase() == 'timetableshift') {
            timeTableShiftEmployees.add({
              "employeeId": emp.id ?? "NoID",
              "employeeName": emp.userName ?? "Unknown",
            });
          }
        }
        if (timeTableShiftEmployees.isNotEmpty) {
          selectedEMPID = timeTableShiftEmployees[0]['employeeId'];
        }
      }
    }
  }

  /// TIME TABLE API CALL
  Future<TimeTableShiftModel?> getTimeTable(String employeeId) async {
    final jwt = singletonClass.getJWTModel();

    final companyId = (singletonClass.selectedCompanyId?.isNotEmpty ?? false)
        ? singletonClass.selectedCompanyId
        : jwt?.companyId;

    final branchId = (singletonClass.branchID?.isNotEmpty ?? false)
        ? singletonClass.branchID
        : jwt?.branchId;

    final String currentMonth = DateFormat('MMMM').format(DateTime.now());

    if (companyId == null || branchId == null) {
      if (kDebugMode) print("Company ID or Branch ID is missing");
      return null;
    }

    final uri = Uri.parse(
      '${singletonClass.baseURL}/time-tables/getByEmployeeIds/$companyId/$branchId?month=$currentMonth&employeeId=$employeeId',
    );

    final response = await http.get(uri, headers: singletonClass.getHeaders());
    if (kDebugMode) {
      print("time table uri $uri");
      print("TIME TABLE RESPONSE ${response.body}");
    }

    if (response.statusCode == 200) {
      final timeTable = TimeTableShiftModel.fromJson(json.decode(response.body));
      singletonClass.timeTableShiftsDataList
        ..clear()
        ..add(timeTable);
      return timeTable;
    }
    return null;
  }

  /// UPDATE SHIFT DATA
  Future<void> getShiftsFromBranches() async {
    String? branchId;
    if (_isTeamChecked == false) {
      branchId = singletonClass.branchID?.isNotEmpty == true
          ? singletonClass.branchID
          : singletonClass.getJWTModel()?.branchId;
    } else {
      branchId = singletonClass.getJWTModel()?.branchId;
    }

    final uri = Uri.parse('${singletonClass.baseURL}/branches/branchId/$branchId');
    final response = await http.get(uri, headers: singletonClass.getHeaders());
    debugPrint("shift data update${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final branch = BranchesModel.fromJson(responseBody);
      singletonClass.branchesModelDataList.clear();
      singletonClass.branchesModelDataList.addAll([branch]);
    }
  }

  String formatIsoTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '--';
    try {
      final utcTime = DateTime.parse(isoTime).toLocal();
      return DateFormat('hh:mm a').format(utcTime);
    } catch (e) {
      return '--:--';
    }
  }

  Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return null;
    }
  }

  String formatOnlyTime(String timeStr) {
    try {
      final time = DateTime.parse("1970-01-01T$timeStr");
      return DateFormat.jm().format(time);
    } catch (e) {
      return '--:--';
    }
  }

  String _translateShifts(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null || status.isEmpty) return localizations.noData;
    switch (status) {
      case 'fullTime':
        return localizations.fullTime;
      case 'flexibleShift':
        return localizations.flexibleShift;
      case 'timeTableShift':
        return localizations.timeTableShift;
      default:
        return status;
    }
  }
}