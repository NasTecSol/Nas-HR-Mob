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

  @override
  void initState() {
    super.initState();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredUnderTeams = filteredData['underTeams']!;
    loadData();
  }

  Future<void> loadData() async {
    await getTeamClockingAPI();
    filterClockingData();
    setState(() {});
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;
    if (kDebugMode) {
      print('Branch Data List length: ${branchDataList.length}');
    }

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data!.branch!.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          bool isSupervisor = department.supervisors?.any(
                  (supervisor) => supervisor.empId == reportingManagerId) ??
              false;
          if (kDebugMode) {
            print(
              'Is Supervisor: $isSupervisor, Reporting Manager ID: $reportingManagerId');
          }

          if (userGrade == "L0" || userGrade == "L1" || userGrade == "L2" || userGrade == "L3") {
            for (var team in department.teams ?? []) {
              for (var supervisor in department.supervisors ?? []) {
                if (supervisor.empId == reportingManagerId) {
                  if (supervisor.teamId == team.teamId) {
                    if (kDebugMode) {
                      print(
                        'Adding subordinate team to underTeams based on supervisor empId and teamId match: ${team.teamId}');
                    }
                    underTeams.add(
                        team);
                  }
                }
              }
            }
          } else if (userGrade == "L4") {}
        }
      }
    }
    // Return both lists in a map
    return {
      'underTeams': underTeams,
    };
  }

  void filterClockingData() {
    String loggedInEmployeeId = singletonClass.getJWTModel()?.employeeId ?? '';
    log("Logged-in Employee ID: $loggedInEmployeeId");

    List<TeamClockingData> filteredClockingData = [];

    // Filter based on team membership
    for (var team in filteredUnderTeams) {
      var teamClocking = singletonClass.teamClockingDataList.first.data
          ?.where((clocking) =>
              team.teamData
                  ?.any((member) => member.employeeId == clocking.employeeId) ??
              false)
          .toList();

      if (teamClocking != null) {
        filteredClockingData.addAll(teamClocking);
      }
    }

    // If an employee is selected, refine the filtered data
    if (selectedEmployeeId != null && selectedEmployeeId!.isNotEmpty) {
      filteredClockingData = filteredClockingData
          .where((clocking) => clocking.employeeId == selectedEmployeeId)
          .toList();
    }

    setState(() {
      filteredClockingDataList = filteredClockingData;
    });

    // Log the filtered clocking data
    log("Filtered Clocking Data: ${jsonEncode(filteredClockingDataList.map((data) => {
          "employeeId": data.employeeId,
          "employeeName": data.employeeName,
          "checkInTime": data.checkInTime
        }).toList())}");
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
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onSelected: (value) {
                      setState(() {
                        selectedEmployeeId = value;
                        filterClockingData(); // Call function to filter data
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return filteredUnderTeams.first.teamData!
                          .map((data) => PopupMenuItem<String>(
                        value: data.employeeId, // Employee ID for filtering
                        child: Text(data.userName ?? "Unknown"), // Display employee name
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
              FutureBuilder(
                  future: getTeamClockingAPI(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'),
                        ),
                      );
                    } else if (filteredClockingDataList.isEmpty) {
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

                    return Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredClockingDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = filteredClockingDataList.reversed.toList()[index];
                        final shift = singletonClass.branchDataList.first.data?.branch!.departmentDetails?.first.shifts;
                        DateTime? checkInTime = parseTime(team.checkInTime ?? '');
                        DateTime? checkOutTime = parseTime(team.checkOutTime ?? '');
                        DateTime? shiftFromTime = parseTime(shift!.first.timeFrom ?? '');
                        DateTime? shiftToTime = parseTime(shift.first.timeTo ?? '');
                        Duration lateDuration = Duration.zero;
                        if (checkInTime != null && shiftFromTime != null) {
                          var policyData = singletonClass.policyModelDataList.isNotEmpty
                              ? singletonClass.policyModelDataList.first.data
                              : null;
                          var attendancePolicy = policyData?.attendancePolicy;
                          var lateComingsPolicy = attendancePolicy?.lateComingsPolicy;
                          int? graceMinutes = lateComingsPolicy?.gracePeriodMinutes;
                          if (graceMinutes != null) {
                            Duration gracePeriod = Duration(minutes: graceMinutes);
                            DateTime graceEndTime = shiftFromTime.add(gracePeriod);
                            if (checkInTime.isAfter(graceEndTime)) {
                              lateDuration = checkInTime.difference(graceEndTime);
                            }
                          }
                        }
                        var earlyDuration = checkOutTime != null &&
                                shiftToTime != null &&
                                checkOutTime.isBefore(shiftToTime)
                            ? shiftToTime.difference(checkOutTime)
                            : Duration.zero;
                        // Get user status
                        String status = getStatus(lateDuration, earlyDuration);


                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      singletonClass.formatDate2(team.createdAt.toString()),
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
                                        color: getStatusColor(status),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          status,
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
                                    Text( team.checkInTime != null ?
                                      singletonClass.formatCheckInTime(team.checkInTime!) : 'N/A',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Transform(
                                      transform: Matrix4.rotationY(math.pi),
                                      // Flip horizontally
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.exit_to_app_outlined,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "${lateDuration.inMinutes} Mins",
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
                                    const SizedBox(width: 5),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: Text( team.checkOutTime != null ?
                                        singletonClass.formatCheckInTime(team.checkOutTime!) : 'N/A',
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
                                    SizedBox(
                                      child: Text(
                                        "${earlyDuration.inMinutes} Mins",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.onTime,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.directions_run_outlined,
                                      size: 20,
                                      color: NasColors.onTime,
                                    ),
                                  ],
                                ),
                              ],
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

  // Method to determine the user status based on late and early times
  String getStatus(Duration lateDuration, Duration earlyDuration) {
    if (lateDuration.inMinutes > 0) {
      return "Late";
    } else if (earlyDuration.inMinutes > 0) {
      return "Early";
    } else {
      return "On Time";
    }
  }

  // Helper method to get color based on the status
  Color getStatusColor(String status) {
    switch (status) {
      case "Late":
        return NasColors.pending;
      case "Early":
        return NasColors.onTime;
      default:
        return NasColors.completed;
    }
  }

  //API CALL
  Future<TeamClockingModel?> getTeamClockingAPI() async {
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/all');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log("Team ClockingData:${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var teamClocking = TeamClockingModel.fromJson(responseBody);
      singletonClass.teamClockingDataList.addAll([teamClocking]);
      return teamClocking;
    }
    return null; // Print the response body
  }
}
