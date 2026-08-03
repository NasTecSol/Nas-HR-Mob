import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

import '../widgets/loader.dart';

class MyClockingScreen extends StatefulWidget {
  const MyClockingScreen({super.key});

  @override
  State<MyClockingScreen> createState() => _MyClockingScreenState();
}

class _MyClockingScreenState extends State<MyClockingScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = true;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fetchClockingData();
  }

  Future<void> _fetchClockingData() async {
    try {
      await getClockingData();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching clocking data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateRange() async {
    DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      barrierColor: NasColors.darkBlue.withOpacity(0.5),
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
                foregroundColor: NasColors.darkBlue,
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: NasColors.darkBlue,
              onPrimary: Colors.white,
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
      getClockingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          /// Curved Gradient Header (NO icon in title text)
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NasColors.darkBlue,
                  NasColors.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: NasColors.darkBlue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.myClocking,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Date Range Filter Action Button
                GestureDetector(
                  onTap: () {
                    _selectDateRange();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Filter Date Range Badge Pill
          if (_fromDate != null && _toDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: NasColors.darkBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: NasColors.darkBlue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range_rounded,
                        size: 14, color: NasColors.darkBlue),
                    const SizedBox(width: 6),
                    Text(
                      "${DateFormat('dd/MM/yyyy').format(_fromDate!)} - ${DateFormat('dd/MM/yyyy').format(_toDate!)}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _fromDate = null;
                          _toDate = null;
                        });
                        getClockingData();
                      },
                      child: Icon(Icons.cancel_rounded,
                          size: 16, color: NasColors.darkBlue),
                    ),
                  ],
                ),
              ),
            ),

          /// Clocking Logs List
          Expanded(
            child: FutureBuilder<ClockingData?>(
              future: getClockingData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    isLoading) {
                  return const Loader();
                } else if (snapshot.hasError) {
                  return _buildErrorState();
                } else {
                  List<dynamic> clockingList = [];
                  try {
                    if (singletonClass.clockingDataList.isNotEmpty &&
                        singletonClass.clockingDataList.first.data != null) {
                      clockingList =
                          singletonClass.clockingDataList.first.data!;
                    }
                  } catch (_) {}

                  if (clockingList.isEmpty) {
                    return _buildEmptyState(local.noData);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await getClockingData();
                    },
                    color: NasColors.darkBlue,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: clockingList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final clock = clockingList[index];
                        final empIdStr = clock.empId?.toString() ?? "---";
                        final nameStr = clock.employeeName?.toString() ?? "---";
                        final statusStr = clock.status?.toString() ?? "---";
                        final typeStr = clock.type?.toString() ?? "---";
                        final dateStr = clock.createdAt != null
                            ? singletonClass.formatDate2(
                                clock.createdAt.toString(), context)
                            : "---";

                        final checkInTimeStr = clock.checkInTime != null
                            ? singletonClass.formatCheckInTime(
                                clock.checkInTime!, context)
                            : "--:--";

                        final checkOutTimeStr = clock.checkOutTime != null
                            ? singletonClass.formatCheckInTime(
                                clock.checkOutTime!, context)
                            : "--:--";

                        final rawBiometrics = clock.rawBiometrics ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                if (rawBiometrics.isNotEmpty) {
                                  _showBiometricsDialog(context, rawBiometrics);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    /// Top Header Row: ID Tag & Date
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: NasColors.darkBlue
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.tag_rounded,
                                                size: 13,
                                                color: NasColors.darkBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                empIdStr,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              dateStr,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    /// Name & Status Badge Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            nameStr,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        /// Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(statusStr),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: getStatusColor(statusStr)
                                                    .withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            _translateSecondaryStatus(
                                                statusStr, context),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(height: 1),
                                    ),

                                    /// Check-In Row
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.login_rounded,
                                            size: 16,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          checkInTimeStr,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: NasColors.onTime,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          typeStr,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    /// Check-Out Row & Total Records Badge
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            size: 16,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          checkOutTimeStr,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          local.totalRecord,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (rawBiometrics.length == 1 ||
                                                    rawBiometrics.length == 2)
                                                ? NasColors.onTime
                                                : Colors.red.shade600,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${rawBiometrics.length}',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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
                          ),
                        );
                      },
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

  /// Raw Biometrics Modal Dialog
  void _showBiometricsDialog(BuildContext context, List<dynamic> biometrics) {
    final local = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: NasColors.darkBlue,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  local.srNo,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  local.timeStamp,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  local.type,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: biometrics.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final bio = biometrics[index];
                final timeStr = bio.timestamp != null
                    ? singletonClass.formatCheckInTime(
                        bio.timestamp.toString(), context)
                    : "--:--";
                final bioTypeStr = bio.type?.toString() ?? "---";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          "${index + 1}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          bioTypeStr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                local.close,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
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

  /// API Call
  Future<ClockingData?> getClockingData() async {
    try {
      String? employeeId = singletonClass.getJWTModel()?.employeeId;
      var client = http.Client();
      DateTime now = DateTime.now();
      DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

      String fromDateString = _fromDate != null
          ? '${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}-${_fromDate!.year}'
          : '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';

      String toDateString = _toDate != null
          ? '${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}-${_toDate!.year}'
          : '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

      var uri = Uri.parse(
          '${singletonClass.baseURL}/c-emp-check-in-out/filter?employeeId=$employeeId&startDate=$fromDateString&endDate=$toDateString');
      var response =
          await client.get(uri, headers: singletonClass.getHeaders());
      if (kDebugMode) {
        print(uri);
      }
      log("ClockingData my clocking:${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var clockingData = ClockingData.fromJson(responseBody);
        singletonClass.setClockingData([clockingData]);
        return clockingData;
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching clocking data: $e");
    }
    return null;
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset('images/empty.json'),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NasColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SizedBox(
        height: 180,
        width: 180,
        child: Lottie.asset('images/error.json'),
      ),
    );
  }
}
