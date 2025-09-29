import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:nashr/l10n/app_localizations.dart';

class MyClockingScreen extends StatefulWidget {
  const MyClockingScreen({super.key});

  @override
  State<MyClockingScreen> createState() => _MyClockingScreenState();
}

class _MyClockingScreenState extends State<MyClockingScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClockingData();
  }

  Future<void> _fetchClockingData() async {
    try {
      getClockingData();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: IconButton(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                          child: Text(
                            AppLocalizations.of(context)!.myClocking,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                            icon: Icon(Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                            onPressed: () {
                              _selectDateRange();
                              getClockingData();
                            },
                          ),
                      ],
                    ),
                  ],
                ),

          ),
          Expanded(
            child: FutureBuilder<ClockingData?>(
              future: getClockingData(),
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
                    child: Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset('images/error.json'),
                      ),
                    ),
                  );
                } else if (snapshot.hasData &&
                    singletonClass.clockingDataList.isNotEmpty &&
                    singletonClass.clockingDataList.first.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    itemCount: singletonClass.clockingDataList.first.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final clock = singletonClass.clockingDataList.first.data![index];
                      return  GestureDetector(
                        onTap: () {
                          if (clock.rawBiometrics != null && clock.rawBiometrics!.isNotEmpty) {
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
                                            color: NasColors.onTime
                                        ),
                                        child: Center(child: Text(AppLocalizations.of(context)!.srNo,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Colors.white
                                          ),
                                        )),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 120,
                                        decoration: BoxDecoration(
                                            color: NasColors.onTime
                                        ),
                                        child: Center(child: Text(AppLocalizations.of(context)!.timeStamp,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Colors.white
                                          ),
                                        )),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            color: NasColors.onTime
                                        ),
                                        child: Center(child: Text(AppLocalizations.of(context)!.type,
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Colors.white
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: clock.rawBiometrics!.length,
                                      itemBuilder: (context, index) {
                                        final bio = clock.rawBiometrics![index];
                                        return  Row(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: 70,
                                              child: Center(
                                                  child: Text("${index + 1}",
                                                    style: GoogleFonts.inter(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                        color: Colors.black
                                                    ),
                                                  )),
                                            ),
                                            SizedBox(
                                              height: 40,
                                              width: 115,
                                              child: Center(child: Text(singletonClass.formatCheckInTime(bio.timestamp.toString(), context),
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    color: Colors.black
                                                ),
                                              )),
                                            ),
                                            SizedBox(
                                              height: 40,
                                              width: 80,
                                              child: Center(child: Text("${bio.type}",
                                                style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    color: Colors.black
                                                ),
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
                                      child: Text(AppLocalizations.of(context)!.close,
                                        style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red
                                        ),
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
                                      "${clock.empId}",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      singletonClass.formatDate2(clock.createdAt.toString() , context),
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
                                      "${clock.employeeName}",
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
                                        color: getStatusColor(clock.status.toString()),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _translateSecondaryStatus("${clock.status}", context),
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
                                      child: Text( clock.checkInTime != null ?
                                      singletonClass.formatCheckInTime(clock.checkInTime! , context) : '--:--',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
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
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color: NasColors.onTime,
                                    ),
                                    Text(
                                      "${clock.type}",
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
                                       width:70,
                                       child: Text( clock.checkOutTime != null ?
                                        singletonClass.formatCheckInTime(clock.checkOutTime! ,context) : '--:--',
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
                                    Text( AppLocalizations.of(context)!.totalRecord,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),),
                                    SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: (clock.rawBiometrics!.length == 1 ||clock.rawBiometrics!.length == 2) ? NasColors.onTime : Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 28,
                                        minHeight: 28,
                                      ),
                                      child: Text(
                                        '${clock.rawBiometrics!.length}',
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
                  );
                } else {
                  return Center(
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
                }
              },
            ),
          ),
        ],
      ),
    );
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
  Future<ClockingData?> getClockingData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
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

    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/filter?employeeId=$employeeId&startDate=$fromDateString&endDate=$toDateString');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    if (kDebugMode) {
      print(uri);
    }
    log("ClockingData my clocking:${response.body}");
    log(fromDateString);
    log(toDateString);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var clockingData = ClockingData.fromJson(responseBody);
      singletonClass.setClockingData([clockingData]);
      return clockingData;
    }
    return null ;
  }
}
