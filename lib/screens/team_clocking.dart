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

class TeamClocking extends StatefulWidget {
  const TeamClocking({super.key});

  @override
  State<TeamClocking> createState() => _TeamClockingState();
}

class _TeamClockingState extends State<TeamClocking> {
  SingletonClass singletonClass = SingletonClass();
  late String reportingManagerId;
  late List<Teams> filteredUnderTeams;
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
  bool showTeamCheckbox = false;

  @override
  void initState() {
    super.initState();
    _teamCheck();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredUnderTeams = filteredData['underTeams']!;
    log("🔍 Filtered ${filteredUnderTeams.length} underTeams");
    final today = DateTime.now();
    _dates = List.generate(today.day, (index) {
      return DateTime(today.year, today.month, index + 1);
    });
    _setDefaultDates();
    _initDates(start: _startDate!, end: _endDate!);
    loadData();
  }

  void _teamCheck() {
    /// Safely find the dashboard module
    final dashboardModule = singletonClass
        .roleAndAccessModelDataList
        .first
        .data!
        .uiSettings!
        .uiModules!
        .firstWhere(
          (e) => e.title == "Dashboard" || e.title == "dashboard",
    );

    /// Default flags
    showDropdown = false;
    showTeamCheckbox = false;
    _isTeamChecked = false;

    if (dashboardModule != null) {
      final access = dashboardModule.accessLevel;
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
          _isTeamChecked = false; // ✅ branch selected → Team unchecked
          extractAllEmployeeIdsForBranch(singletonClass.branchID);
          loadData();
        } else {
          _isTeamChecked = true; // ✅ no branch selected → Team checked
        }
      }

      /// 🧩 CASE 2:
      /// Companies + branches available + team == false
      else if (hasCompanies && hasBranches && !teamEnabled) {
        showDropdown = true;
        showTeamCheckbox = false;
        _isTeamChecked = false;
        extractAllEmployeeIdsForBranch(singletonClass.branchID);
        loadData();
      }

      /// 🧩 CASE 3:
      /// No companies + no branches + team == true
      else if (!hasCompanies && !hasBranches && teamEnabled) {
        showDropdown = false;
        showTeamCheckbox = true;
        _isTeamChecked = true;
        extractAllEmployeeIdsForBranch(singletonClass.getJWTModel()?.branchId);
        loadData();
      }

      /// 🧩 CASE 4:
      /// No companies + no branches + team == false
      else {
        showDropdown = false;
        showTeamCheckbox = false;
        _isTeamChecked = false;
      }
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

  void extractAllEmployeeIdsForBranch(String? selectedBranchId) {
    List<String> allEmployeeIds = [];

    if ((selectedBranchId != null && selectedBranchId.isNotEmpty)) {
      final branches = singletonClass.branchesDataList.first.data;
      final branchList = branches
          ?.where((branch) => branch.branchCompanyId == selectedBranchId)
          .toList();

      if (branchList != null && branchList.isNotEmpty) {
        for (var branch in branchList) {
          final departments = branch.departmentDetails ?? [];

          for (var department in departments) {
            final departmentList = department.departments ?? [];

            for (var dept in departmentList) {
              final teams = dept.teams ?? [];

              for (var team in teams) {
                final teamData = team['teamData'] ?? [];

                for (var employee in teamData) {
                  final employeeId = employee['employeeId'];
                  if (employeeId != null) {
                    allEmployeeIds.add(employeeId);
                    selectedBranchIds.clear();
                  }
                }
              }
            }
          }
        }
      }
      selectedBranchIds = allEmployeeIds.toSet();
      if (kDebugMode) {
        print('✅ Total Employee IDs: ${allEmployeeIds.length}');
        print('🔍 All IDs Set: $selectedBranchIds');
      }
    }
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    log("📆 Default Date Range: $_startDate to $_endDate");
  }

  void _initDates({required DateTime start, required DateTime end}) {
    _dates.clear();
    final now = DateTime.now();

    for (var date = start;
        !date.isAfter(end) && !date.isAfter(now);
        date = date.add(Duration(days: 1))) {
      _dates.add(date);
    }

    _selectedDateIndex = null;
    _selectedDate = null;

    log("📅 Generated ${_dates.length} dates from $start to $end");
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
    await getTeamClockingAPI(startDate: _startDate!, endDate: _endDate!);
    filterAttendanceData();
  }

  void filterAttendanceData() {
    List<TeamClockingData> allClockingData =
        singletonClass.teamClockingDataList.first.data!;

    List<TeamClockingData> filtered = allClockingData;

    if (selectedEmployeeId != null) {
      filtered =
          filtered.where((e) => e.employeeId == selectedEmployeeId).toList();
    }

    if (_selectedDate != null) {
      filtered = filtered.where((attendance) {
        DateTime updatedAt = DateTime.parse(attendance.updatedAt!);
        return updatedAt.year == _selectedDate!.year &&
            updatedAt.month == _selectedDate!.month &&
            updatedAt.day == _selectedDate!.day;
      }).toList();
    }

    setState(() {
      filteredClockingDataList = filtered;
    });
  }

  String _getDayOfWeek(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == "ar") {
      return [
        "الإثنين", // Monday
        "الثلاثاء", // Tuesday
        "الأربعاء", // Wednesday
        "الخميس", // Thursday
        "الجمعة", // Friday
        "السبت", // Saturday
        "الأحد", // Sunday
      ][date.weekday - 1];
    } else {
      return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
    }
  }

  String formatDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == "ar") {
      return _toArabicNumber(date.day);
    } else {
      return date.day.toString();
    }
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join('');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
            child: Column(children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.4),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.teamClocking,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      final DateTime now = DateTime.now();
                      final DateTime lastSelectableDate = now;
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 2),
                        lastDate: lastSelectableDate,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              scaffoldBackgroundColor: Colors.white,
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      NasColors.darkBlue, // Button color
                                ),
                              ),
                              colorScheme: ColorScheme.light(
                                primary: NasColors.darkBlue, // Selection color
                                onPrimary: Colors.white, // Default text color
                                secondaryContainer: NasColors.icons,
                              ),
                            ),
                            child: child!,
                          );
                        },
                        initialDateRange: DateTimeRange(
                            start: now.subtract(const Duration(days: 7)),
                            end: now),
                      );
                      if (picked != null) {
                        singletonClass.teamClockingDataList.clear();
                        _startDate = picked.start;
                        _endDate = picked.end;
                        _initDates(start: picked.start, end: picked.end);
                        await getTeamClockingAPI(
                            startDate: _startDate!, endDate: _endDate!);
                        filterAttendanceData();
                      }
                    },
                    icon: Icon(
                      Icons.date_range,
                      color: NasColors.darkBlue,
                      size: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            isSearching = true;
                          });
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText:
                              '${AppLocalizations.of(context)!.search}...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.search,
                      color: NasColors.darkBlue,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showDropdown)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (value) {
                          setState(() {
                            singletonClass.branchID = value;
                            final selectedBranch = singletonClass.availableBranches
                                .firstWhere((branch) => branch.branchId.toString() == value);
                            singletonClass.branchName = selectedBranch.branchName ?? '';
                            if (kDebugMode) {
                              print('Selected Branch ID: $value');
                            }
                            extractAllEmployeeIdsForBranch(value);
                            singletonClass.getBranchData();
                            loadData();
                            _isTeamChecked = false;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          final branchList = singletonClass.availableBranches.isNotEmpty
                              ? singletonClass.availableBranches : [];
                          if (branchList.isEmpty) {
                            return [];
                          }

                          return branchList.map((branch) => PopupMenuItem<String>(
                            value: branch.branchId,
                            child: Text(branch.branchName ?? "---"),
                          )).toList();
                        },
                        child: Container(
                          height: 60,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Image.asset(
                                'images/site.png',
                                // <-- Replace with your actual image path
                                height: 14,
                                width: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  singletonClass.branchName != null &&
                                          singletonClass.branchName!.isNotEmpty
                                      ? singletonClass.branchName!
                                      : singletonClass.branchDataList.first.data!.branch!.branchName!,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    if (showTeamCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Column(
                        children: [
                          Checkbox(
                              value: _isTeamChecked,
                              activeColor: NasColors.onTime,
                              onChanged: (singletonClass.branchID != null)
                                  ? (bool? value) {
                                      setState(() {
                                        _isTeamChecked = value ?? false;
                                        singletonClass.branchID = null;
                                        singletonClass.branchName = null;
                                        singletonClass.getBranchData();
                                        selectedBranchIds.clear();
                                        _extractTeams();
                                        loadData();
                                      });
                                    }
                                  : null),
                          Text(
                            AppLocalizations.of(context)!.teams,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: NasColors.darkBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  itemBuilder: (ctx, i) {
                    final date = _dates[i];
                    final selected = _selectedDateIndex == i;
                    return GestureDetector(
                      onTap: () {
                        _selectedDateIndex = i;
                        _selectedDate = date;
                        filterAttendanceData();
                      },
                      child: Container(
                        width: 55,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? NasColors.darkBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(formatDay(context, date),
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        selected ? Colors.white : Colors.grey)),
                            Text(_getDayOfWeek(context ,date),
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        selected ? Colors.white : Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              FutureBuilder(
                  future: getTeamClockingAPI(
                      startDate: _startDate, endDate: _endDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: Lottie.asset('images/loader.json',
                              height: 200, width: 200));
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/error.json'),
                          ),
                        ),
                      );
                    }
                    if (singletonClass.teamClockingDataList.isEmpty ||
                        singletonClass.teamClockingDataList.first.data ==
                            null ||
                        singletonClass
                            .teamClockingDataList.first.data!.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Lottie.asset('images/empty.json',
                                height: 200, width: 200),
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
                      );
                    }
                    final dataList =
                        singletonClass.teamClockingDataList.first.data!;
                    return Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = dataList[index];
                        final searchText = searchController.text.toLowerCase();
                        if (isSearching) {
                          final matchesName = team.employeeName?.toLowerCase().contains(searchText) ?? false;
                          final matchesId = team.empId?.toLowerCase().contains(searchText) ?? false;

                          if (!matchesName && !matchesId) {
                            return const SizedBox.shrink();
                          }
                        }
                        return GestureDetector(
                          onTap: () {
                            if (team.rawBiometrics != null &&
                                team.rawBiometrics!.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: NasColors.onTime),
                                          child: Center(
                                              child: Text(
                                            AppLocalizations.of(context)!.srNo,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.white),
                                          )),
                                        ),
                                        Container(
                                          height: 40,
                                          width: 120,
                                          decoration: BoxDecoration(
                                              color: NasColors.onTime),
                                          child: Center(
                                              child: Text(
                                            AppLocalizations.of(context)!
                                                .timeStamp,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.white),
                                          )),
                                        ),
                                        Container(
                                          height: 40,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              color: NasColors.onTime),
                                          child: Center(
                                              child: Text(
                                            AppLocalizations.of(context)!.type,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: Colors.white),
                                          )),
                                        ),
                                      ],
                                    ),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: team.rawBiometrics!.length,
                                        itemBuilder: (context, index) {
                                          final bio =
                                              team.rawBiometrics![index];
                                          return Row(
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                width: 70,
                                                child: Center(
                                                    child: Text(
                                                  "${index + 1}",
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                )),
                                              ),
                                              SizedBox(
                                                height: 40,
                                                width: 115,
                                                child: Center(
                                                    child: Text(
                                                  singletonClass
                                                      .formatCheckInTime(
                                                          bio.timestamp
                                                              .toString(),
                                                          context),
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                )),
                                              ),
                                              SizedBox(
                                                height: 40,
                                                width: 80,
                                                child: Center(
                                                    child: Text(
                                                  "${bio.type}",
                                                  style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.black),
                                                )),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          AppLocalizations.of(context)!.close,
                                          style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${team.empId}",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        singletonClass.formatDate2(
                                            team.createdAt.toString(), context),
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        "${team.employeeName}",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        height: 20,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: getStatusColor(
                                              team.status.toString()),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _translateSecondaryStatus(
                                                "${team.status}", context),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:70,
                                        child: Text(
                                          team.checkInTime != null
                                              ? singletonClass.formatCheckInTime(
                                                  team.checkInTime!, context)
                                              : '--:--',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Transform(
                                        transform: Matrix4.rotationY(math.pi),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.exit_to_app_outlined,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                        color: NasColors.onTime,
                                      ),
                                      Text(
                                        "${team.type}",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                            team.checkOutTime != null
                                                ? singletonClass
                                                    .formatCheckInTime(
                                                        team.checkOutTime!,
                                                        context)
                                                : '--:--',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                      ),
                                      const Icon(
                                        Icons.exit_to_app_outlined,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const Spacer(),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .totalRecord,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: (team.rawBiometrics!.length ==
                                                      1 ||
                                                  team.rawBiometrics!.length ==
                                                      2)
                                              ? NasColors.onTime
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 28,
                                          minHeight: 28,
                                        ),
                                        child: Text(
                                          '${team.rawBiometrics!.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
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
                      },
                    ));
                  })
            ])));
  }

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

    if (status == null || status.isEmpty) {
      return localizations.noData;
    }

    switch (status) {
      case 'Absent':
        return localizations.absent;
      case 'Present':
        return localizations.present;
      case 'late':
        return localizations.late;
      case 'leave':
        return localizations.leave;
      case 'holiday':
        return localizations.holiday;
      case 'dayOFF':
        return localizations.dayOff;
      case 'training':
        return localizations.training;
      case 'absent with approval':
        return localizations.absentWithApproval;
      case 'Missing CheckIn/Out':
        return localizations.missingCheckInOut;
      case 'Late':
        return localizations.late;
      case 'Pending':
        return localizations.pending;
      case 'No-CheckIn':
        return localizations.noCheckIn;
      case 'Late-Penality':
        return localizations.latePenality;
      case 'Short-Hours':
        return localizations.shortHours;
      case 'Missing-CheckIn':
        return localizations.missingCheckIn;
      case 'Missing-CheckOut':
        return localizations.missingCheckOut;
      case 'Check-In':
        return localizations.checkIn;
      case 'Check-Out':
        return localizations.checkOut;
      case 'OOS-In':
        return localizations.oosIn;
      case 'OOS-Out':
        return localizations.oosOut;
      case 'Early-In':
        return localizations.earlyIn;
      case 'Early-Left':
        return localizations.earlyLeft;
      case 'OnTime-In':
        return localizations.onTimeIn;
      case 'OnTime-Out':
        return localizations.onTimeOut;
      case 'Late-In':
        return localizations.lateIn;
      case 'Late-Out':
        return localizations.lateOut;
      case 'SM-In':
        return localizations.smIn;
      case 'SM-Out':
        return localizations.smOut;
      case 'Break-In':
        return localizations.breakIn;
      case 'Break-Out':
        return localizations.breakOut;
      case 'slot':
        return localizations.slot;
      case 'Out-Off-Shift':
        return localizations.outOffShift;
      case 'Full-Day':
        return localizations.fullDay;
      default:
        return status;
    }
  }

  ///API CALL
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
            if (member.employeeId != null && member.employeeId!.isNotEmpty) {
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
        ? DateFormat('MM-dd-yyyy').format(startDate)
        : DateFormat('MM-01-yyyy').format(now);
    String endDateStr = endDate != null
        ? DateFormat('MM-dd-yyyy').format(endDate)
        : DateFormat('MM-dd-yyyy').format(now);

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-check-in-out/filter?employeeId=$ids&startDate=$startDateStr&endDate=$endDateStr');
    log("📡 Fetching Team Clocking: $uri");

    var response = await http.get(uri, headers: singletonClass.getHeaders());
    log("Team Clocking Response: ${response.body}");

    if (response.statusCode == 200) {
      var teamClocking = TeamClockingModel.fromJson(json.decode(response.body));
      singletonClass.teamClockingDataList.add(teamClocking);
      return teamClocking;
    }
    return null;
  }
}
