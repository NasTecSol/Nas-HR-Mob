import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'dart:math' as math;

class TeamAttendanceDetailScreen extends StatefulWidget {
  final TeamAttendanceData? attendanceData;
  const TeamAttendanceDetailScreen({super.key, this.attendanceData});

  @override
  State<TeamAttendanceDetailScreen> createState() => _TeamAttendanceDetailScreenState();
}

class _TeamAttendanceDetailScreenState extends State<TeamAttendanceDetailScreen> with TickerProviderStateMixin{
  SingletonClass singletonClass = SingletonClass();
  bool _expanded = false;
  bool _leaveExpanded = false;
  bool _penalitiesExpanded = false;
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

    return  Scaffold(
      backgroundColor: Colors.white,
      body: Padding(padding: const EdgeInsets.only(top: 48.0, left: 20, right: 20),
        child:Column(
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
                      mainAxisSize: MainAxisSize.min, // avoid taking full height
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
                          singletonClass.formatDate2(widget.attendanceData!.createdAt!),
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
                      Text("${widget.attendanceData!.name}",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      Spacer(),
                      Container(
                        height:
                        widget.attendanceData!.status == "Missing CheckIn/Out"
                            ? 60
                            : 40,
                        width:
                        widget.attendanceData!.status == "Missing CheckIn/Out"
                            ? 120
                            : 120,
                        decoration: BoxDecoration(
                          color: getStatusColor(widget.attendanceData!.status!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _translateStatus(
                                widget.attendanceData!.status, context),
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
                    child:Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform(
                                transform: Matrix4.rotationY(math.pi),
                                alignment: Alignment.center,
                                child:  Icon(
                                  Icons.exit_to_app_outlined,
                                  size: 25,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              Text(AppLocalizations.of(context)!.clockIn,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),),
                              SizedBox(width: 20),
                              Text(singletonClass.formatCheckInTime(widget.attendanceData!.clockInTime),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),),
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
                              Text(AppLocalizations.of(context)!.clockOut,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),),
                              SizedBox(width: 20),
                              Text(singletonClass.formatCheckInTime(widget.attendanceData!.clockOutTime),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),),
                              SizedBox(width: 20),
                              Icon(
                                Icons.directions_run_outlined,
                                size: 25,
                                color: NasColors.onTime,
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .earlyLeft,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              SizedBox(width: 10),
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
                                "${widget.attendanceData!.totalHoursWorked}",
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
                                IconButton(onPressed: (){
                                  _toggleExpand();
                                }, icon: Icon(Icons.close_fullscreen_outlined))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.coffee_rounded,
                                    size: 25,
                                    color: NasColors.darkBlue),
                                Text(AppLocalizations.of(context)!.breakTaken,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if(_expanded)...[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!.breakNo,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  Text(AppLocalizations.of(context)!.startTime,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  Text(AppLocalizations.of(context)!.endTime,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  Text(AppLocalizations.of(context)!.duration,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              widget.attendanceData!.breaksTaken!.isNotEmpty ?
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,

                                    itemCount: widget.attendanceData!.breaksTaken!.length,
                                    itemBuilder: (context , index){
                                      final breakTaken = widget.attendanceData!.breaksTaken![index];
                                      DateTime? startTime = parseTime(breakTaken['startTime'].toString())?.toLocal();
                                      DateTime? endTime = parseTime(breakTaken['endTime'].toString())?.toLocal();
                                      String duration = formatMinutes(breakTaken['durationMinutes']);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.zero,
                                                color: NasColors.lightGrey,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withValues(alpha: 0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child:  Padding(
                                                padding: const EdgeInsets.only(top: 15.0),
                                                child: Text(
                                                  "${index + 1}", // Dynamically setting the break number
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.normal,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 50,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.zero,
                                                color: NasColors.lightGrey,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withValues(alpha: 0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 15.0),
                                                child: Text(formatDateTime(startTime),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.normal,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 50,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.zero,
                                                color: NasColors.lightGrey,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withValues(alpha: 0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 15.0),
                                                child: Text(formatDateTime(endTime),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.normal,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              height: 50,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.zero,
                                                color: NasColors.lightGrey,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withValues(alpha: 0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 10.0),
                                                child: Text(duration,
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
                                      );
                                    }),
                              ) : Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noData,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 15,
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
                                          color: Colors.grey.withValues(alpha: 0.4),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child:  Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        AppLocalizations.of(context)!.totalDuration,
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
                                          color: Colors.grey.withValues(alpha: 0.4),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child:  Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        totalDurationString, // Dynamically setting the break number
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
                              IconButton(onPressed: (){
                                _togglePenalitiesExpand();
                              }, icon: Icon(Icons.close_fullscreen_outlined))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning,
                              color: Colors.red,
                                size: 40,
                              ),
                              const SizedBox(width: 10),
                              Text(AppLocalizations.of(context)!.penalties,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          if(_penalitiesExpanded)...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Category",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  "Detail",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Text(
                                  "Value",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            widget.attendanceData!.penalties!.isNotEmpty ?
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,

                                  itemCount: widget.attendanceData!.penalties!.length,
                                  itemBuilder: (context , index){
                                    final penalities = widget.attendanceData!.penalties![index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.zero,
                                              color: NasColors.lightGrey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(alpha: 0.4),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Text("${penalities.action}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: NasColors.darkBlue,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            height: 50,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.zero,
                                              color: NasColors.lightGrey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(alpha: 0.4),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 15.0),
                                              child: Text(
                                                  "${penalities.lateMinute}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: NasColors.darkBlue,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            height: 50,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.zero,
                                              color: NasColors.lightGrey,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(alpha: 0.4),
                                                  spreadRadius: 1,
                                                  blurRadius: 1,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 10.0),
                                              child: Text("${penalities.percentage}",
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
                                    );
                                  }),
                            ) : Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ]
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: (){
                              _toggleLeaveExpand();
                            }, icon: Icon(Icons.close_fullscreen_outlined))
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
                            Text(AppLocalizations.of(context)!.leaveInfo,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if(_leaveExpanded)...[
                        Text("${widget.attendanceData!.leaveDetails}",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: NasColors.darkBlue,
                          ),
                        ),]
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
                      Text(AppLocalizations.of(context)!.remarks,
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
                    padding: const EdgeInsets.all(12.0), // Adds padding to match the TextFormField's internal padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey), // Same border as the TextFormField
                    ),
                    child: widget.attendanceData!.remarks == 'Check-out time is missing Auto updated by system' ? Text(
                      AppLocalizations.of(context)!.missingCheckInAndCheckOut,
                      maxLines: 5,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ) : Text(
                      widget.attendanceData!.remarks ?? '',
                      maxLines: 5,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    )
                  )
                ],
              ),
            )

          ],
        ),),
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
  DateTime? parseTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    DateTime dateTime = DateTime.parse(dateTimeString);
    return dateTime.toUtc();
  }


  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat("hh:mm a").format(dateTime.toLocal()); // Convert before formatting
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '--';
    try {
      int totalMinutes = (minutes is int) ? minutes : int.parse(minutes.toString());
      int hours = totalMinutes ~/ 60;
      int remainingMinutes = totalMinutes % 60;

      if (hours > 0) {
        return '$hours h $remainingMinutes min';
      } else {
        return '$remainingMinutes min';
      }
    } catch (e) {
      print('Error formatting minutes: $e');
      return '--';
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
}
