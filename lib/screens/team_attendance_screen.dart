import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredUnderTeams = filteredData['underTeams']!;
    loadData();
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;

    // Debugging: print branch data
    print('Branch Data List length: ${branchDataList.length}');

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data?.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          // Check if the user is a supervisor in the department
          bool isSupervisor = department.supervisors?.any(
                  (supervisor) => supervisor.empId == reportingManagerId) ??
              false;
          print(
              'Is Supervisor: $isSupervisor, Reporting Manager ID: $reportingManagerId');

          if (userGrade == "L0" || userGrade == "L1") {
            // Supervisor with L0 or L1 grade
            for (var team in department.teams ?? []) {
              for (var supervisor in department.supervisors ?? []) {
                // Check if the supervisor empId matches the reportingManagerId
                if (supervisor.empId == reportingManagerId) {
                  // Now check if the supervisor's teamId matches the current team's teamId
                  if (supervisor.teamId == team.teamId) {
                    print(
                        'Adding subordinate team to underTeams based on supervisor empId and teamId match: ${team.teamId}');
                    underTeams.add(
                        team); // Add to underTeams if supervisor manages the team
                  }
                }
              }
            }
          } else if (userGrade == "L2" || userGrade == "L3") {}
        }
      }
    }
    // Return both lists in a map
    return {
      'underTeams': underTeams,
    };
  }

  Future<void> loadData() async {
    await getTeamAttendanceData();
    filterAttendanceData();
  }

  void filterAttendanceData() {
    List<TeamAttendanceData> filteredData = [];
    List<TeamAttendanceData>? allAttendanceData =
        singletonClass.teamAttendanceDataList.first.data;

    if (allAttendanceData != null && filteredUnderTeams.isNotEmpty) {
      for (var team in filteredUnderTeams) {
        var teamClocking = allAttendanceData
            .where((clocking) =>
                team.teamData?.any(
                    (member) => member.employeeId == clocking.employeeId) ??
                false)
            .toList();

        filteredData.addAll(teamClocking);
      }
    }

    if (selectedEmployeeId != null && selectedEmployeeId!.isNotEmpty) {
      filteredData = filteredData
          .where((clocking) => clocking.employeeId == selectedEmployeeId)
          .toList();
    }

    setState(() {
      filteredAttendanceDataList = filteredData;
    });
  }

  Future<TeamAttendanceModel?> getTeamAttendanceData() async {
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-attendance');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = TeamAttendanceModel.fromJson(responseBody);
      singletonClass.teamAttendanceDataList.addAll([attendance]);
      return attendance;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
            child: Column(
              children: [
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
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 180,
                      child: Text(
                        AppLocalizations.of(context)!.teamAttendance,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
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
                          filterAttendanceData(); // Call function to filter data
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return filteredUnderTeams.first.teamData!
                            .map((data) => PopupMenuItem<String>(
                                  value: data.employeeId,
                                  // Employee ID for filtering
                                  child: Text(data.userName ??
                                      "Unknown"), // Display employee name
                                ))
                            .toList();
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
                            const Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppLocalizations.of(context)!.filter,
                              textAlign: TextAlign.center,
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
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                  itemCount: filteredAttendanceDataList.length,
                  itemBuilder: (context, index) {
                    final attendance =
                        filteredAttendanceDataList.reversed.toList()[index];
                    String formatDate(String updatedAt) {
                      DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                      return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                    }

                    String date = formatDate(attendance.updatedAt!);
                    String lateMinutes = formatMinutes(attendance.lateMinutes);
                    String earlyCheckOut =
                        formatMinutes(attendance.earlyCheckOut);
                    String breakTime = formatMinutes(attendance.breakTime);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> TeamAttendanceDetailScreen(attendanceData: attendance)));
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
                                  height: attendance.status == "Missing CheckIn/Out" ? 30 : 20,
                                  width: attendance.status == "Missing CheckIn/Out" ? 120 : 75,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(attendance.status!),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _translateStatus(attendance.status, context),
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
                                Text(
                                  singletonClass.formatCheckInTime(
                                      attendance.clockInTime),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 5),
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
                                Text(
                                  "$lateMinutes ${AppLocalizations.of(context)!.minutes}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.pending,
                                  ),
                                ),
                                Icon(
                                  Icons.error,
                                  size: 20,
                                  color: NasColors.pending,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    singletonClass.formatCheckInTime(
                                        attendance.clockOutTime),
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
                                  "$earlyCheckOut ${AppLocalizations.of(context)!.minutes}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.onTime,
                                  ),
                                ),
                                Icon(
                                  Icons.directions_run_outlined,
                                  size: 20,
                                  color: NasColors.onTime,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  date,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
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
                                const Icon(
                                  Icons.coffee,
                                  size: 20,
                                  color: Colors.brown,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Check for null values
    if (status == null) {
      return localizations.noData;
    }

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
        return NasColors.onTime;
      case "Quarterly":
        return NasColors.pending;
      case "Missing CheckIn/Out":
        return NasColors.onTime;
      default:
        return NasColors.completed;
    }
  }

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
      print('Error parsing time: $e\n$timeString');
      return null;
    }
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '--';
    try {
      // Ensure the value is treated as a double and then round it
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes
          .ceil()
          .toString(); // Round up to the nearest integer
    } catch (e) {
      print('Error formatting minutes: $e');
      return '--';
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat("hh:mm a").format(dateTime); // Format as "02:30 PM"
  }
}
