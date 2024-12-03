import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:nashr/singleton_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:share_plus/share_plus.dart';
import '../request_controller/profile_response_model.dart';
import '../widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'loan_screen.dart';

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

  bool isLoading = false;
  PlatformFile? selectedFile;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded; // Toggle the expanded state
    });
  }

  late List<String> _tabTitles; // Titles for each tab

  @override
  void initState() {
    super.initState();

    setState(() {});
  }

  Future<void> fetchLatestProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await singletonClass.getEmployeeData(); // Fetch updated employee data
      setState(() {
        // Update UI with the latest data
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabTitles = [
      AppLocalizations.of(context)!.myProfile,
      AppLocalizations.of(context)!.bankAccounts,
      AppLocalizations.of(context)!.documents,
      AppLocalizations.of(context)!.loans,
      AppLocalizations.of(context)!.familyInfo
    ];

    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      // This will trigger rebuild and change the title and icon button action
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeProfile = singletonClass.employeeDataList.first.data;
    final bankInfo = singletonClass.employeeDataList.first.data!.bankingInfo;
    final salaryInfo = singletonClass.employeeDataList.first.data!.salaryInfo;
    final familyInfo = singletonClass.employeeDataList.first.data!.familyInfo;
    final documentInfo =
        singletonClass.employeeDataList.first.data!.documentsInfo;
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
                        _tabTitles[_tabController.index],
                        // Display the title based on the selected tab
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),

                      // Display the Settings button for "Profile" tab (index 0)
                      if (_tabController.index == 0)
                        IconButton(
                          onPressed: () {
                            // Add your settings action for the "Profile" tab
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
                              Icons.settings,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (_tabController.index == 1)
                        IconButton(
                          onPressed: () async {},
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
                              Icons.add,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      // Display the "Add" button for "Documents" tab (index 2)
                      if (_tabController.index == 2)
                        IconButton(
                          onPressed: () {
                            // Add your settings action for the "Profile" tab
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
                              Icons.add,
                              color: Colors.black,
                            ),
                          ),
                        ),

                      // Display the "Request" button for "Loans" tab (index 3)
                      if (_tabController.index == 3)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: NasColors.darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            // Add your action for "Loans" tab
                          },
                          child: SizedBox(
                            height: 40,
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)!.requests,
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
                  const SizedBox(height: 20),
                  TabBar(
                    padding: const EdgeInsets.only(left: 0),
                    dragStartBehavior: DragStartBehavior.start,
                    controller: _tabController,
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 5,
                    indicator: UnderlineTabIndicator(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        width: 8.0, // Thickness of the indicator
                        color: Colors.black, // Color of the indicator
                      ), // Horizontal padding
                    ),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    unselectedLabelColor: Colors.grey,
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 14, // Smaller font for unselected tabs
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.profile),
                      Tab(text: AppLocalizations.of(context)!.bankAccounts),
                      Tab(text: AppLocalizations.of(context)!.documents),
                      Tab(text: AppLocalizations.of(context)!.loans),
                      Tab(text: AppLocalizations.of(context)!.familyInfo),
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
                  child: RefreshIndicator(
                    onRefresh: fetchLatestProfileData,
                    child: ListView(padding: EdgeInsets.zero, children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: GestureDetector(
                                    onTap: () => _toggleExpand(),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: _expanded ? 300 : 180,
                                      // Adjust height based on expanded state
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
                                          padding:
                                              const EdgeInsets.only(top: 35),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                  )),
                              // Positioned image overlapping the top border of the container
                              Positioned(
                                top: -0,
                                // Adjust position as needed to overlap with container top border
                                left:
                                    (MediaQuery.of(context).size.width - 100) /
                                        2,
                                // Adjust position as needed horizontally
                                child: Stack(children: [
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
                                        employeeProfile?.profilePic ?? '',
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
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType
                                              .image, // Ensures only image files are allowed
                                        );

                                        if (result != null &&
                                            result.files.single.path != null) {
                                          PlatformFile file =
                                              result.files.single;

                                          // Save the file data for sending in the API call
                                          setState(() {
                                            selectedFile = file;
                                          });

                                          print('Selected file: ${file.name}');

                                          // Show confirmation dialog before uploading
                                          _showConfirmationDialog(
                                              file); // Upload the selected file to the API
                                        } else {
                                          // User canceled the file picker
                                          print('File selection canceled.');
                                        }
                                      },
                                      color: Colors
                                          .green, // Adjust icon color as needed
                                    ),
                                  ),
                                ]),
                              ),
                              if (isLoading == true)
                                Center(
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: CircularProgressIndicator(
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
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
                                    offset: const Offset(0,
                                        3), // Offset in the x and y directions
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
                ),
                // Content for Tab 2
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
                              buildOptionsCard(0,
                                  AppLocalizations.of(context)!.paymentMethods),
                              buildOptionsCard(
                                  1, AppLocalizations.of(context)!.salary)
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
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                    ),
                                                    color: Colors.white,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          "images/bankicon.png"),
                                                      // Use a method to get the appropriate image
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "${bank.title}",
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "${employeeProfile!.firstName} ${employeeProfile.middleName} ${employeeProfile.lastName}",
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        maskAccountNumber(
                                                            "${bank.accountNumber}"),
                                                        // Call the method to mask the account number
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "${bank.bankName}",
                                                        maxLines: 2,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )),
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
                                            AppLocalizations.of(context)!
                                                .lastMonthSalary,
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
                // Content for Tab 3
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: documentInfo?.length,
                        itemBuilder: (BuildContext context, int index) {
                          final documents = documentInfo![index];
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      width: double.infinity,
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: ListView(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "${documents.type}",
                                                  // Display the type of the tapped document
                                                  maxLines: 2,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const Spacer(),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Done",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ))
                                              ],
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                images.imageUrl,
                                                height: 250,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.topCenter,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: NasColors.lightBlue,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () async {
                                                      try {
                                                        // Load the asset image as bytes
                                                        final byteData =
                                                            await rootBundle.load(
                                                                'images/iqama.png'); // Update with your asset path

                                                        // Get the temporary directory
                                                        final tempDir =
                                                            await getTemporaryDirectory();

                                                        // Create a temporary file in the directory
                                                        final file = File(
                                                            '${tempDir.path}/iqama.png');

                                                        // Write the image bytes to the temporary file
                                                        await file.writeAsBytes(
                                                            byteData.buffer
                                                                .asUint8List());

                                                        // Share the temporary file
                                                        await Share.shareXFiles(
                                                            [XFile(file.path)],
                                                            text:
                                                                'Check out this image!');
                                                      } catch (e) {
                                                        // Handle any errors that occur during the process
                                                        debugPrint(
                                                            'Error sharing image: $e');
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'Failed to share image: $e')),
                                                        );
                                                      }
                                                    },
                                                    icon: const Icon(
                                                        Icons.ios_share,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: NasColors.lightBlue,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      // Copy the image URL or any text to the clipboard
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                              text: images
                                                                  .imageUrl)); // Text to be copied
                                                    },
                                                    icon: const Icon(Icons.copy,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: NasColors.lightBlue,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      // Action for the favorite button
                                                    },
                                                    icon: const Icon(Icons.star,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: SizedBox(
                                                    // Set a fixed width
                                                    height: 120,
                                                    // Set a fixed height
                                                    child: Image.asset(
                                                      'images/qrCode.png',
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment.topCenter,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                          Icons.broken_image,
                                                          size: 60,
                                                          color: Colors.grey,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15)),
                                                color: NasColors.lightBlue,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                                    text: images
                                                                        .name)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const Divider(
                                                      height: 1,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 10),
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              images.cardNumber,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 4,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                                    text: images
                                                                        .cardNumber)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const Divider(
                                                      height: 1,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 10),
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              images
                                                                  .dateOfBirthInHijri,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              maxLines: 4,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                                    text: images
                                                                        .dateOfBirthInHijri)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const Divider(
                                                      height: 1,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 10),
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              images
                                                                  .expiryDateInHijri,
                                                              maxLines: 4,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                                    text: images
                                                                        .expiryDateInHijri)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const Divider(
                                                      height: 1,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(height: 10),
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
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              images
                                                                  .placeOfBirth,
                                                              maxLines: 4,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
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
                                                                    text: images
                                                                        .placeOfBirth)); // Text to be copied
                                                          },
                                                          icon: const Icon(
                                                              Icons.copy,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
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
                        },
                      ),
                    ],
                  ),
                ),
                // Content for Tab 4
                Container(
                  color: Colors.white,
                  child: const LoanScreen(),
                ),
                // Content for Tab 5
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
                                      offset: const Offset(0,
                                          3), // Offset in the x and y directions
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
                                              .familyInfo,
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
                                          AppLocalizations.of(context)!
                                              .fatherName,
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
                                          AppLocalizations.of(context)!
                                              .motherName,
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
                                          AppLocalizations.of(context)!.country,
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
                                          AppLocalizations.of(context)!.city,
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
                                          AppLocalizations.of(context)!
                                              .familyPhoneNo,
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
                                          AppLocalizations.of(context)!
                                              .emergencyContact,
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
                                          AppLocalizations.of(context)!
                                              .relation,
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
                    )),
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
      return '*' * (accountNumber.length - 4) +
          accountNumber.substring(accountNumber.length - 4);
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

// Function to show the confirmation dialog
  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(AppLocalizations.of(context)!.confirmUpload),
          content:
              Text('${AppLocalizations.of(context)!.areYouSureYouWantToUploadThisFile} ${file.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Trigger the API call to upload the file
                await uploadProfile();
              },
              child:  Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadProfile() async {
    if (selectedFile == null) {
      print("No file selected.");
      return; // Exit the function if no file is selected
    }

    // Check if bytes are available
    if (selectedFile!.bytes == null) {
      // Load the bytes of the selected file manually
      print("Loading bytes for the selected file...");
      try {
        final file = File(selectedFile!.path!); // Convert PlatformFile to File
        final fileBytes = await file.readAsBytes();

        // If bytes are still null, return early
        if (fileBytes.isEmpty) {
          print("No bytes available for the selected file.");
          return; // Exit the function if no valid bytes are available
        }

        // Proceed with uploading the file after loading bytes
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        print('Error reading file: $e');
      }
    } else {
      // If bytes are already available, upload directly
      _uploadFileWithBytes(selectedFile!.bytes!);
    }
  }

  void _uploadFileWithBytes(Uint8List fileBytes) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true; // Corrected to set isLoading to true
    });

    try {
      var request = http.MultipartRequest('POST', uri);

      // Safely get the mime type (fall back to 'application/octet-stream' if mime type is not found)
      final mimeType = lookupMimeType(selectedFile!.path ?? '') ??
          'application/octet-stream';

      // Add the file to the request as bytes
      request.files.add(http.MultipartFile(
        'file', // Field name in the API
        http.ByteStream.fromBytes(fileBytes), // Convert bytes to ByteStream
        fileBytes.length, // File size (in bytes)
        filename: selectedFile!.name, // Filename
        contentType: MediaType.parse(mimeType), // MIME type
      ));

      // Add additional fields to the request if necessary
      request.fields['attachmentName'] =
          selectedFile!.name; // Safe unwrapping of nullable name
      request.fields['attachmentType'] = selectedFile!.extension ??
          ''; // Safe unwrapping of nullable extension

      // Send the request
      var response = await request.send();

      final responseBody = await response.stream.bytesToString();

      // Log the response body for debugging
      print("API Response Body: $responseBody");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        ProfileResponse profileResponse = ProfileResponse.fromJson(decodedJson);
        singletonClass.profileResponseDataList = [profileResponse];

        updateEmployeeData(); // Update local data
        singletonClass.getEmployeeData(); // Fetch updated employee data

        // Refresh UI with new data
        setState(() {});
        setState(() {
          isLoading = false;
          singletonClass.getEmployeeData();
        });
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.success,
          type: QuickAlertType.success,
        );
        setState(() {
          singletonClass.getEmployeeData();
        });
      } else {
        print('Upload failed: ${response.statusCode}');
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.errorFetchData,
          type: QuickAlertType.error,
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //PATCH CALL
  void updateEmployeeData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var uri = Uri.parse('${singletonClass.baseURL}/employee/$employeeId');

    // Create the JSON payload
    Map<String, dynamic> employeeData = {
      "userName": singletonClass.employeeDataList.first.data!.userName,
      "password": singletonClass.employeeDataList.first.data!.password,
      "email": singletonClass.employeeDataList.first.data!.email,
      "firstName": singletonClass.employeeDataList.first.data!.firstName,
      "middleName": singletonClass.employeeDataList.first.data!.middleName,
      "lastName": singletonClass.employeeDataList.first.data!.lastName,
      "martialStatus":
          singletonClass.employeeDataList.first.data!.martialStatus,
      "religion": singletonClass.employeeDataList.first.data!.religion,
      "address": singletonClass.employeeDataList.first.data!.address,
      "NIC": singletonClass.employeeDataList.first.data!.nic,
      "iqamaNumber": singletonClass.employeeDataList.first.data!.iqamaNumber,
      "passport": singletonClass.employeeDataList.first.data!.passport,
      "imigrationSatus":
          singletonClass.employeeDataList.first.data!.imigrationSatus,
      "DOB": singletonClass.employeeDataList.first.data!.dob,
      "age": singletonClass.employeeDataList.first.data!.age,
      "phoneNumber": singletonClass.employeeDataList.first.data!.phoneNumber,
      "gender": singletonClass.employeeDataList.first.data!.gender,
      "role": singletonClass.employeeDataList.first.data!.role,
      "profession": singletonClass.employeeDataList.first.data!.profession,
      "nationality": singletonClass.employeeDataList.first.data!.nationality,
      "profilePic": singletonClass.profileResponseDataList.first.data!.url,
      "familyInfo": singletonClass.employeeDataList.first.data!.familyInfo,
      "educationInfo":
          singletonClass.employeeDataList.first.data!.educationInfo,
      "experienceBackground":
          singletonClass.employeeDataList.first.data!.experienceBackground,
      "bankingInfo": singletonClass.employeeDataList.first.data!.bankingInfo,
      "employeeInfo": singletonClass.employeeDataList.first.data!.employeeInfo,
      "salaryInfo": singletonClass.employeeDataList.first.data!.salaryInfo,
      "socialLinks": singletonClass.employeeDataList.first.data!.socialLinks,
      "loanInfo": singletonClass.employeeDataList.first.data!.loanInfo,
      "assetsInfo": singletonClass.employeeDataList.first.data!.assetsInfo,
      "approvals": singletonClass.employeeDataList.first.data!.approvals,
      "contractInfo": singletonClass.employeeDataList.first.data!.contractInfo,
      "documentsInfo":
          singletonClass.employeeDataList.first.data!.documentsInfo,
      "createdBy": singletonClass.employeeDataList.first.data!.createdBy,
    };

    try {
      // Send the PATCH request
      var response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(employeeData),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('Employee data updated successfully');
      } else {
        print('Failed to update employee data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class Document {
  final String imageUrl;
  final String name;
  final String cardNumber;
  final String dateOfBirthInHijri;
  final String expiryDateInHijri;
  final String placeOfBirth;

  Document({
    required this.imageUrl,
    required this.name,
    required this.cardNumber,
    required this.dateOfBirthInHijri,
    required this.expiryDateInHijri,
    required this.placeOfBirth,
  });
}
