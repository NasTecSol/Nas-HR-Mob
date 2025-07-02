import 'dart:convert';
import 'dart:developer';
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
import 'dart:math' as math;
import '../request_controller/branch_model.dart';

class TeamAttendanceScreen extends StatefulWidget {
  const TeamAttendanceScreen({super.key});

  @override
  State<TeamAttendanceScreen> createState() => _TeamAttendanceScreenState();
}

class _TeamAttendanceScreenState extends State<TeamAttendanceScreen> {
  final SingletonClass singletonClass = SingletonClass();

  late String reportingManagerId;
  late List<Teams> filteredUnderTeams;
  List<TeamAttendanceData> filteredAttendanceDataList = [];
  String? selectedEmployeeId;
  DateTime? _selectedDate;
  int? _selectedDateIndex;
  final List<DateTime> _dates = [];
  Set<String> selectedBranchIds = {};
  DateTime? _startDate;
  String? selectedBranchName;
  String? selectedBranchId;
  DateTime? _endDate;

  @override
   void initState() {
    super.initState();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    log("🟢 Logged-in Reporting Manager ID: $reportingManagerId");

    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredUnderTeams = filteredData['underTeams']!;
    log("🔍 Filtered ${filteredUnderTeams.length} underTeams");

    _setDefaultDates();
    _initDates(start: _startDate!, end: _endDate!);
    loadData();
  }

  void extractAllEmployeeIdsForBranch(String? selectedBranchId) {
    List<String> allEmployeeIds = [];

    if ((selectedBranchId != null && selectedBranchId.isNotEmpty)){
      final branches = singletonClass.branchesDataList.first.data;
      final branchList = branches?.where((branch) => branch.branchCompanyId == selectedBranchId).toList();

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
      print('✅ Total Employee IDs: ${allEmployeeIds.length}');
      print('🔍 All IDs Set: $selectedBranchIds');
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

    for (var date = start; !date.isAfter(end) && !date.isAfter(now); date = date.add(Duration(days: 1))) {
      _dates.add(date);
    }

    _selectedDateIndex = null;
    _selectedDate = null;

    log("📅 Generated ${_dates.length} dates from $start to $end");
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

    if (grade == 'L0' || grade == 'L1') {
      if (selectedBranchIds.isNotEmpty) {
        employeeIds = selectedBranchIds;
      } else if (selectedBranchId == null || selectedBranchId!.isEmpty) {
        for (var team in filteredUnderTeams) {
          log("👥 Checking team: ${team.teamId}");
          if (team.teamData != null) {
            for (var member in team.teamData!) {
              if (member.employeeId != null && member.employeeId!.isNotEmpty) {
                employeeIds.add(member.employeeId!);
                log(" - Found Employee ID: ${member.employeeId}");
              } else {
                log(" - ⚠️ Empty employeeId in team: ${team.teamId}");
              }
            }
          } else {
            log(" - ⚠️ teamData is null for team: ${team.teamId}");
          }
        }
      }
    }

    if (grade == 'L2' || grade == 'L3') {
      for (var team in filteredUnderTeams) {
        log("👥 Checking team: ${team.teamId}");
        if (team.teamData != null) {
          for (var member in team.teamData!) {
            if (member.employeeId != null && member.employeeId!.isNotEmpty) {
              employeeIds.add(member.employeeId!);
              log(" - Found Employee ID: ${member.employeeId}");
            } else {
              log(" - ⚠️ Empty employeeId in team: ${team.teamId}");
            }
          }
        } else {
          log(" - ⚠️ teamData is null for team: ${team.teamId}");
        }
      }
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

    if (selectedEmployeeId != null) {
      filtered = filtered.where((e) => e.employeeId == selectedEmployeeId).toList();
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
      filteredAttendanceDataList = filtered;
    });
  }


  String _getDayOfWeek(DateTime date) {
    return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
  }


  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context)!.teamAttendance,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onSelected: (value) {
                    setState(() {
                      selectedEmployeeId = value;
                    });
                    filterAttendanceData();
                  },
                  itemBuilder: (BuildContext context) {
                    final grade = singletonClass.getJWTModel()?.grade;
                    List<PopupMenuEntry<String>> items = [];

                    if (grade == 'L0' || grade == 'L1') {
                      // Use selectedBranchIds to find employee names
                      final branches = singletonClass.branchesDataList.first.data;
                      final branchEmployees = <Map<String, dynamic>>[];

                      for (var branch in branches ?? []) {
                        for (var deptGroup in branch.departmentDetails ?? []) {
                          for (var dept in deptGroup.departments ?? []) {
                            for (var team in dept.teams ?? []) {
                              for (var emp in team['teamData'] ?? []) {
                                if (selectedBranchIds.contains(emp['employeeId'])) {
                                  branchEmployees.add(emp);
                                }
                              }
                            }
                          }
                        }
                      }

                      items = branchEmployees.map((emp) {
                        return PopupMenuItem<String>(
                          value: emp['employeeId'],
                          child: Text(emp['userName'] ?? 'Unknown'),
                        );
                      }).toList();
                    } else if (grade == 'L2' || grade == 'L3') {
                      items = filteredUnderTeams.first.teamData!
                          .map((data) => PopupMenuItem<String>(
                        value: data.employeeId,
                        child: Text(data.userName ?? "Unknown"),
                      ))
                          .toList();
                    }

                    return items;
                  },
                  child: Container(
                    height: 30,
                    width: 90,
                    decoration: BoxDecoration(
                      color: NasColors.darkBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_alt, color: Colors.white, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.filter,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1' || singletonClass.getJWTModel()?.grade == "L2")
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
                  child: PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onSelected: (value) {
                      setState(() {
                        selectedBranchId = value;
                        final branch = singletonClass.branchesDataList.first.data?.firstWhere((branch) => branch.branchCompanyId == value);
                        selectedBranchName = branch?.branchName ?? "Unknown Branch";
                        print('Selected Branch ID: $value');
                        extractAllEmployeeIdsForBranch(value);
                        getTeamAttendanceData();
                        loadData();
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      final branchList = singletonClass.branchesDataList.first.data;
                      if (branchList == null || branchList.isEmpty) {
                        return [];
                      }

                      return branchList.map((branch) => PopupMenuItem<String>(
                        value: branch.branchCompanyId,
                        child: Text(branch.branchName ?? "Unknown Branch"),
                      )).toList();
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        color: NasColors.darkBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              selectedBranchName != null && selectedBranchName!.isNotEmpty
                                  ? selectedBranchName!
                                  : "${singletonClass.branchDataList.first.data!.branch!.branchName}",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              Spacer(),
              TextButton.icon(
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
                    initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
                  );
                  if (picked != null) {
                    _startDate = picked.start;
                    _endDate = picked.end;
                    _initDates(start: picked.start, end: picked.end);
                    await getTeamAttendanceData(startDate: _startDate!, endDate: _endDate!);
                    filterAttendanceData();
                  }
                },
                icon:  Icon(Icons.date_range,color: NasColors.darkBlue,),
                label: Text(
                  AppLocalizations.of(context)!.selectDate,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
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
                      color: selected ? NasColors.darkBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${date.day}",
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: selected ? Colors.white : Colors.grey)),
                        Text(_getDayOfWeek(date),
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
          Expanded(
              child: FutureBuilder(
                  future: getTeamAttendanceData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Lottie.asset('images/loader.json',
                            height: 200, width: 200),
                      );
                    } else if (filteredAttendanceDataList.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.noData),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount:filteredAttendanceDataList.length,
                      itemBuilder: (ctx, i) {
                        final attendance = filteredAttendanceDataList[i];

                        String formatDate(String updatedAt) {
                          DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                          return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                        }
                        String date = formatDate(attendance.updatedAt!);
                        int? lateMinutes = int.tryParse(formatMinutes(attendance.lateMinutes));
                        int? earlyCheckOut = int.tryParse(formatMinutes(attendance.earlyCheckOut));
                        String breakTime = formatMinutes(attendance.breakTime);

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
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      attendance.name ?? "N/A",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      height: attendance.status ==
                                              "Missing CheckIn/Out"
                                          ? 30
                                          : 20,
                                      width: attendance.status ==
                                              "Missing CheckIn/Out"
                                          ? 120
                                          : 75,
                                      decoration: BoxDecoration(
                                        color:
                                            getStatusColor(attendance.status!),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _translateStatus(
                                              attendance.status, context),
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
                                    const Icon(Icons.exit_to_app_outlined,
                                        size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      singletonClass.formatCheckInTime(
                                          attendance.clockInTime),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    if ((lateMinutes == null || lateMinutes <= 0) &&
                                        (earlyCheckOut == null || earlyCheckOut <= 0) && (attendance.status == 'Present' || attendance.status == 'Missing CheckIn/Out')) ...[
                                      Text(
                                        "✅",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],

                                    if (lateMinutes != null && lateMinutes > 0)...[
                                    Text(
                                      "$lateMinutes ${AppLocalizations.of(context)!.minutes}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.pending,
                                      ),
                                    ),
                                    Icon(Icons.error,
                                        size: 20, color: NasColors.pending),]
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Transform(
                                      transform: Matrix4.rotationY(math.pi),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.exit_to_app_outlined,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      singletonClass.formatCheckInTime(
                                          attendance.clockOutTime),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    if ((lateMinutes == null || lateMinutes <= 0) &&
                                        (earlyCheckOut == null || earlyCheckOut <= 0) && (attendance.status == 'Present' || attendance.status == 'Missing CheckIn/Out')) ...[
                                      Text(
                                        "${formatMinutes(attendance.totalHoursWorked)} ${AppLocalizations.of(context)!.minutes}",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    if (earlyCheckOut != null && earlyCheckOut > 0)...[
                                    Text(
                                      "$earlyCheckOut ${AppLocalizations.of(context)!.minutes}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.onTime,
                                      ),
                                    ),
                                    Icon(Icons.directions_run_outlined,
                                        size: 20, color: NasColors.onTime),]
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(date,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
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
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  })),
        ],
      ),
    );
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
      case 'Missing CheckIn/Out':
        return localizations.missingCheckInOut;
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Absent":
        return NasColors.red;
      case "Present":
        return NasColors.completed;
      case "Quarterly":
        return NasColors.pending;
      case "Missing CheckIn/Out":
        return NasColors.pending;
      default:
        return NasColors.completed;
    }
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '--';
    try {
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString();
    } catch (e) {
      return '--';
    }
  }
}
