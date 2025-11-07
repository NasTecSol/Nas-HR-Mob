import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/screens/employee_details_screen_assets.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../request_controller/team_model.dart';
import '../widgets/loader.dart';

class BranchEmployeeProfileScreen extends StatefulWidget {
  final Employees? employees;
  final bool isTeamMate;

  const BranchEmployeeProfileScreen(
      {super.key,this.employees ,required this.isTeamMate});

  @override
  State<BranchEmployeeProfileScreen> createState() => _BranchEmployeeProfileScreen();
}

class _BranchEmployeeProfileScreen extends State<BranchEmployeeProfileScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  late Future<EmployeeDetailsData?> _employeeDetailsFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _employeeDetailsFuture = getEmployeeDetailsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: ListView(padding: EdgeInsets.zero, children: [
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
                          singletonClass.employeeDetailsAttendanceDataList.clear();
                          singletonClass.employeeDetailsDataList.clear();
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                      child: Text(
                        AppLocalizations.of(context)!.employeeProfile,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                isLoading == false ? FutureBuilder<EmployeeDetailsData?>(
                    future: _employeeDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show loader while waiting for data
                        return Loader();
                      }
                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.errorFetchData,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
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
                      } else {
                        final employeeDetails = snapshot.data!.data;
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: (employeeDetails != null &&
                                            employeeDetails.isNotEmpty &&
                                            (employeeDetails.first.profilePic?.isNotEmpty ?? false))
                                            ? Image.network(
                                          employeeDetails.first.profilePic!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            return Image.asset(
                                              'images/DP.png',
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            );
                                          },
                                        )
                                            : Image.asset(
                                          'images/DP.png',
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              widget.employees!.userName ??
                                                  'N/A',
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              widget.employees?.employeeInfo!.first.designation ??
                                                  'N/A',
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              widget.employees?.employeeInfo!.first.grade ?? 'N/A',
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              widget.employees?.employeeInfo!.first.empId ?? 'N/A',
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (widget.isTeamMate == true)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    buildOptionsCard(0,
                                        AppLocalizations.of(context)!.profile),
                                    buildOptionsCard(
                                        1,
                                        AppLocalizations.of(context)!
                                            .leaveBalance),
                                    buildOptionsCard(
                                        2,
                                        AppLocalizations.of(context)!
                                            .attendance),
                                    buildOptionsCard(
                                        3,
                                        AppLocalizations.of(context)!
                                            .documents),
                                    buildOptionsCard(4,
                                        AppLocalizations.of(context)!.assets),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (widget.isTeamMate == true)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    5,
                                        (index) => AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: _selectedOptionIndex == index
                                          ? 18.0
                                          : 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: _selectedOptionIndex == index
                                            ? NasColors.darkBlue
                                            : Colors.grey,
                                        // Active color
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                    )),
                              ),
                            const SizedBox(height: 10),
                            if (_selectedOptionIndex == 0) ...[
                              Container(
                                width: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(100),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .personalInformation,
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.gender,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.gender ?? '___' : '___'}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .nationality,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.nationality ?? '___' : '___'}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .birthDate,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.dob ?? '___' : '___'}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.age,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.age ?? '___' : '___'}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .martialStatus,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.martialStatus ?? '___' : '___'}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.phoneNo,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          widget.isTeamMate == false
                                              ? maskPhoneNumber(
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? (employeeDetails!.first.phoneNumber?.first.mobileNumber?.toString() ?? '')
                                                : '',
                                          )
                                              : (employeeDetails?.isNotEmpty ?? false)
                                              ? (employeeDetails!.first.phoneNumber?.first.mobileNumber?.toString() ?? '___')
                                              : '___',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.address,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.address?.streetAddress ?? '___' : '___'}",
                                          maxLines: 2,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .passportNo,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "${(employeeDetails?.isNotEmpty ?? false) ? employeeDetails!.first.passport?.id ?? '___' : '___'}",
                                          maxLines: 2,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (_selectedOptionIndex == 1) ...[
                              // ANNUAL LEAVE
                              if (employeeDetails != null &&
                                  employeeDetails.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .annualLeave,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .leaveUsed,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${employeeDetails.first.leaveBalance?.annualLeave?.used ?? 0}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 75,
                                              child: VerticalDivider(
                                                color: Colors.grey[400],
                                                thickness: 1,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .leaveRemaining,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${employeeDetails.first.leaveBalance?.annualLeave?.remaining ?? 0}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
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
                              const SizedBox(height: 20),
                              if (employeeDetails != null &&
                                  employeeDetails.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .sickLeave,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .leaveUsed,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${employeeDetails.first.leaveBalance?.sickLeave?.used ?? 0}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 75,
                                              child: VerticalDivider(
                                                color: Colors.grey[400],
                                                thickness: 1,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!
                                                      .leaveRemaining,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${employeeDetails.first.leaveBalance?.sickLeave?.remaining ?? 0}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
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
                              const SizedBox(height: 20),

                              // LEAVE HISTORY
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .leaveHistory,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.history,
                                            color: NasColors.darkBlue,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (_selectedOptionIndex == 2) ...[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                ?.attendance ??
                                                'Attendance',
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(Icons.history,
                                              color: NasColors.darkBlue),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: ListView.separated(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: singletonClass.employeeDetailsAttendanceDataList.first.data?.first.data?.length ?? 0,
                                          separatorBuilder: (_, __) => const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Divider(
                                                color: Colors.grey,
                                                thickness: 1,
                                                height: 20),
                                          ),
                                          itemBuilder: (context, index) {
                                            final attendanceList = singletonClass.employeeDetailsAttendanceDataList.first.data?.first.data;
                                            if (attendanceList == null || attendanceList.isEmpty) {
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
                                            final reversedList = attendanceList.toList();
                                            if (index >= reversedList.length) {
                                              return SizedBox();
                                            }
                                            final attendance = reversedList[index];

                                            int breakTime = attendance.breakTime ?? 0;
                                            int breakHours = breakTime ~/ 60;
                                            int breakMinutes = breakTime % 60;

                                            String date = "___";
                                            if (attendance.updatedAt != null) {
                                              try {
                                                date = DateFormat('dd-MM-yyyy')
                                                    .format(DateTime.parse(
                                                    attendance.updatedAt!));
                                              } catch (_) {
                                                date = "___";
                                              }
                                            }

                                            int? lateMinutes = int.tryParse(
                                                formatMinutes(
                                                    attendance.lateMinutes));
                                            int? earlyCheckOut = int.tryParse(
                                                formatMinutes(
                                                    attendance.earlyCheckOut));

                                            return Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                              padding:
                                              const EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipOval(
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                          Colors.white,
                                                          radius: 30,
                                                          child: Image.asset(
                                                            'images/DP.png',
                                                            fit: BoxFit.cover,
                                                            width: 100,
                                                            height: 100,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          SizedBox(
                                                            width:150,
                                                            child: Text(
                                                              attendance.name?.isNotEmpty == true
                                                                  ? attendance.name! : "___",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            _translateStatus(attendance.status, context),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              color: getStatusColor(
                                                                  attendance
                                                                      .status ??
                                                                      ""),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Builder(
                                                        builder: (_) {
                                                          int workedMinutes =
                                                              attendance
                                                                  .totalHoursWorked ??
                                                                  0;
                                                          double progress =
                                                          (workedMinutes /
                                                              (11 * 60))
                                                              .clamp(
                                                              0.0, 1.0);

                                                          return Column(
                                                            children: [
                                                              Text(
                                                                "${workedMinutes ~/ 60}h ${workedMinutes % 60}m",
                                                                style:
                                                                GoogleFonts
                                                                    .inter(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              SizedBox(
                                                                width: 80,
                                                                height: 8,
                                                                child:
                                                                ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      8),
                                                                  child:
                                                                  LinearProgressIndicator(
                                                                    value:
                                                                    progress,
                                                                    backgroundColor:
                                                                    Colors.grey[
                                                                    300],
                                                                    valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                      progress >=
                                                                          1.0
                                                                          ? Colors
                                                                          .green
                                                                          : Colors
                                                                          .orange,
                                                                    ),
                                                                    minHeight:
                                                                    8,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        attendance.empId
                                                            ?.isNotEmpty ==
                                                            true
                                                            ? attendance.empId!
                                                            : "___",
                                                        style:
                                                        GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        date,
                                                        style:
                                                        GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${breakHours}h ${breakMinutes}m",
                                                        style:
                                                        GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Icon(Icons.coffee,
                                                          size: 20,
                                                          color: Colors.brown),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Divider(
                                                      color: Colors.grey),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      Colors.grey.shade200,
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                        bottomLeft:
                                                        Radius.circular(15),
                                                        bottomRight:
                                                        Radius.circular(15),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                  context)
                                                                  ?.checkIn ??
                                                                  "Check In",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color:
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              singletonClass
                                                                  .formatCheckInTime(
                                                                  attendance
                                                                      .clockInTime ??
                                                                      "" , context),
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: (lateMinutes !=
                                                                    null &&
                                                                    lateMinutes >
                                                                        0)
                                                                    ? NasColors
                                                                    .pending
                                                                    : Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                  context)
                                                                  ?.checkOut ??
                                                                  "Check Out",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color:
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              singletonClass
                                                                  .formatCheckInTime(
                                                                  attendance
                                                                      .clockOutTime ??
                                                                      "" , context),
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: (lateMinutes !=
                                                                    null &&
                                                                    lateMinutes >
                                                                        0)
                                                                    ? NasColors
                                                                    .pending
                                                                    : Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                  context)
                                                                  ?.late ??
                                                                  "Late",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color:
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              "${lateMinutes! ~/ 60}${AppLocalizations.of(context)!.h} ${lateMinutes % 60}${AppLocalizations.of(context)!.m}",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.bold,
                                                                color: NasColors.pending,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Text(
                                                              AppLocalizations.of(
                                                                  context)
                                                                  ?.earlyLeft ??
                                                                  "Early Left",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color:
                                                                Colors.grey,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              "${earlyCheckOut! ~/ 60}${AppLocalizations.of(context)!.h} ${earlyCheckOut % 60}${AppLocalizations.of(context)!.m}",
                                                              style: GoogleFonts.inter(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.bold,
                                                                color: NasColors.onTime,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (_selectedOptionIndex == 3) ...[
                              Column(
                                children: [
                                  (singletonClass.employeeDetailsDataList.isNotEmpty &&
                                      singletonClass.employeeDetailsDataList.first.data != null &&
                                      singletonClass.employeeDetailsDataList.first.data!.isNotEmpty &&
                                      singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo != null &&
                                      singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo!.isNotEmpty)
                                      ? ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo?.length ?? 0,
                                    itemBuilder: (BuildContext context, int index) {
                                      final documents = singletonClass
                                          .employeeDetailsDataList
                                          .first
                                          .data!
                                          .first
                                          .documentsInfo![index];

                                      final fileType =
                                      documents.format?.split('.').last.toLowerCase();
                                      final isImage = fileType != null &&
                                          ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);
                                      final isPdf = fileType == 'pdf';

                                      return Transform.translate(
                                        offset: Offset(0, index == 0 ? 0 : -10),
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (isImage || isPdf) {
                                              if (documents.url != null &&
                                                  await canLaunchUrl(documents.url!)) {
                                                await launchUrl(documents.url!);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                      content: Text('Could not open the document!')),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Unsupported file type!')),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, left: 30, right: 30),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.white,
                                              boxShadow: [
                                                if (index != 0)
                                                  const BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 10,
                                                    spreadRadius: 10,
                                                    offset: Offset(0, -6),
                                                  ),
                                                const BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${documents.type ?? ''}",
                                                  maxLines: 2,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: isImage && documents.url != null
                                                      ? Image.network(
                                                    documents.url!,
                                                    height: 60,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.topCenter,
                                                  )
                                                      : Icon(
                                                    isPdf
                                                        ? Icons.picture_as_pdf
                                                        : Icons.insert_drive_file,
                                                    size: 60,
                                                    color: NasColors.darkBlue,
                                                  ),
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
                                  ),
                                ],
                              ),
                            ],
                            if (_selectedOptionIndex == 4) ...[
                              (singletonClass.employeeDetailsDataList.isNotEmpty &&
                                  singletonClass.employeeDetailsDataList.first.data != null &&
                                  singletonClass.employeeDetailsDataList.first.data!.isNotEmpty &&
                                  singletonClass.employeeDetailsDataList.first.data!.first.assetsInfo != null &&
                                  singletonClass.employeeDetailsDataList.first.data!.first.assetsInfo!.isNotEmpty)
                                  ? ListView.builder(
                                padding: const EdgeInsets.all(5),
                                shrinkWrap: true,
                                itemCount: singletonClass
                                    .employeeDetailsDataList.first.data!.first.assetsInfo!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final assets = singletonClass
                                      .employeeDetailsDataList.first.data!.first.assetsInfo![index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EmployeeDetailsScreenAssets(
                                                assetsInfo: assets,
                                              )));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                                        color: NasColors.containerColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 165,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                              ),
                                              color: NasColors.darkBlue,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  _getImageForEventType(assets.assetType ?? ""),
                                                ),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(children: [
                                                  Text(
                                                    assets.assetName ?? "",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2.5),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        assets.assetType ?? "",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        height: 30,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.rectangle,
                                                          color: NasColors.onTime,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Status",
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
                                                  )
                                                ]),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${AppLocalizations.of(context)!.id}# ${assets.assetId ?? ""}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  "${AppLocalizations.of(context)!.assignedAt} ${assets.issueDateFrom ?? ""}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
                              ),
                            ]

                          ],
                        );
                      }
                    }) : Loader(),
              ],
            ),
          ),
        ]));
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '--';
    try {
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString();
    } catch (e) {
      return '--';
    }
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null) return localizations.noData;

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
        return NasColors.completed;
      case "Quarterly":
        return NasColors.pending;
      case "Missing CheckIn/Out":
        return NasColors.pending;
      default:
        return NasColors.completed;
    }
  }

  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 65,
        width: 140,
        child: Card(
          color:
          _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color:
              _selectedOptionIndex == index ? Colors.white : Colors.white,
              width: 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : NasColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String maskPhoneNumber(String number) {
    if (number.length < 4) return number; // in case number is too short
    String prefix = number.substring(0, 3); // e.g. +92
    String suffix = number.substring(number.length - 1); // last digit
    String masked = '*' * (number.length - 4); // mask middle part
    return '$prefix$masked$suffix';
  }

  Future<EmployeeDetailsData?> getEmployeeDetailsData() async {
    String? employeeId = widget.employees!.employeeInfo!.first.empId;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeDetailsData.fromJson(responseBody);
      singletonClass.setEmployeeDetailsData([employeeData]);
      getEmployeeAttendanceData();
      return employeeData;
    }
    return null;
  }

  ///EMPLOYEE ATTENDANCE DATA API CALL
  Future<EmployeeDetailsAttendanceData?> getEmployeeAttendanceData(
      {
        int limit = 10000,
        int page = 0,
      }
      ) async {
    String? employeeId =
        singletonClass.employeeDetailsDataList.first.data?.first.id;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();

    // Get current date
    DateTime now = DateTime.now();

    // Get the first date of the current month
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

    // Format the dates in 'MM-dd-yyyy' format
    String firstDateString =
        '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString =
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$employeeId/$currentDateString/$firstDateString?limit=$limit&page=$page');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    print("Employee Attendance Data${response.body}");
    print(employeeId);
    print(firstDateString);
    print(currentDateString);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = EmployeeDetailsAttendanceData.fromJson(responseBody);
      singletonClass.setEmployeeAttendanceDataList([attendance]);
      return attendance;
    }

    return null;
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'laptop':
        return 'images/Laptop.png';
      case 'car':
        return 'images/Car.png';
      default:
        return 'images/Vector.png'; // Default image for company or other types
    }
  }
}
