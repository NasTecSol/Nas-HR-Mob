import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/attendance_detail_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
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
  void initState() {
    super.initState();

  }

  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _selectDateRange() async {
    DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      barrierColor: NasColors.darkBlue,
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      firstDate: DateTime(2000),
      lastDate: now,
      saveText: AppLocalizations.of(context)!.ok,
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
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
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
                    Text(
                      AppLocalizations.of(context)!.attendance,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
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
                          _selectDateRange();
                          getAttendanceData();
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
                    singletonClass.attendanceDataList.first.data!.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount:  singletonClass.attendanceDataList.first.data!.data!.length,
                    itemBuilder: (context, index) {
                      final attendance = singletonClass.attendanceDataList.first.data!.data![index];
                      String formatDate(String updatedAt) {
                        DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                        return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                      }
                      String date = formatDate(attendance.updatedAt!);
                      String lateMinutes = formatMinutes(attendance.lateMinutes);
                      String earlyCheckOut = formatMinutes(attendance.earlyCheckOut);
                      String breakTime = formatMinutes(attendance.breakTime);


                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> AttendanceDetailScreen(attendanceData: attendance)));
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
                                    singletonClass.getJWTModel()?.userName ?? "",
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
                                        _translateStatus(attendance.status , context),
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
                                    singletonClass.formatCheckInTime(attendance.clockInTime!),
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
                                    singletonClass.formatCheckInTime(attendance.clockOutTime!),
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
                                  Spacer(),
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

  Future<AttendanceData?> getAttendanceData({
    int limit = 31,
    int page = 0,
  }) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    print(employeeId);
    var client = http.Client();

    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

    // Use selected dates if available; otherwise, use defaults
    String fromDateString = _fromDate != null
        ? '${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}-${_fromDate!.year}'
        : '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';

    String toDateString = _toDate != null
        ? '${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}-${_toDate!.year}'
        : '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$employeeId/$toDateString/$fromDateString?limit=$limit&page=$page');

    print(toDateString);
    print(fromDateString);
    var response = await client.get(uri);
    log("Attendance of login user${response.body}");
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
      double roundedMinutes = (minutes is int) ? minutes.toDouble() : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString(); // Round up to the nearest integer
    } catch (e) {
      return '--';
    }
  }



  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat("hh:mm a").format(dateTime); // Format as "02:30 PM"
  }
}
