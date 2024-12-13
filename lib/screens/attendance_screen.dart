import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import '../request_controller/attendance_model.dart';
import '../singleton_class.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  SingletonClass singletonClass = SingletonClass();

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
                      AppLocalizations.of(context)!.attendance,
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<AttendanceData?>(
              future: getAttendanceData(),
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
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (snapshot.hasData &&
                    singletonClass.attendanceDataList.isNotEmpty &&
                    singletonClass.attendanceDataList.first.data!.isNotEmpty) {
                  final attendanceList = singletonClass.attendanceDataList.first.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final attendance = attendanceList[index];

                      // Parsing and formatting the time values
                      DateTime? checkInTime = parseTime(attendance.clockInTime);
                      DateTime? checkOutTime = parseTime(attendance.clockOutTime);
                      String lateMinutes = formatMinutes(attendance.lateMinutes);
                      String earlyCheckOut = formatMinutes(attendance.earlyCheckOut);


                      return Container(
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
                                  singletonClass.getJWTModel()?.userName ?? "",
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
                                    color: getStatusColor(attendance.status),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      attendance.status,
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
                                  formatDateTime(checkInTime),
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
                                  "$lateMinutes Mins",
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
                                    formatDateTime(checkOutTime),
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
                                  "$earlyCheckOut Mins",
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
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noData,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<AttendanceData?> getAttendanceData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var client = http.Client();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String firstDateString =
        '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString =
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$employeeId/$currentDateString/$firstDateString');

    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = AttendanceData.fromJson(responseBody);
      singletonClass.setAttendanceData([attendance]);
      return attendance;
    }
    return null;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Absent":
        return NasColors.pending;
      case "Present":
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
      double roundedMinutes = (minutes is int) ? minutes.toDouble() : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString(); // Round up to the nearest integer
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
