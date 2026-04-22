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

class _TeamAttendanceScreenState extends State<TeamAttendanceScreen> {
  final SingletonClass singletonClass = SingletonClass();
  bool _isChecked = false;
  bool _isTeamChecked = true;
  late String reportingManagerId;
  late List<Teams> filteredUnderTeams;
  List<TeamAttendanceData> filteredAttendanceDataList = [];
  String? selectedEmployeeId;
  DateTime? _selectedDate;
  int? _selectedDateIndex;
  Set<String> selectedBranchIds = {};
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedOptionIndex = 0;
  bool isSearching = false;
  bool _isLoadingBranchData = false;
  bool showDropdown = false;
  bool showTeamCheckbox = false;
  bool showOnlyMeCheckbox = false;
  TextEditingController searchController = TextEditingController();
  late List<DateTime> _dates;
  bool _isInitialLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool isDateRangeSelected = false;
  bool _isLoading = false;


  @override
   void initState() {
    super.initState();
    _isInitialLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try{
        _teamCheck();

        if (singletonClass.getJWTModel()?.grade == 'L4') {
          _isChecked = true;
        }
        reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
        log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
        await singletonClass.getTeamBranchData();
        await singletonClass.getBranchData();
        List<BranchData> branchDataList = singletonClass.branchDataList;
        var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
        filteredUnderTeams = filteredData['underTeams']!;
        log("🔍 Filtered ${filteredUnderTeams.length} underTeams");
        await loadData();
      } catch (e, s) {
        log("❌ initState error: $e\n$s");
      } finally {
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
          });
        }
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

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients && _selectedDateIndex! >= 0) {
      _scrollController.animateTo(
        _selectedDateIndex! * 60,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _teamCheck() {
    /// Safely get Dashboard module
    final manageTimeModule = singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => (e.title == "ManageTime" || e.name == "ManageTime"),
    );
    final attendanceHistoryMenu = manageTimeModule.subMenu!.firstWhere((submenu) =>
    submenu.title == "Attendance History" ||
        submenu.name == "Attendance History",
    );

    final access = attendanceHistoryMenu.accessLevel;
    final companies = access?.companies ?? [];
    final hasCompanies = companies.isNotEmpty &&
        companies.any((c) => c.companyId != null && c.companyId!.isNotEmpty && c.companyId != "");
    final hasBranches =
        hasCompanies &&
        companies.any((c) =>
        c.branches != null &&
            c.branches!.isNotEmpty &&
            c.branches!.any((b) => b.branchId != null && b.branchId!.isNotEmpty && b.branchId != ""));
    final teamEnabled = access?.team == true;
    final hasBranchId =
        singletonClass.branchID != null && singletonClass.branchID!.isNotEmpty;

    /// Reset all UI flags
    showDropdown = false;
    showTeamCheckbox = false;
    showOnlyMeCheckbox = false;
    _isTeamChecked = false;
    _isChecked = false;

    /// 🧩 CASE 1: Companies & Branches available, Team == true
    if (hasCompanies && hasBranches && teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = true;
      showOnlyMeCheckbox = true;

      if (hasBranchId) {
        /// Branch selected → Team off, Only Me off
        _isTeamChecked = false;
        _isChecked = false;
        extractAllEmployeeIdsForBranch(singletonClass.branchID);
      } else {
        /// No branch selected → Team on, Only Me off
        _isTeamChecked = true;
        _isChecked = false;
      }
    }

    /// 🧩 CASE 2: Companies & Branches available, Team == false
    else if (hasCompanies && hasBranches && !teamEnabled) {
      showDropdown = true;
      showTeamCheckbox = false;
      showOnlyMeCheckbox = true;

      if (!hasBranchId) {
        /// No branch selected → Only Me true
        _isChecked = true;
      } else {
        extractAllEmployeeIdsForBranch(singletonClass.branchID);
      }
    }

    /// 🧩 CASE 3: No Companies/Branches, Team == true
    else if (!hasCompanies && !hasBranches && teamEnabled) {
      showDropdown = false;
      showTeamCheckbox = true;
      showOnlyMeCheckbox = true;
      _isTeamChecked = true;
      _isChecked = false;
    }

    /// 🧩 CASE 4: No Companies/Branches, Team == false
    else {
      showDropdown = false;
      showTeamCheckbox = false;
      showOnlyMeCheckbox = true;
      _isTeamChecked = false;
      _isChecked = true;
    }

    /// 🔁 Refresh data based on updated logic
    setState(() {
      loadData();
    });

    log('✅ _teamCheck results → '
        'Dropdown: $showDropdown | TeamCheckbox: $showTeamCheckbox | OnlyMe: $showOnlyMeCheckbox | '
        '_isTeamChecked: $_isTeamChecked | _isChecked: $_isChecked');
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

        /// ✅ FILTER BY BRANCH ID
        if (branchData?.employees!.first.branchId != selectedBranchId) continue;

        if (branchData?.employees != null) {
          for (var employee in branchData!.employees!) {
            final employeeId = employee.id;

            if (employeeId != null &&
                employeeId.isNotEmpty &&
                employee.employeeInfo!.first.employeeStatus == 'Active') {
              allEmployeeIds.add(employeeId);
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

  void _setDefaultDates() {
    final now = DateTime.now();

    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day);

    log("📆 Default Date Range: $_startDate to $_endDate");
  }


  void _initDates({required DateTime start, required DateTime end}) {
    _dates.clear();
    final today = DateTime.now();

    for (var date = start; !date.isAfter(end); date = date.add(const Duration(days: 1))) {
      _dates.add(date);
    }

    /// ✅ Auto-select today's index
    _selectedDateIndex = _dates.indexWhere((d) =>
    d.year == today.year && d.month == today.month && d.day == today.day);

    if (_selectedDateIndex != -1) {
      _selectedDate = today;
    }
    log("📅 Generated ${_dates.length} dates");
    log("✅ Auto-selected today: $_selectedDate");
  }



  Map<String, List<Teams>> getFilteredTeams(List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;
    log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");
    log("🔍 User grade: $userGrade");

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data?.branch!.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          log("🏢 Department: ${department.departmentName}");
          for (var supervisor in department.supervisors ?? []) {
            log("👨‍💼 Supervisor: ${supervisor.empId}, Team ID: ${supervisor.teamId}");
          }
          for (var team in department.teams ?? []) {
            log("🧑‍🤝‍🧑 Team: ${team.teamId}");
            for (var supervisor in department.supervisors ?? []) {
              if (supervisor.empId == reportingManagerId && supervisor.teamId == team.teamId) {
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
    await getTeamAttendanceData(startDate: _startDate!, endDate: _endDate!);
    filterAttendanceData();
  }


  Future<TeamAttendanceModel?> getTeamAttendanceData({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10000,
    int page = 0,
  }) async {
    log("📡 Fetching attendance data...");
    Set<String> employeeIds = {};

    final grade = singletonClass.getJWTModel()?.grade;

    if (grade == 'L0' || grade == 'L1' || grade == 'L2' || grade == "L3"){
      if(_isChecked == false && _isTeamChecked == true && (singletonClass.branchID!.isEmpty || singletonClass.branchID == null)){
        for (var team in filteredUnderTeams) {
          log("👥 Processing team: ${team.teamId}");
          if (team.teamData != null && team.teamData!.isNotEmpty) {
            for (var member in team.teamData!) {
              if (member.employeeId != null && member.employeeId!.isNotEmpty) {
                employeeIds.add(member.employeeId!);
                log(" - Added Employee ID: ${member.employeeId}");
              } else {
                log(" - ⚠️ Skipping empty employeeId in team: ${team.teamId}");
              }
            }
          } else {
            log(" - ⚠️ No teamData found for team: ${team.teamId}");
          }
        }
      } else if (_isChecked == false && _isTeamChecked == false && singletonClass.branchID!.isNotEmpty && singletonClass.branchID != null){
        if (selectedBranchIds.isNotEmpty) {
          employeeIds = selectedBranchIds;
        }
      } else {
        String? userID = singletonClass.getJWTModel()?.employeeId;
        employeeIds.add(userID!);
      }
    } else {
      String? userID = singletonClass.getJWTModel()?.employeeId;
      employeeIds.add(userID!);
    }

    if (employeeIds.isEmpty) {
      log("❌ No employee IDs found. Returning empty attendance data.");
      filteredAttendanceDataList.clear();
      return  null;
    }

    final ids = employeeIds.join(',');
    final now = DateTime.now();

    String startDateStr = startDate != null
        ? '${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}-${startDate.year}'
        : '${now.month.toString().padLeft(2, '0')}-01-${now.year}';

    String endDateStr = endDate != null
        ? '${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}-${endDate.year}'
        : '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    final uri = Uri.parse(
      '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$ids/$endDateStr/$startDateStr?limit=$limit&page=$page',
    );

    log("🌐 Final Employee ID list: $ids");
    log("🌐 API URL: $uri");

    final response = await http.get(uri,headers: singletonClass.getHeaders());

    log("📨 TEAM DATA RESPONSE: ${response.statusCode}");
    log("📨 TEAM DATA BODY: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final attendance = TeamAttendanceModel.fromJson(responseBody);
      singletonClass.teamAttendanceDataList.clear();
      singletonClass.teamAttendanceDataList.add(attendance);
      log("✅ Attendance data successfully fetched and saved");
      return attendance;
    } else {
      log("❌ Failed to fetch attendance data");
      return null;
    }
  }



  void filterAttendanceData() {
    List<TeamAttendanceData> allAttendanceData =
        singletonClass.teamAttendanceDataList.first.data!.data ?? [];

    List<TeamAttendanceData> filtered = allAttendanceData;

    // ✅ Filter by employee if selected
    if (selectedEmployeeId != null) {
      filtered = filtered.where((e) => e.employeeId == selectedEmployeeId).toList();
    }

    // ✅ Show all date range data when range is selected
    if (!isDateRangeSelected) {
      if (_selectedDate != null) {
        filtered = filtered.where((attendance) {
          DateTime updatedAt = DateTime.parse(attendance.date!);
          return updatedAt.year == _selectedDate!.year &&
              updatedAt.month == _selectedDate!.month &&
              updatedAt.day == _selectedDate!.day;
        }).toList();
      }
    }

    setState(() {
      filteredAttendanceDataList.clear();
      filteredAttendanceDataList = filtered;
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
    final manageTimeModule = singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => (e.title == "ManageTime" || e.name == "ManageTime"),
    );
    final attendanceHistoryMenu = manageTimeModule.subMenu!.firstWhere((submenu) =>
      submenu.title == "Attendance History" ||
          submenu.name == "Attendance History",
    );

    final access = attendanceHistoryMenu.accessLevel;
    final companies = access!.companies ?? [];
    final hasCompanies = companies.isNotEmpty &&
        companies.any((c) => c.companyId != null && c.companyId!.isNotEmpty && c.companyId != "");
    final hasBranches =
        hasCompanies &&
            companies.any((c) =>
            c.branches != null &&
                c.branches!.isNotEmpty &&
                c.branches!.any((b) => b.branchId != null && b.branchId!.isNotEmpty && b.branchId != ""));
    final teamEnabled = access.team == true;

    if (hasCompanies && hasBranches && teamEnabled) {
      // ✅ Case 1: Companies + Branches + Team → Dropdown + Team + Only Me
      showDropdown = true;
      showTeamCheckbox = true;
      showOnlyMeCheckbox = true;
    } else if (hasCompanies && hasBranches && !teamEnabled) {
      // ✅ Case 2: Companies + Branches + No Team → Dropdown + Only Me
      showDropdown = true;
      showOnlyMeCheckbox = true;
    } else if (!hasCompanies && !hasBranches && teamEnabled) {
      // ✅ Case 3: No companies + No branches + Team → Team + Only Me
      showTeamCheckbox = true;
      showOnlyMeCheckbox = true;
    } else if (!hasCompanies && !hasBranches && !teamEnabled) {
      // ✅ Case 4: No companies + No branches + No Team → Only Me
      showOnlyMeCheckbox = true;
    }
      return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
            child: Row(
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
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.attendanceHistory,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
                  IconButton(
                    onPressed: () async {
                      final DateTime now = DateTime.now();
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(now.year - 2),
                        lastDate: now,
                        initialDateRange: DateTimeRange(
                          start: now.subtract(const Duration(days: 7)),
                          end: now,
                        ),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              scaffoldBackgroundColor: Colors.white,
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: NasColors.darkBlue, // Button color
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
                      );
                      if (picked != null) {
                        _startDate = picked.start;
                        _endDate = picked.end;

                        isDateRangeSelected = true;  // ✅ activate range mode

                        _initDates(start: picked.start, end: picked.end);

                        await loadData(); // <-- API fetch
                      }
                    },
                    icon:  Icon(Icons.date_range,color: NasColors.darkBlue,size: 30,),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildOptionsCard(0, AppLocalizations.of(context)!.all),
                buildOptionsCard(1, AppLocalizations.of(context)!.present),
                buildOptionsCard(2, AppLocalizations.of(context)!.absent),
                buildOptionsCard(3, AppLocalizations.of(context)!.leave),
                buildOptionsCard(4, AppLocalizations.of(context)!.missingCheckInOut),
                buildOptionsCard(5, AppLocalizations.of(context)!.late),
                buildOptionsCard(6, AppLocalizations.of(context)!.earlyCheckOut),

              ],
            ),
          ),
            SizedBox(
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
                    child: Container(
                      width: 55,
                      decoration: BoxDecoration(
                        color: selected ? NasColors.darkBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(formatDay(context, date),
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : Colors.grey)),
                          Text(_getDayOfWeek(context,date),
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(isSearching == false)...[
                if(_isChecked == false)...[
                  if (showDropdown)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (value) async {
                          // 🧩 Show loader while fetching
                          setState(() {
                            _isLoadingBranchData = true;
                          });

                          try {
                            singletonClass.teamAttendanceDataList.clear();
                            selectedBranchIds.clear();
                            singletonClass.branchID = value;

                            // 🔹 1. Fetch latest team-branch data
                            await singletonClass.getTeamBranchData();

                            // 🔹 2. Extract employee IDs for that branch
                            await extractAllEmployeeIdsForBranch(value);

                            // 🔹 3. Get branch name
                            final selectedBranch = singletonClass.availableBranches
                                .firstWhere((branch) => branch.branchId.toString() == value);
                            singletonClass.branchName = selectedBranch.branchName ?? '';

                            if (kDebugMode) {
                              print('🏢 Selected Branch ID: $value');
                              print('🏷️ Branch Name: ${singletonClass.branchName}');
                              print('👥 Extracted IDs: $selectedBranchIds');
                            }

                            // 🔹 4. Reset checkboxes and load attendance
                            _isTeamChecked = false;
                            _isChecked = false;
                            await loadData();
                          } catch (e) {
                            log("❌ Error in branch selection: $e");
                          } finally {
                            // ✅ Hide loader after everything completes
                            setState(() {
                              _isLoadingBranchData = false;
                            });
                          }
                        },

                        itemBuilder: (BuildContext context) {
                          final branchList = singletonClass.availableBranches;
                          if (branchList.isEmpty) return [];

                          return branchList.map((branch) {
                            return PopupMenuItem<String>(
                              value: branch.branchId,
                              child: Text(branch.branchName ?? "---"),
                            );
                          }).toList();
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
                          child:_isLoadingBranchData
                              ? Center(child: CircularProgressIndicator(
                            color: NasColors.darkBlue,
                          ))
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Image.asset('images/site.png', height: 14, width: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  singletonClass.branchName?.isNotEmpty == true
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
                              const Icon(Icons.keyboard_arrow_down, color: Colors.black),
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
                                ? (bool? value) async {

                              try {
                                singletonClass.teamAttendanceDataList.clear();
                                _isChecked = false;
                                _isTeamChecked = value ?? false;
                                selectedBranchIds.clear();

                                if (hasCompanies && hasBranches && teamEnabled) {
                                  singletonClass.branchID = null;
                                  singletonClass.branchName = null;
                                }

                                await singletonClass.getTeamBranchData();
                                await loadData();
                              } catch (e) {
                                log("❌ Error toggling team checkbox: $e");
                              } finally {
                                setState(() {
                                  isSearching = false;
                                });
                              }
                            }
                                : null,
                          ),
                          Text(
                            AppLocalizations.of(context)!.teams,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (showOnlyMeCheckbox)...[
                  if (!_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Column(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          activeColor: NasColors.onTime,
                          onChanged: (bool? value) {
                            final newValue = value ?? false;

                            /// ✅ Immediate UI update
                            setState(() {
                              _isChecked = newValue;
                              _isLoading = true; // ONLY loader
                            });

                            _handleCheckboxChange(newValue);
                          },
                        ),
                        Text(
                          AppLocalizations.of(context)!.onlyMe,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                      SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ),
                ]
              ],
              if(isSearching == true)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {

                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSearching = false;
                            searchController.clear();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: (){
                setState(() {
                  isSearching = true;
                });
              }, icon: Icon(Icons.search, size: 30,color: Colors.black,))
            ],
          ),
            SizedBox(height: 10),
            Expanded(
                child: (_isLoadingBranchData ||  _isInitialLoading == true)
                    ? Loader()
                    : FutureBuilder(
                    future: getTeamAttendanceData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loader();
                      } else if (filteredAttendanceDataList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Lottie.asset('images/empty.json'),
                                  ),
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
                      final hasMatchingData = filteredAttendanceDataList.any((attendance) {
                        final status = attendance.status?.toLowerCase() ?? '';

                        if (_selectedOptionIndex == 0) return true;
                        if (_selectedOptionIndex == 1) return status == 'present';
                        if (_selectedOptionIndex == 2) return status == 'absent';
                        if (_selectedOptionIndex == 4) {
                          final normalized = status.replaceAll('-', ' ');
                          return normalized == 'missing checkin/out' ||
                              normalized == 'missing checkin' ||
                              normalized == 'missing checkout' ||
                              normalized == 'pending';
                        }
                        if (_selectedOptionIndex == 5) return (attendance.lateMinutes ?? 0) > 0;
                        if (_selectedOptionIndex == 6) return (attendance.earlyCheckOut ?? 0) > 0;
                        if (_selectedOptionIndex == 3) {
                          final normalized = status.replaceAll('-', ' ');
                          return normalized == 'on-leave' ||
                              normalized == 'leave' ||
                              normalized == 'annualLeave' ||
                              normalized == 'on leave';
                        }
                        return false;
                      });
                      return  hasMatchingData
                          ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:filteredAttendanceDataList.length,
                        itemBuilder: (ctx, i) {
                          final attendance = filteredAttendanceDataList[i];
                          if (_selectedOptionIndex != 0) {
                            final status = attendance.status?.toLowerCase();
                            if ((_selectedOptionIndex == 1 && status != 'present') ||
                                (_selectedOptionIndex == 2 && status != 'absent') ||
                                (_selectedOptionIndex == 4 && !['missing checkin/out', 'missing checkin', 'missing checkout' , 'pending']
                                    .contains(status.replaceAll('-', ' '))) ||
                                (_selectedOptionIndex == 5 && (attendance.lateMinutes ?? 0) <= 0) ||
                                (_selectedOptionIndex == 6 && (attendance.earlyCheckOut ?? 0) <= 0) ||
                                (_selectedOptionIndex == 3 && !['on-leave', 'leave', 'on leave']
                                    .contains(status.replaceAll('-', ' ')))
                            ) {
                              return const SizedBox.shrink();
                            }
                          }

                          String formatDate(String updatedAt) {
                            try{
                              DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                              final locale = Localizations.localeOf(context).languageCode;
                              if (locale == 'ar'){
                                final arabicFormatter = DateFormat('dd-MM-yyyy', 'ar');
                                return arabicFormatter.format(updatedAtDateTime);
                              }else{
                                final formattedTime = DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                                return formattedTime;
                              }
                            } catch (e){
                              if (kDebugMode) {
                                print("Error formatting time: $e");
                              }
                              return '--:--';
                            }
                          }
                          String date = formatDate(attendance.date!);
                          int? lateMinutes = int.tryParse(attendance.lateMinutes.toString());
                          int? earlyCheckOut = int.tryParse(attendance.earlyCheckOut.toString());
                          String breakTime = formatMinutes(attendance.breakTime);
                          final searchText = searchController.text.toLowerCase();
                          if (isSearching) {
                            final matchesName = attendance.name?.toLowerCase().contains(searchText) ?? false;
                            final matchesId = attendance.empId?.toLowerCase().contains(searchText) ?? false;

                            if (!matchesName && !matchesId) {
                              return const SizedBox.shrink();
                            }
                          }
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TeamAttendanceDetailScreen(attendanceData: attendance),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        attendance.empId ?? "___",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(date,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 30,
                                          child: ClipOval(
                                            child: Image.asset(
                                              'images/DP.png',
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: 130,
                                            child: Text(
                                              attendance.name ?? "___",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        children: [
                                          if (attendance.status != null)
                                            Container(
                                              height: attendance.status == "Missing CheckIn/Out" ? 50 : 30,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: getStatusColor(attendance.status!),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _translateStatus(attendance.status!, context),
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: 5),
                                          if (attendance.secondaryStatus != null)
                                            Container(
                                              height: attendance.secondaryStatus == "Missing CheckIn/Out" ? 50 : 30,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: getStatusColor(attendance.secondaryStatus!),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _translateSecondaryStatus(attendance.secondaryStatus!, context),
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
                                      )

                                    ],
                                  ),
                                  if(attendance.status != "On-Leave")...[SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.shifts,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Spacer(),
                                        Builder(builder: (_) {
                                          final int workedMinutes = attendance.totalHoursWorked ?? 0;
                                          final int totalWorkingMinutes = 11 * 60;
                                          final double progress = (workedMinutes / totalWorkingMinutes).clamp(0.0, 1.0);

                                          return Column(
                                            children: [
                                              Text(
                                                "${workedMinutes ~/ 60}${AppLocalizations.of(context)!.h} ${workedMinutes % 60}${AppLocalizations.of(context)!.m}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              SizedBox(
                                                width: 80,
                                                height: 8,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: LinearProgressIndicator(
                                                    value: progress,
                                                    backgroundColor: Colors.grey[300],
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      progress >= 1.0
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                    minHeight: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            if (attendance.shiftInfo != null && attendance.shiftInfo!.shiftType == 'fullTime')...[
                                              Text(
                                                attendance.shiftInfo != null &&
                                                    attendance.shiftInfo!.timefrom != null &&
                                                    attendance.shiftInfo!.timeTo != null
                                                    ? "${singletonClass.formatCheckInTime(attendance.shiftInfo!.timefrom.toString(), context)} - ${singletonClass.formatCheckInTime(attendance.shiftInfo!.timeTo.toString(), context)}"
                                                    : "---",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 180,
                                                child: Text(
                                                  maxLines: 5,
                                                  attendance.shiftInfo != null &&
                                                      attendance.shiftInfo!.shiftName != null
                                                      ? "${attendance.shiftInfo!.shiftName}"
                                                      : "---",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (attendance.shiftInfo != null && attendance.shiftInfo!.shiftType == 'flexibleShift')...[
                                              Text(
                                                maxLines: 5,
                                                attendance.shiftInfo != null &&
                                                    attendance.shiftInfo!.shiftName != null
                                                    ? "${attendance.shiftInfo!.shiftName}"
                                                    : "---",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                            if (attendance.shiftInfo != null &&
                                                attendance.shiftInfo!.shiftType == 'timeTableShift') ...[
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: attendance.slots!.take(2).map<Widget>((slot) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          "${singletonClass.formatCheckInTime(slot.slotStart , context)} - ${singletonClass.formatCheckInTime(slot.slotEnd, context)}",
                                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              )
                                            ],
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          "$breakTime ${AppLocalizations.of(context)!.minutes}",
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Icon(Icons.coffee,
                                            size: 20, color: Colors.brown),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                                    ),
                                    child: attendance.status != "On-Leave" ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                         children: [
                                           Text(
                                             AppLocalizations.of(context)!.checkIn,
                                             style: GoogleFonts.inter(
                                               fontSize: 13,
                                               fontWeight: FontWeight.bold,
                                               color: Colors.grey
                                             ),
                                           ),
                                           SizedBox(height: 5),
                                           Text(
                                             singletonClass.formatCheckInTime(
                                                 attendance.clockInTime , context),
                                             style: GoogleFonts.inter(
                                               fontSize: 13,
                                               fontWeight: FontWeight.bold,
                                               color:(lateMinutes != null && lateMinutes > 0) ? NasColors.pending : Colors.black,
                                             ),
                                           ),
                                         ],
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.checkOut,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              singletonClass.formatCheckInTime(
                                                  attendance.clockOutTime , context),
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color:(lateMinutes != null && lateMinutes > 0) ? NasColors.pending : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.late,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "${lateMinutes! ~/ 60}${AppLocalizations.of(context)!.h} ${lateMinutes % 60}${AppLocalizations.of(context)!.m}",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.pending,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.earlyLeft,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "${earlyCheckOut! ~/ 60}${AppLocalizations.of(context)!.h} ${earlyCheckOut % 60}${AppLocalizations.of(context)!.m}",
                                               style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.onTime,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ) : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.leaveType,
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "${attendance.leaveDetails!.requestInfo!.subType}",
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.startDate,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              singletonClass.formatDate2("${attendance.leaveDetails!.requestInfo!.requestData!.first.startDate}", context),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.endDate,
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              singletonClass.formatDate2("${attendance.leaveDetails!.requestInfo!.requestData!.first.endDate}", context),
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 5),
                                        Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.duration,
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "${attendance.leaveDetails!.requestInfo!.requestData!.first.duration}",
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ) : Center(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Lottie.asset('images/empty.json'),
                                  ),
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
                        )
                      );
                    })
            ),
        ],
      ),
    );
  }


  ///counter helper method
  int getCountForCard(int index) {
    if (filteredAttendanceDataList.isEmpty) return 0;

    switch (index) {
      case 0:
        return filteredAttendanceDataList.length;
      case 1:
        return filteredAttendanceDataList.where(
              (e) => (e.status?.toLowerCase() ?? "") == "present",
        ).length;
      case 2:
        return filteredAttendanceDataList.where(
              (e) => (e.status?.toLowerCase() ?? "") == "absent",
        ).length;
      case 4:
        return filteredAttendanceDataList.where((e) {
          final status = (e.status ?? "").toLowerCase().replaceAll('-', ' ');
          return status == "missing checkin/out" ||
              status == "missing checkin" ||
              status == "missing checkout" ||
              status == 'pending';
        }).length;
      case 5:
        return filteredAttendanceDataList.where(
              (e) => (e.lateMinutes ?? 0) > 0,
        ).length;
      case 6:
        return filteredAttendanceDataList.where(
              (e) => (e.earlyCheckOut ?? 0) > 0,
        ).length;
      case 3:
        return filteredAttendanceDataList.where((e) {
          final status = (e.status ?? "").toLowerCase().replaceAll('-', ' ');
          return status == "on-leave" ||
              status == "leave" ||
              status == "on leave";
        }).length;
      default:
        return 0;
    }
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null) return localizations.noData;

    switch (status) {
      case 'Absent':
        return localizations.absent;
      case 'Present':
        return localizations.present;
      case 'Quarterly':
        return localizations.quarterly;
      case 'Pending':
        return localizations.pending;
      case 'Missing CheckIn/Out':
        return localizations.missingCheckInOut;
      case 'On-Leave':
        return localizations.onLeaves;
      default:
        return status;
    }
  }
/// secondary status
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
      case 'annualLeave':
        return localizations.annualLeave;
      default:
        return status;
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


  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '---';
    try {
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString();
    } catch (e) {
      return '---';
    }
  }

  String minutesToHoursMinutes(int? totalMinutes) {
    if (totalMinutes == null || totalMinutes <= 0) return '---';

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
    } else if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h';
    } else {
      return '${minutes.toString().padLeft(2, '0')}m';
    }
  }


  Widget buildOptionsCard(int index, String title) {
    int count = getCountForCard(index);

    Color getTextColor() {
      if (_selectedOptionIndex == index) return Colors.white;
      switch (index) {
        case 0:
          return NasColors.darkBlue;
        case 1:
          return NasColors.completed;
        case 2:
          return NasColors.red;
        case 3:
          return NasColors.darkBlue;
        case 4:
          return NasColors.pending;
        case 5:
          return NasColors.pending;
        case 6:
          return NasColors.onTime;
        default:
          return NasColors.darkBlue;
      }
    }

    Color getCardColor() {
      if (_selectedOptionIndex != index) return Colors.white;
      switch (index) {
        case 0:
          return NasColors.darkBlue;
        case 1:
          return NasColors.completed;
        case 2:
          return NasColors.red;
        case 3:
          return NasColors.darkBlue;
        case 4:
          return NasColors.pending;
        case 5:
          return NasColors.pending;
        case 6:
          return NasColors.onTime;
        default:
          return NasColors.darkBlue;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
        filterAttendanceData();
      },
      child: SizedBox(
        height: 70,
        width: (index == 4 || index == 6) ? 210 : 160,
        child: Card(
          color: getCardColor(),
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(
              color: Colors.white,
              width: 0,
            ),
          ),
          child: Center(
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(),
                ),
              ),
            ),
            const SizedBox(width: 6),

            /// ✅ Circle badge for count
            _selectedOptionIndex == index ?
            Text(
              count.toString(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: getTextColor(),
              ),
            ) :
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getTextColor().withOpacity(0.2), // opacity 50%
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(),
                ),
              ),
            )
        ],
        ),
      ),

    ),
      ),
    );
  }

/// helper methods
  Future<void> _handleCheckboxChange(bool isChecked) async {
    try {
      singletonClass.teamAttendanceDataList.clear();
      selectedBranchIds.clear();

      if (!isChecked) {
        /// 🔁 UNCHECKED → Branch Mode

        if (singletonClass.branchDataList.isNotEmpty) {
          final firstBranch = singletonClass.branchDataList.first;

          singletonClass.branchID = firstBranch.data?.branch?.id;
          singletonClass.branchName = firstBranch.data?.branch?.branchName;

          await extractAllEmployeeIdsForBranch(singletonClass.branchID);
        }

        _isTeamChecked = false;
      } else {
        /// 🔁 ONLY ME MODE
        singletonClass.branchID = null;
        singletonClass.branchName = null;
        _isTeamChecked = false;
      }

      _initDates(start: _startDate!, end: _endDate!);

      /// ⚠️ Run in parallel where possible
      await Future.wait([
        singletonClass.getTeamBranchData(),
        loadData(),
      ]);

    } catch (e) {
      log("❌ Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}