import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'dart:math' as math;

class TeamAttendanceDetailScreen extends StatefulWidget {
  final TeamAttendanceData? attendanceData;

  const TeamAttendanceDetailScreen({super.key, this.attendanceData});

  @override
  State<TeamAttendanceDetailScreen> createState() =>
      _TeamAttendanceDetailScreenState();
}

class _TeamAttendanceDetailScreenState extends State<TeamAttendanceDetailScreen>
    with TickerProviderStateMixin {
  SingletonClass singletonClass = SingletonClass();
  bool _expanded = false;
  bool _leaveExpanded = false;
  bool _penalitiesExpanded = false;
  bool _slotsExpanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded; // Toggle the expanded state
    });
  }

  void _toggleLeaveExpand() {
    setState(() {
      _leaveExpanded = !_leaveExpanded;
    });
  }

  void _togglePenalitiesExpand() {
    setState(() {
      _penalitiesExpanded = !_penalitiesExpanded;
    });
  }

  void _toggleSlotsExpand() {
    setState(() {
      _slotsExpanded = !_slotsExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    String lateMinutes = formatMinutes(widget.attendanceData!.lateMinutes);
    String earlyMinutes = formatMinutes(widget.attendanceData!.earlyCheckOut);
    dynamic totalDurationMinutes = widget.attendanceData!.breaksTaken!.isEmpty
        ? 0.0
        : widget.attendanceData!.breaksTaken!
            .map((breakTaken) => breakTaken['durationMinutes'] ?? 0.0)
            .reduce((value, element) => value + element);

    String totalDurationString = formatMinutes(totalDurationMinutes.toString());
    final int workedMinutes = widget.attendanceData!.totalHoursWorked ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 48.0, left: 20, right: 20),
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // avoid taking full height
                      children: [
                        Text(
                          AppLocalizations.of(context)!.attendanceDetail,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                        Text(
                          singletonClass
                              .formatDate2(widget.attendanceData!.createdAt! , context),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ClipOval(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
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
                      SizedBox(
                        width: 130,
                        child: Text(
                          "${widget.attendanceData!.name}",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          if (widget.attendanceData!.status != null)
                            Container(
                              height: widget.attendanceData!.status == "Missing CheckIn/Out" ? 60 : 40,
                              width: 120,
                              decoration: BoxDecoration(
                                color: getStatusColor(widget.attendanceData!.status!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _translateStatus(widget.attendanceData!.status!, context),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: 5),

                          if (widget.attendanceData!.secondaryStatus != null)
                            Container(
                              height: widget.attendanceData!.secondaryStatus == "Missing-CheckOut" ? 60 : 40,
                              width: 120,
                              decoration: BoxDecoration(
                                color: getStatusColor(widget.attendanceData!.secondaryStatus!),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  translateSecondaryStatus(widget.attendanceData!.secondaryStatus!, context),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )

                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: NasColors.containerGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform(
                                transform: Matrix4.rotationY(math.pi),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.exit_to_app_outlined,
                                  size: 25,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.clockIn,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                singletonClass.formatCheckInTime(
                                    widget.attendanceData!.clockInTime , context),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 20),
                              Icon(
                                Icons.error,
                                size: 25,
                                color: NasColors.pending,
                              ),
                              Text(
                                AppLocalizations.of(context)!.late,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                lateMinutes,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.exit_to_app_outlined,
                                size: 25,
                                color: NasColors.darkBlue,
                              ),
                              Text(
                                AppLocalizations.of(context)!.clockOut,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                singletonClass.formatCheckInTime(
                                    widget.attendanceData!.clockOutTime , context),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.directions_run_outlined,
                                size: 25,
                                color: NasColors.onTime,
                              ),
                              Text(
                                AppLocalizations.of(context)!.earlyLeft,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                earlyMinutes,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.worked}:",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "${workedMinutes ~/ 60}${AppLocalizations.of(context)!.h} ${workedMinutes % 60}${AppLocalizations.of(context)!.m}",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 400,
                    decoration: BoxDecoration(
                      color: NasColors.containerGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _toggleExpand();
                                  },
                                  icon: Icon(Icons.close_fullscreen_outlined))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.coffee_rounded,
                                  size: 25, color: NasColors.darkBlue),
                              Text(
                                AppLocalizations.of(context)!.breakTaken,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${widget.attendanceData!.breaksTaken!.isNotEmpty && widget.attendanceData!.breaksTaken != null ? widget.attendanceData!.breaksTaken!.length : 0}', // Approver List Notification count
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (_expanded) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.breakNo,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.startTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.endTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.duration,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            widget.attendanceData!.breaksTaken!.isNotEmpty
                                ? SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: widget.attendanceData!
                                            .breaksTaken!.length,
                                        itemBuilder: (context, index) {
                                          final breakTaken = widget
                                              .attendanceData!
                                              .breaksTaken![index];
                                          DateTime? startTime = parseTime(
                                                  breakTaken['startTime']
                                                      .toString())
                                              ?.toLocal();
                                          DateTime? endTime = parseTime(
                                                  breakTaken['endTime']
                                                      .toString())
                                              ?.toLocal();
                                          String duration = formatMinutes(
                                              breakTaken['durationMinutes']);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                    color: NasColors.lightGrey,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child: Text(
                                                      "${index + 1}",
                                                      // Dynamically setting the break number
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 50,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                    color: NasColors.lightGrey,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child: Text(
                                                      formatDateTime(startTime),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 50,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                    color: NasColors.lightGrey,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0),
                                                    child: Text(
                                                      formatDateTime(endTime),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 50,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                    color: NasColors.lightGrey,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.4),
                                                        spreadRadius: 1,
                                                        blurRadius: 1,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Text(
                                                      duration,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Lottie.asset(
                                                  'images/empty.json'),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .noData,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 50,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.zero,
                                    color: NasColors.lightGrey,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.grey.withValues(alpha: 0.4),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .totalDuration,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: NasColors.darkBlue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 29),
                                Container(
                                  height: 50,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.zero,
                                    color: NasColors.lightGrey,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.grey.withValues(alpha: 0.4),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      totalDurationString,
                                      // Dynamically setting the break number
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: NasColors.darkBlue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 400,
                    decoration: BoxDecoration(
                      color: NasColors.containerGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _togglePenalitiesExpand();
                                  },
                                  icon: Icon(Icons.close_fullscreen_outlined))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!.penalties,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${widget.attendanceData!.penalties!.isNotEmpty && widget.attendanceData!.penalties != null ? widget.attendanceData!.penalties!.length : 0}', // Approver List Notification count
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          if (_penalitiesExpanded) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.category,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.details,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.value,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            widget.attendanceData!.penalties!.isNotEmpty
                                ? SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: widget
                                            .attendanceData!.penalties!.length,
                                        itemBuilder: (context, index) {
                                          final penalities = widget
                                              .attendanceData!
                                              .penalties![index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 15.0),
                                                    child: Text(
                                                      maxLines: 3,
                                                      overflow: TextOverflow.fade,
                                                      "${penalities.action}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.normal,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                const SizedBox(width: 5),
                                                Padding(
                                                    padding: const EdgeInsets.only(top: 15.0),
                                                    child: Text(
                                                      "${penalities.lateMinute}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                const SizedBox(width: 5),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Text(
                                                      "${penalities.percentage}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            NasColors.darkBlue,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        }),
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Lottie.asset(
                                                  'images/empty.json'),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .noData,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ]
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (widget.attendanceData!.shift == 'timeTableShift') ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 400,
                      decoration: BoxDecoration(
                        color: NasColors.containerGrey,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            // Shadow color
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: Offset(0, 3), // Shadow position (x, y)
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _toggleSlotsExpand();
                                    },
                                    icon: Icon(Icons.close_fullscreen_outlined))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/slots.png',
                                  fit: BoxFit.contain,
                                  width: 30,
                                  height: 30,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)!.slots,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '${widget.attendanceData!.slots!.isNotEmpty && widget.attendanceData!.slots != null ? widget.attendanceData!.slots!.length : 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (_slotsExpanded) ...[
                              const SizedBox(height: 10),
                              widget.attendanceData!.slots!.isNotEmpty
                                  ? SizedBox(
                                      height: 220,
                                      child:
                                          widget.attendanceData?.slots
                                                      ?.isNotEmpty ==
                                                  true
                                              ? ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: widget
                                                          .attendanceData
                                                          ?.slots
                                                          ?.length ??
                                                      0,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final slots = widget
                                                        .attendanceData!
                                                        .slots![index];

                                                    DateTime? checkIn =
                                                        parseTime(slots
                                                                    .checkInTime
                                                                    ?.toString() ??
                                                                '')
                                                            ?.toLocal();
                                                    DateTime? checkOut =
                                                        parseTime(slots
                                                                    .checkOutTime
                                                                    ?.toString() ??
                                                                '')
                                                            ?.toLocal();

                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.zero,
                                                          color: NasColors
                                                              .lightGrey,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.4),
                                                              spreadRadius: 1,
                                                              blurRadius: 1,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .exit_to_app_outlined,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              Colors.black),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "${AppLocalizations.of(context)!.clockIn}:",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        checkIn !=
                                                                                null
                                                                            ? "$checkIn"
                                                                            : "___",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          20),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .error,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              NasColors.pending),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "${AppLocalizations.of(context)!.late}:",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              NasColors.pending,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        (slots.lateMinutes?.toString().isNotEmpty ??
                                                                                false)
                                                                            ? "${slots.lateMinutes}"
                                                                            : "___",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              10),
                                                                      Container(
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            75,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              getStatusColor(slots.status ?? ''),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            _translateStatus(slots.status ?? '',
                                                                                context),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                GoogleFonts.inter(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white,
                                                                              fontSize: 10,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400),
                                                              Row(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Transform(
                                                                        transform:
                                                                            Matrix4.rotationY(math.pi),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child: const Icon(
                                                                            Icons
                                                                                .exit_to_app_outlined,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.black),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "${AppLocalizations.of(context)!.clockOut}:",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        checkOut !=
                                                                                null
                                                                            ? "$checkOut"
                                                                            : "___",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          20),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .directions_run_outlined,
                                                                          size:
                                                                              20,
                                                                          color:
                                                                              NasColors.onTime),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        "${AppLocalizations.of(context)!.earlyLeft}:",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              NasColors.onTime,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        (slots.earlyCheckOut?.toString().isNotEmpty ??
                                                                                false)
                                                                            ? "${slots.earlyCheckOut}"
                                                                            : "___",
                                                                        style: GoogleFonts
                                                                            .inter(
                                                                          fontSize:
                                                                              13,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Column(
                                                      children: [
                                                        Center(
                                                          child: SizedBox(
                                                            height: 200,
                                                            width: 200,
                                                            child: Lottie.asset(
                                                                'images/empty.json'),
                                                          ),
                                                        ),
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .noData,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: NasColors
                                                                .darkBlue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                  : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Lottie.asset(
                                                    'images/empty.json'),
                                              ),
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .noData,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 400,
                    decoration: BoxDecoration(
                      color: NasColors.containerGrey,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // Shadow position (x, y)
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  _toggleLeaveExpand();
                                },
                                icon: Icon(Icons.close_fullscreen_outlined))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/time.png',
                              fit: BoxFit.contain,
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.leaveInfo,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (_leaveExpanded) ...[
                          Text(
                            widget.attendanceData?.leaveDetails?.isNotEmpty ==
                                    true
                                ? widget.attendanceData!.leaveDetails!
                                : '___',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: NasColors.darkBlue,
                            ),
                          ),
                          SizedBox(height: 20),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/Comments.png',
                        fit: BoxFit.contain,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.remarks,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                      height: 80,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      // Adds padding to match the TextFormField's internal padding
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: Colors
                                .grey), // Same border as the TextFormField
                      ),
                      child: widget.attendanceData!.remarks ==
                              'Check-out time is missing Auto updated by system'
                          ? Text(
                              AppLocalizations.of(context)!
                                  .missingCheckInAndCheckOut,
                              maxLines: 5,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              widget.attendanceData!.remarks ?? '',
                              maxLines: 5,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Check for null values
    if (status == null || status.isEmpty) {
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

  ///secondary status translation
  String translateSecondaryStatus(String? status, BuildContext context) {
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


  DateTime? parseTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    DateTime dateTime = DateTime.parse(dateTimeString);
    return dateTime.toUtc();
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat("hh:mm a")
        .format(dateTime.toLocal()); // Convert before formatting
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '---';
    try {
      int totalMinutes =
          (minutes is int) ? minutes : int.parse(minutes.toString());
      int hours = totalMinutes ~/ 60;
      int remainingMinutes = totalMinutes % 60;

      if (hours > 0) {
        return '$hours ${AppLocalizations.of(context)!.h} $remainingMinutes ${AppLocalizations.of(context)!.m}';
      } else {
        return '$remainingMinutes ${AppLocalizations.of(context)!.m}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting minutes: $e');
      }
      return '---';
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
}
