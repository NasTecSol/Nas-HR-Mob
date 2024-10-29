import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamClocking extends StatefulWidget {
  const TeamClocking({super.key});

  @override
  State<TeamClocking> createState() => _TeamClockingState();
}

class _TeamClockingState extends State<TeamClocking> {
  SingletonClass singletonClass = SingletonClass();

  @override
  Widget build(BuildContext context) {
    final teamClocking = singletonClass.clockingDataList.first.data;

    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20),
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
                              color: Colors.grey.withOpacity(0.4),
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
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: NasColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // Add your onPressed functionality here
                    },
                    child: SizedBox(
                      height: 30,
                      width: 90,
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
                  future: singletonClass.getClockingData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      return singletonClass.clockingDataList.first.data!.isEmpty
                          ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                              itemCount: teamClocking?.length,
                              itemBuilder: (BuildContext context, int index) {
                                final team = teamClocking![index];
                                final shift = singletonClass
                                    .branchDataList
                                    .first
                                    .data
                                    ?.departmentDetails
                                    ?.first
                                    .shifts;

                                // Parse shift times and clock times for the current index
                                DateTime? checkInTime =
                                    parseTime(team.checkInTime ?? '');
                                DateTime? checkOutTime =
                                    parseTime(team.checkOutTime ?? '');
                                DateTime? shiftFromTime =
                                    parseTime(shift!.first.timeFrom ?? '');
                                DateTime? shiftToTime =
                                    parseTime(shift.first.timeTo ?? '');

                                // Calculate late and early durations
                                var lateDuration = checkInTime != null &&
                                        shiftFromTime != null &&
                                        checkInTime.isAfter(shiftFromTime)
                                    ? checkInTime.difference(shiftFromTime)
                                    : Duration.zero;
                                var earlyDuration = checkOutTime != null &&
                                        shiftToTime != null &&
                                        checkOutTime.isBefore(shiftToTime)
                                    ? shiftToTime.difference(checkOutTime)
                                    : Duration.zero;

                                // Get user status
                                String status =
                                    getStatus(lateDuration, earlyDuration);

                                // Format Check-In and Check-Out Times
                                String formattedCheckInTime =
                                    team.checkInTime != null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(team.checkInTime!))
                                        : "N/A";
                                String formattedCheckOutTime =
                                    team.checkOutTime != null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(team.checkOutTime!))
                                        : "N/A";

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                            Text(
                                              formattedCheckInTime,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Transform(
                                              transform:
                                                  Matrix4.rotationY(math.pi),
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
                                              child: Text(
                                                formattedCheckOutTime,
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
                    } else {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.noData,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }
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
      print('Error parsing time: $e\n$timeString');
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
}
