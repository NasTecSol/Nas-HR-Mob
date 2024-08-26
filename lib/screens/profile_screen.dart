import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import '../widgets/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  bool _expanded = false; // Initialize the expanded state

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded; // Toggle the expanded state
    });
  }
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // Initialize _tabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose _tabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeProfile = singletonClass.employeeDataList.first.data;
    final bankInfo = singletonClass.employeeDataList.first.data!.bankingInfo;
    final salaryInfo = singletonClass.employeeDataList.first.data!.salaryInfo;
    final familyInfo = singletonClass.employeeDataList.first.data!.familyInfo;
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "My Profile",
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Add your settings action
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
                            Icons.settings,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    padding: const EdgeInsets.only(left: 0),
                    dragStartBehavior: DragStartBehavior.start,
                    controller: _tabController,
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 8,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Bank Accounts'),
                      Tab(text: 'Family Info'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Content for Tab 1
                Container(
                  color: Colors.white,
                  child: ListView(padding: EdgeInsets.zero, children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child:GestureDetector(
                                onTap: () => _toggleExpand(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: _expanded ? 300 : 180, // Adjust height based on expanded state
                                  width: 400,
                                  margin: const EdgeInsets.only(top: 30),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: NasColors.darkBlue,
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
                                    padding: const EdgeInsets.all(20.0),
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.only(top: 35),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${employeeProfile?.firstName} ${employeeProfile?.middleName} ${employeeProfile?.lastName}',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${employeeProfile?.profession}',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '#1234',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          if (_expanded) ...[
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${employeeProfile?.employeeInfo?.first.depName}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${employeeProfile?.employeeInfo?.first.workDomain}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${employeeProfile?.employeeInfo?.first.grade}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ),
                            // Positioned image overlapping the top border of the container
                            Positioned(
                              top: -0,
                              // Adjust position as needed to overlap with container top border
                              left: (MediaQuery.of(context).size.width - 400) /
                                  0.07,
                              // Adjust position as needed horizontally
                              child: Stack(children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2, // Adjust border width as needed
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'images/DP.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -5,
                                  right: -5,
                                  child: IconButton(
                                    icon: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.black, width: 1)),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      // Add functionality for edit action
                                    },
                                    color: Colors
                                        .green, // Adjust icon color as needed
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
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
                                      "Personal Information",
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
                                      "Gender",
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
                                      "${employeeProfile?.gender}",
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
                                      "Nationality",
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
                                      "${employeeProfile?.nationality}",
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
                                      "BirthDate",
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
                                      "${employeeProfile?.dob}",
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
                                      "Age",
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
                                      "${employeeProfile?.age}",
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
                                      "Martial Status",
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
                                      "${employeeProfile?.martialStatus}",
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
                                      "Phone no",
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
                                      "${employeeProfile?.phoneNumber?.first.mobileNumber}",
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
                                      "Address",
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
                                      "${employeeProfile?.address?.city} ${employeeProfile?.address?.streetAddress} ${employeeProfile?.address?.country}",
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
                                      "Passport No",
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
                                      "${employeeProfile?.passport?.id}",
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
                        ),
                      ],
                    ),
                  ]),
                ),
                Container(
                    color: Colors.white,
                    child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  buildOptionsCard(0, "Payment Methods"),
                                  buildOptionsCard(1, "Salary")
                                ],
                              ),
                              if (_selectedOptionIndex == 0)
                                Column(
                                  children: [
                                    ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: bankInfo?.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final bank = bankInfo![index];
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
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
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 165,
                                                    width: 80,
                                                    // Adjusted the width for visibility
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(15),
                                                        bottomLeft: Radius.circular(15),
                                                      ),
                                                      color: Colors.white,
                                                      image: DecorationImage(
                                                        image: AssetImage("images/bankicon.png"), // Use a method to get the appropriate image
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Text(
                                                          "${bank.title}",
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
                                                          "${employeeProfile!.firstName} ${employeeProfile.middleName} ${employeeProfile.lastName}",
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
                                                          maskAccountNumber("${bank.accountNumber}"), // Call the method to mask the account number
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
                                                          "${bank.bankName}",
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
                                              )
                                            ),
                                          );
                                        })
                                  ],
                                ),
                              if (_selectedOptionIndex == 1)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Container(
                                        width: double.infinity,
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
                                              const SizedBox(height: 10),
                                              Text(
                                                "Last Month's Salary",
                                                maxLines: 2,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "June 2024",
                                                maxLines: 2,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 25),
                                              Text(
                                                "${salaryInfo?.baseSalary} SAR",
                                                maxLines: 2,
                                                style: GoogleFonts.inter(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                )
                            ],
                          ),

                    )),
                Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
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
                                        "Family Information",
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
                                        "Father Name",
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
                                        "${familyInfo?.fatherName}",
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
                                        "Mother Name",
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
                                        "${familyInfo?.motherName}",
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
                                        "Address",
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
                                        "${familyInfo?.familyAddress?.streetAddress}",
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
                                        "Country",
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
                                        "${familyInfo?.familyAddress?.country}",
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
                                        "City",
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
                                        "${familyInfo?.familyAddress?.city}",
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
                                        "Family Phone no",
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
                                        "${familyInfo?.familyContactNumber}",
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
                                        "Emergency Contact",
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Relation",
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
                                        "${familyInfo?.emergencyContactInfo?.first.relationType}",
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
                                        "Phone no",
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
                                        "${familyInfo?.emergencyContactInfo?.first.relationContactNumber}",
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
                          ),
                        ],
                      )
                    ],
                  )
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Tab 4 Content'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
//Method for Account Number
  String maskAccountNumber(String accountNumber) {
    // Check if the account number has at least 2 digits
    if (accountNumber.length >= 2) {
      return '*' * (accountNumber.length - 4) + accountNumber.substring(accountNumber.length - 4);
    } else {
      // If the account number has less than 2 digits, just return it as is
      return accountNumber;
    }
  }

  //Cards
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 140,
        child: Card(
          color:
              _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
}
