import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/branch_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EmployeeProfileScreen extends StatefulWidget {
  final Supervisors? supervisors;

  final Teams? teams;

  const EmployeeProfileScreen({super.key, this.supervisors, this.teams});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  late Future<EmployeeDetailsData?> _employeeDetailsFuture;
  final List<Document> documentInfoDummy = [
    // Example data, replace with your actual document data
    Document(
        imageUrl: 'images/cnic.png',
        name: 'العمراني، نصار ابراهيم',
        cardNumber: '1027195021',
        dateOfBirthInHijri: '1404/04/05',
        expiryDateInHijri: '1450/11/29',
        placeOfBirth: 'Alqaan'),
    Document(
        imageUrl: 'images/iqama.png',
        name: 'العمراني، نصار ابراهيم',
        cardNumber: '1027195021',
        dateOfBirthInHijri: '1404/04/05',
        expiryDateInHijri: '1450/11/29',
        placeOfBirth: 'Alqaan'),
  ];

  @override
  void initState() {
    super.initState();
    _employeeDetailsFuture = getEmployeeDetailsData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20),
            child: FutureBuilder<EmployeeDetailsData?>(
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
                  } else if (snapshot.hasError) {
                    // Handle error state
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
                              padding:
                                  const EdgeInsets.only(left: 0.0, top: 0.0),
                              child: Text(
                                AppLocalizations.of(context)!.employeeProfile,
                                style: GoogleFonts.inter(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                  ClipOval(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 40,
                                      child: Image.asset(
                                        'images/DP.jpg',
                                        fit: BoxFit.fill,
                                        height: 150,
                                        width: 150,
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
                                          "${widget.supervisors!.userName}",
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
                                          "${widget.supervisors!.designation}",
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
                                          "${widget.supervisors!.grade}",
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
                                          "${widget.supervisors!.empId}",
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
                              buildOptionsCard(
                                  1, AppLocalizations.of(context)!.onLeaves),
                              buildOptionsCard(
                                  2, AppLocalizations.of(context)!.attendance),
                              buildOptionsCard(
                                  3, AppLocalizations.of(context)!.checkIn),
                              buildOptionsCard(
                                  4, AppLocalizations.of(context)!.documents),
                              buildOptionsCard(
                                  5, AppLocalizations.of(context)!.assets),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
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
                                    // Increase size if selected
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: _selectedOptionIndex == index
                                          ? NasColors.darkBlue
                                          : Colors.grey, // Active color
                                      borderRadius: BorderRadius.circular(4),
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
                                  color: Colors.grey.withOpacity(0.4),
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
                                      "${employeeDetails!.gender}",
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
                                      "${employeeDetails.nationality}",
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
                                      "${employeeDetails.dob}",
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
                                      "${employeeDetails.age}",
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
                                      "${employeeDetails.martialStatus}",
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
                                      "${employeeDetails.phoneNumber!.first.mobileNumber}",
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
                                      "${employeeDetails.address!.streetAddress}",
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
                                      "${employeeDetails.passport!.id}",
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
                          //ANNUAL LEAVE
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
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
                                            "${employeeDetails!.leaveBalance!.annualLeave?.used}",
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
                                            "${employeeDetails.leaveBalance!.annualLeave?.remaining}",
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
                                  color: Colors.grey.withOpacity(0.4),
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
                                            "${employeeDetails.leaveBalance!.sickLeave?.used}",
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
                                            "${employeeDetails.leaveBalance!.sickLeave?.remaining}",
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
                                  color: Colors.grey.withOpacity(0.4),
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
                        if (_selectedOptionIndex == 3) ...[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
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
                                // Set to min to avoid infinite height issues
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
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: singletonClass.employeeDetailsClockingDataList.first.data!.length,
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
                                      itemBuilder: (BuildContext context, int index) {
                                        final clocking = singletonClass.employeeDetailsClockingDataList.first.data![index];
                                        final dateTime = DateTime.parse(clocking.createdAt!); // Parse date string to DateTime object
                                        final formattedDate = singletonClass.formatDate(dateTime);
                                        final checkInTime = singletonClass.formatCheckInTime(clocking.checkInTime!);

                                        return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    height: 20,
                                                    width: 75,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      color: NasColors.onTime,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "On time",
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
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${AppLocalizations.of(context)!.checkIn}:  $checkInTime',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${AppLocalizations.of(context)!.checkOut}: N/A',
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
                                                  Text(
                                                    '${AppLocalizations.of(context)!.breaks}:  N/A',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${AppLocalizations.of(context)!.worked}: N/A',
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
                                                  Text(
                                                    '${AppLocalizations.of(context)!.late}:  --_--',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${AppLocalizations.of(context)!.earlyCheckOut}: N/A',
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (_selectedOptionIndex == 4) ...[
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: singletonClass.employeeDetailsDataList.first.data!.documentsInfo!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final documents =  singletonClass.employeeDetailsDataList.first.data!.documentsInfo![index];
                                final images = documentInfoDummy[index];
                                return Transform.translate(
                                  offset: Offset(0, index == 0 ? 0 : -10),
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet<void>(
                                        backgroundColor: NasColors.darkBlue,
                                        enableDrag: true,
                                        isDismissible: true,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20),
                                          ),
                                        ),
                                        context: context,
                                        builder: (BuildContext context) {
                                          // Pass the document data to the bottom sheet
                                          return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.9,
                                            width: double.infinity,
                                            color: Colors.transparent,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: ListView(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${documents.type}",
                                                        // Display the type of the tapped document
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            "Done",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.asset(
                                                      images.imageUrl,
                                                      height: 250,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment.topCenter,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: NasColors
                                                              .lightBlue,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () async {
                                                            try {
                                                              // Load the asset image as bytes
                                                              final byteData =
                                                                  await rootBundle
                                                                      .load(
                                                                          'images/iqama.png'); // Update with your asset path

                                                              // Get the temporary directory
                                                              final tempDir =
                                                                  await getTemporaryDirectory();

                                                              // Create a temporary file in the directory
                                                              final file = File(
                                                                  '${tempDir.path}/iqama.png');

                                                              // Write the image bytes to the temporary file
                                                              await file
                                                                  .writeAsBytes(
                                                                      byteData
                                                                          .buffer
                                                                          .asUint8List());

                                                              // Share the temporary file
                                                              await Share
                                                                  .shareXFiles([
                                                                XFile(file.path)
                                                              ], text: 'Check out this image!');
                                                            } catch (e) {
                                                              // Handle any errors that occur during the process
                                                              debugPrint(
                                                                  'Error sharing image: $e');
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Failed to share image: $e')),
                                                              );
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.ios_share,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: NasColors
                                                              .lightBlue,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            // Copy the image URL or any text to the clipboard
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: images
                                                                        .imageUrl)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: NasColors
                                                              .lightBlue,
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            // Action for the favorite button
                                                          },
                                                          icon: const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  15)),
                                                      color:
                                                          NasColors.lightBlue,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Name in Arabic",
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    images.name,
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: () {
                                                                  // Copy the image URL or any text to the clipboard
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              images.name)); // Text to be copied
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Divider(
                                                            height: 1,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Card Number",
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    images
                                                                        .cardNumber,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: () {
                                                                  // Copy the image URL or any text to the clipboard
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              images.cardNumber)); // Text to be copied
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Divider(
                                                            height: 1,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Date of Birth in Hijri",
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    images
                                                                        .dateOfBirthInHijri,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: () {
                                                                  // Copy the image URL or any text to the clipboard
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              images.dateOfBirthInHijri)); // Text to be copied
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Divider(
                                                            height: 1,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Expiry date in Hijri",
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    images
                                                                        .expiryDateInHijri,
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: () {
                                                                  // Copy the image URL or any text to the clipboard
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              images.expiryDateInHijri)); // Text to be copied
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Divider(
                                                            height: 1,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    "Place of Birth",
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Text(
                                                                    images
                                                                        .placeOfBirth,
                                                                    maxLines: 4,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Spacer(),
                                                              IconButton(
                                                                onPressed: () {
                                                                  // Copy the image URL or any text to the clipboard
                                                                  Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              images.placeOfBirth)); // Text to be copied
                                                                },
                                                                icon: const Icon(
                                                                    Icons.copy,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Divider(
                                                            height: 1,
                                                            color: Colors.white,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 30, right: 30),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          if (index != 0)
                                            const BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 10,
                                              spreadRadius: 10,
                                              offset: Offset(0,
                                                  -6), // Top shadow added only for items after the first one
                                            ),
                                          const BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            offset: Offset(0,
                                                5), // Bottom shadow to enhance overlap effect
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              images.imageUrl,
                                              height: 60,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ],
                        if (_selectedOptionIndex == 5) ...[
                          ListView.builder(
                              padding: const EdgeInsets.all(5),
                              shrinkWrap: true,
                              itemCount:  singletonClass.employeeDetailsDataList.first.data!.assetsInfo!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final assets =  singletonClass.employeeDetailsDataList.first.data!.assetsInfo![index];
                                return Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: NasColors.containerColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
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
                                                Text(
                                                  "${assets.assetType}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
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
                                              ]),
                                              const SizedBox(height: 20),
                                              Text(
                                                "ID #${assets.assetType}",
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
                                );
                              })
                        ]
                      ],
                    );
                  }
                }),
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
    String? employeeId = widget.supervisors?.empId;
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeDetailsData.fromJson(responseBody);
      singletonClass.setEmployeeDetailsData([employeeData]);
      getEmployeeClocking();
      return employeeData;
    }
    return null; // Print the response body
  }

  //EMPLOYEE CLOCKING DATA API CALL
  Future<EmployeeDetailsClocking?> getEmployeeClocking() async {
    String? employeeId = singletonClass.employeeDetailsDataList.first.data?.id;
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-check-in-out/$employeeId/2024-09-05/2024-09-11');

    var response = await client.get(uri);

    log(response.body);

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
