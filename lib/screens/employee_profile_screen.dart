import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/branch_model.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/screens/employee_details_screen_assets.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final TeamData? teamData;

  const EmployeeProfileScreen({super.key, this.teamData});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  late Future<EmployeeDetailsData?> _employeeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _employeeDetailsFuture = getEmployeeDetailsData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: ListView(
          padding: EdgeInsets.zero,
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
                              ]),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 0.0, top: 0.0),
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
                FutureBuilder<EmployeeDetailsData?>(
                    future: _employeeDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show loader while waiting for data
                        return Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/loader.json'),
                          ),
                        );
                      } if (snapshot.hasError) {
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
                      }
                      else if (!snapshot.hasData || snapshot.data == null) {
                        // Handle no data available state
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        );
                      } else {
                        // Data is available
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
                                      color: Colors.grey.withValues(alpha: 0.4),
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
                                            width:
                                            2, // Adjust border width as needed
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Image.network(
                                            employeeDetails?.first.profilePic ?? '',
                                            // URL for the network image, empty string if null
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            errorBuilder: (BuildContext context,
                                                Object exception,
                                                StackTrace? stackTrace) {
                                              // Display the default asset image if the network image fails to load
                                              return Image.asset(
                                                'images/DP.png',
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "${widget.teamData!.userName}",
                                              maxLines: 2,
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
                                              "${widget.teamData!.designation}",
                                              maxLines: 2,
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
                                              "${widget.teamData!.grade}",
                                              // Call the method to mask the account number
                                              maxLines: 2,
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
                                              "${widget.teamData!.empId}",
                                              maxLines: 2,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 15),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  buildOptionsCard(
                                      0, AppLocalizations.of(context)!.profile),
                                  if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1' || singletonClass.getJWTModel()?.grade == 'L2' || singletonClass.getJWTModel()?.grade == 'L3' )...[
                                    buildOptionsCard(
                                        1, AppLocalizations.of(context)!.leaveBalance),
                                    buildOptionsCard(
                                        2, AppLocalizations.of(context)!.attendance),
                                    buildOptionsCard(
                                        3, AppLocalizations.of(context)!.documents),
                                    buildOptionsCard(
                                        4, AppLocalizations.of(context)!.assets),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1' || singletonClass.getJWTModel()?.grade == 'L2'|| singletonClass.getJWTModel()?.grade == 'L3')...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    6,
                                        (index) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: _selectedOptionIndex == index
                                          ? 18.0
                                          : 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: _selectedOptionIndex == index
                                            ? NasColors.darkBlue
                                            : Colors.grey, // Active color
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    )),
                              ),
                            ],
                            const SizedBox(height: 10),
                            if (_selectedOptionIndex == 0) ...[
                              Container(
                                width: 400,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.4),
                                      // Shadow color with opacity
                                      spreadRadius: 5,
                                      // Spread radius
                                      blurRadius: 10,
                                      // Blur radius
                                      offset: const Offset(
                                          0, 3), // Offset in the x and y directions
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
                                          "${employeeDetails!.first.gender}",
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
                                          AppLocalizations.of(context)!.nationality,
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
                                          "${employeeDetails.first.nationality}",
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
                                          AppLocalizations.of(context)!.birthDate,
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
                                          "${employeeDetails.first.dob}",
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
                                          "${employeeDetails.first.age}",
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
                                          "${employeeDetails.first.martialStatus}",
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
                                          "${employeeDetails.first.phoneNumber!.first.mobileNumber}",
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
                                          "${employeeDetails.first.address!.streetAddress}",
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
                                          AppLocalizations.of(context)!.passportNo,
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
                                          "${employeeDetails.first.passport!.id}",
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
                            if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1' ) ...[
                              if (_selectedOptionIndex == 1) ...[
                                //ANNUAL LEAVE
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.4),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: const Offset(
                                            0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.annualLeave,
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
                                                  "${employeeDetails!.first.leaveBalance!.annualLeave?.used}",
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
                                                  "${employeeDetails.first.leaveBalance!.annualLeave?.remaining}",
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
                                //SICK LEAVE
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.4),
                                        // Shadow color with opacity
                                        spreadRadius: 5,
                                        // Spread radius
                                        blurRadius: 10,
                                        // Blur radius
                                        offset: const Offset(
                                            0, 3), // Offset in the x and y directions
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.sickLeave,
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
                                                  "${employeeDetails.first.leaveBalance!.sickLeave?.used}",
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
                                                  "${employeeDetails.first.leaveBalance!.sickLeave?.remaining}",
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
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.4),
                                        // Shadow color with opacity
                                        spreadRadius: 5,
                                        // Spread radius
                                        blurRadius: 10,
                                        // Blur radius
                                        offset: const Offset(
                                            0, 3), // Offset in the x and y directions
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
                              if (_selectedOptionIndex == 2) ... [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.4),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: const Offset(
                                            0, 3), // Offset in the x and y directions
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
                                              AppLocalizations.of(context)!
                                                  .attendance,
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
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: singletonClass.employeeDetailsAttendanceDataList.first.data!.first.data!.length,
                                            separatorBuilder: (BuildContext context, int index) {
                                              return const Padding(
                                                padding: EdgeInsets.only(left: 10.0 , right: 10.0),
                                                child: Divider(
                                                  color: Colors.grey,
                                                  thickness: 1,
                                                  height: 20,
                                                ),
                                              );
                                            },
                                            itemBuilder: (BuildContext context , int index){
                                              final attendance = singletonClass.employeeDetailsAttendanceDataList.first.data!.first.data!.reversed.toList()[index];
                                              int breakHours = (attendance.breakTime! ~/ 60);
                                              int breakMinutes = (attendance.breakTime! % 60).round();
                                              int totalMinutes = (attendance.totalHoursWorked! * 60).round();
                                              int hours = totalMinutes ~/ 60;
                                              int minutes = totalMinutes % 60;
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${attendance.date}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: NasColors.darkBlue,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                           attendance.status == 'absent' ? AppLocalizations.of(context)!.absent :
                                                          AppLocalizations.of(context)!.present,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: attendance.status == 'absent' ? Colors.red : NasColors.onTime,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${AppLocalizations.of(context)!.checkIn}:  ${singletonClass.formatCheckInTime(attendance.clockInTime!)}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: NasColors.darkBlue,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          '${AppLocalizations.of(context)!.checkOut}: ${singletonClass.formatCheckInTime(attendance.clockOutTime!)}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: NasColors.darkBlue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width:140,
                                                          child: Text(
                                                            '${AppLocalizations.of(context)!.breaks}:  $breakHours hours $breakMinutes mins',
                                                            style: GoogleFonts.inter(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                              color: NasColors.darkBlue,
                                                            ),
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          '${AppLocalizations.of(context)!.worked}: $hours hours $minutes mins',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w500,
                                                            color: NasColors.darkBlue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ) ,
                                )
                              ],
                              if (_selectedOptionIndex == 3) ...[
                                Column(
                                  children: [
                                    singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo!.isNotEmpty
                                        ? ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo!.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final documents = singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo![index];
                                        final fileType = documents.format?.split('.').last.toLowerCase(); // Null check for documents.type
                                        final isImage = fileType != null && ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);
                                        final isPdf = fileType == 'pdf';

                                        return Transform.translate(
                                          offset: Offset(0, index == 0 ? 0 : -10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (isImage || isPdf) {
                                                // Open the document URL using the default viewer (image viewer or PDF viewer)
                                                if (await canLaunchUrl(documents.url)) {
                                                  await launchUrl(documents.url);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Could not open the document!')),
                                                  );
                                                }
                                              } else {
                                                // Handle other file types if needed
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Unsupported file type!')),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(top: 10.0, left: 30, right: 30),
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
                                                    "${documents.type}",
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
                                                    child: isImage
                                                        ? Image.network(
                                                      documents.url,
                                                      height: 60,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      alignment: Alignment.topCenter,
                                                    )
                                                        : Icon(
                                                      isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
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
                                        child: Text(
                                          AppLocalizations.of(context)!.noData,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_selectedOptionIndex == 4) ...[
                                ListView.builder(
                                    padding: const EdgeInsets.all(5),
                                    shrinkWrap: true,
                                    itemCount:  singletonClass.employeeDetailsDataList.first.data!.first.assetsInfo!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final assets =  singletonClass.employeeDetailsDataList.first.data!.first.assetsInfo![index];
                                      return Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: GestureDetector(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeDetailsScreenAssets(assetsInfo: assets,)));
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(
                                                  Radius.circular(15)),
                                              color: NasColors.containerColor,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withValues(alpha: 0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0,
                                                      0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 165,
                                                  width: 80,
                                                  // Adjusted the width for visibility
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(15),
                                                      bottomLeft: Radius.circular(15),
                                                    ),
                                                    color: NasColors.darkBlue,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        _getImageForEventType(assets
                                                            .assetType!), // Use a method to get the appropriate image
                                                      ),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Row(children: [
                                                        Text(
                                                          "${assets.assetName}",
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
                                                              "${assets.assetType}",
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
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    10),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  "Status",
                                                                  textAlign:
                                                                  TextAlign.center,
                                                                  style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                    FontWeight.bold,
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
                                                        "ID #${assets.assetId}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      Text(
                                                        "Assigned At ${assets.issueDateFrom}",
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
                                        ),
                                      );
                                    })
                              ]
                            ],
                          ],
                        );
                      }
                    }),
              ],
            ),
          ),
        ]));
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

  Future<EmployeeDetailsData?> getEmployeeDetailsData() async {
    String? employeeId = widget.teamData?.empId;
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeDetailsData.fromJson(responseBody);
      singletonClass.setEmployeeDetailsData([employeeData]);
      getEmployeeClocking();
      getEmployeeAttendanceData();
      return employeeData;
    }
    return null; // Print the response body
  }
   //EMPLOYEE ATTENDANCE DATA API CALL
  Future<EmployeeDetailsAttendanceData?> getEmployeeAttendanceData() async {
    String? employeeId = singletonClass.employeeDetailsDataList.first.data?.first.id;
    var client = http.Client();

    // Get current date
    DateTime now = DateTime.now();

    // Get the first date of the current month
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

    // Format the dates in 'MM-dd-yyyy' format
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$employeeId/$currentDateString/$firstDateString');

    var response = await client.get(uri,headers: singletonClass.getHeaders());
    print("Employee Attendance Data${response.body}");
    print(employeeId);
    print(firstDateString);
    print(currentDateString);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = EmployeeDetailsAttendanceData.fromJson(responseBody);
      singletonClass.setEmployeeAttendanceDataList([attendance]);
      return attendance;
    }

    return null;
  }


  //EMPLOYEE CLOCKING DATA API CALL
  Future<EmployeeDetailsClocking?> getEmployeeClocking() async {
    String? employeeId = singletonClass.employeeDetailsDataList.first.data?.first.id;
    var client = http.Client();
    // Get current date
    DateTime now = DateTime.now();

    // Get the first date of the current month
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

    // Format the dates in 'MM-dd-yyyy' format
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';
    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-check-in-out/filter?employeeId=$employeeId&startDate=$firstDateString&endDate=$currentDateString');

    var response = await client.get(uri,headers: singletonClass.getHeaders());

    log("Employee Clock in / out data : ${response.body}");

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeClockingData = EmployeeDetailsClocking.fromJson(responseBody);
      singletonClass.setEmployeeDetailsClocking([employeeClockingData]);
      return employeeClockingData;
    }
    return null; // Print the response body
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
