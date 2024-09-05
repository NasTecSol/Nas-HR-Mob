import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Container(
                        height: 50,
                        width: 50,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                    child: Text(
                      AppLocalizations.of(context)!.teamClocking,
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: TextButton(
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
                        width: 100,
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
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: teamClocking?.length,
                  itemBuilder: (BuildContext context, int index) {
                    final team = teamClocking![index];
                    final shift = singletonClass.branchDataList.first.data?.departmentDetails?.first.shifts;

                    // Parse shift times and clock times for the current index
                    DateTime? checkInTime = parseTime(team.checkInTime ?? '');
                    DateTime? checkOutTime = parseTime(team.checkOutTime ?? '');
                    DateTime? shiftFromTime = parseTime(shift!.first.timeFrom ?? '');
                    DateTime? shiftToTime = parseTime(shift.first.timeTo ?? '');

                    // Calculate late and early durations
                    var lateDuration = checkInTime != null && shiftFromTime != null && checkInTime.isAfter(shiftFromTime)
                        ? checkInTime.difference(shiftFromTime)
                        : Duration.zero;
                    var earlyDuration = checkOutTime != null && shiftToTime != null && checkOutTime.isBefore(shiftToTime)
                        ? shiftToTime.difference(checkOutTime)
                        : Duration.zero;

                    // Format durations as minutes
                    String formatDuration(Duration duration) {
                      if (duration.inMinutes >= 60) {
                        int hours = duration.inHours;
                        int minutes = duration.inMinutes % 60;
                        return minutes > 0 ? "$hours hr $minutes mins" : "$hours hr";
                      } else {
                        return "${duration.inMinutes} Mins";
                      }
                    }

                    String lateMinutes = formatDuration(lateDuration);
                    String earlyMinutes = formatDuration(earlyDuration);

                    // Format Check-In and Check-Out Times
                    String formattedCheckInTime = team.checkInTime != null
                        ? DateFormat('hh:mm a').format(DateTime.parse(team.checkInTime!))
                        : "N/A";
                    String formattedCheckOutTime = team.checkOutTime != null
                        ? DateFormat('hh:mm a').format(DateTime.parse(team.checkOutTime!))
                        : "N/A";

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
                                    color: NasColors.pending,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Late",
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
                                  transform: Matrix4.rotationY(math.pi),
                                  // Flip horizontally
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.exit_to_app_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  lateMinutes,
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
                                Spacer(),
                                SizedBox(
                                  child: Text(
                                    earlyMinutes,
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
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
    );
  }
  DateTime? parseTime(String timeString) {
    try {
      // Remove the date part and milliseconds, and timezone offset, if present
      final timeOnlyString = timeString.contains('T')
          ? timeString.split('T')[1].split('.')[0] // Handles '2024-09-04T09:30:30.617515Z'
          : timeString.split('.')[0]; // Handles '09:00:00.000+00:00'

      // Parse the cleaned time string in 'HH:mm:ss' format
      final timeFormat = DateFormat.Hms(); // 'HH:mm:ss'
      DateTime now = DateTime.now();
      DateTime parsedTime = timeFormat.parse(timeOnlyString);

      // Combine parsed time with the current date
      return DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute, parsedTime.second);
    } catch (e) {
      print('Error parsing time: $e\n$timeString');
      return null; // Return null if parsing fails
    }
  }
}
