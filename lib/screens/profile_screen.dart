import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:nashr/screens/setting_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';
import '../request_controller/profile_response_model.dart';
import '../request_controller/signature_model.dart';
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
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  int _selectedOptionIndex2 = 0;
  bool _expanded = false;
  final SignatureController _controller = SignatureController(penStrokeWidth: 2, penColor: Colors.black);
  bool _isEditing = false;
  File? _signatureImageFile;
  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/signature.png');
    if (file.existsSync()) {
      setState(() {
        _signatureImageFile = file;
      });
    }
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        await _uploadSignatureToApi(data);
        setState(() {
          _isEditing = false;
        });
      }
    }
  }



  void _resetSignature() {
    _controller.clear();
  }

  void _startEditing() {
    _controller.clear();
    setState(() {
      _isEditing = true;
    });
  }


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
  Widget build(BuildContext context) {
    final employeeProfile = singletonClass.employeeDataList.first.data;
    final bankInfo = singletonClass.employeeDataList.first.data!.bankingInfo;
    final salaryInfo = singletonClass.employeeDataList.first.data!.salaryInfo;
    final familyInfo = singletonClass.employeeDataList.first.data!.familyInfo;
    final documentInfo = singletonClass.employeeDataList.first.data!.documentsInfo;
    final shiftInfo = singletonClass.employeeDataList.first.data!.employeeInfo;
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
                      if(_selectedOptionIndex2 == 0)...[
                        Text(
                          AppLocalizations.of(context)!.myProfile,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                      if(_selectedOptionIndex2 == 1)...[
                        Text(
                          AppLocalizations.of(context)!.bankAccounts,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                      if(_selectedOptionIndex2 == 2)...[
                        Text(
                          AppLocalizations.of(context)!.documents,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                      if(_selectedOptionIndex2 == 3)...[
                        Text(
                          AppLocalizations.of(context)!.loans,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                      if(_selectedOptionIndex2 == 4)...[
                        Text(
                          AppLocalizations.of(context)!.familyInfo,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                      if(_selectedOptionIndex2 == 5)...[
                        Text(
                          AppLocalizations.of(context)!.shiftInfo,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Display the Settings button for "Profile" tab (index 0)
                      if (_selectedOptionIndex2 == 0)
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const SettingScreen()));
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
                      if (_selectedOptionIndex2 == 1)
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
                      if (_selectedOptionIndex2 == 2)
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
                      if (_selectedOptionIndex2 == 3)
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildOptionsCard2(0, AppLocalizations.of(context)!.profile),
                        buildOptionsCard2(1, AppLocalizations.of(context)!.bankAccounts),
                        buildOptionsCard2(2, AppLocalizations.of(context)!.documents),
                        buildOptionsCard2(3, AppLocalizations.of(context)!.loans),
                        buildOptionsCard2(4, AppLocalizations.of(context)!.familyInfo),
                        buildOptionsCard2(5, AppLocalizations.of(context)!.shiftInfo),
                        buildOptionsCard2(6, AppLocalizations.of(context)!.signature),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedOptionIndex2 == 0)...[
            Expanded(
              child: Container(
                color: Colors.white,
                child: RefreshIndicator(
                  color: NasColors.darkBlue,
                  backgroundColor: Colors.white,
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
                                                '${employeeProfile?.employeeInfo?.first.employeeShift}',
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
            ),
          ],
          if (_selectedOptionIndex2 == 1)...[
            Expanded(
              child: Container(
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
            ),
          ],
          if (_selectedOptionIndex2 == 2)...[
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: [ Column(
                    children: [
                      documentInfo!.isNotEmpty
                          ? ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: documentInfo.length,
                        itemBuilder: (BuildContext context, int index) {
                          final documents = documentInfo[index];
                          final fileType = documents.format?.split('.').last.toLowerCase(); // Null check for documents.type
                          final isImage = fileType != null && ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);
                          final isPdf = fileType == 'pdf';

                          return Transform.translate(
                            offset: Offset(0, index == 0 ? 0 : -10),
                            child: GestureDetector(
                              onTap: () async {
                                if (isImage || isPdf) {
                                  // Open the document URL using the default viewer (image viewer or PDF viewer)
                                  if (await canLaunch(documents.url)) {
                                    await launch(documents.url);
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
    ]
                )
              ),
            ),
          ],
          if (_selectedOptionIndex2 == 3)...[
            Expanded(
              child: Container(
                color: Colors.white,
                child: const LoanScreen(),
              ),
            ),
          ],
          if (_selectedOptionIndex2 == 4)...[
            Expanded(
              child: Container(
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
            ),
          ],
          if (_selectedOptionIndex2 == 5)...[
            Expanded(
              child: Container(
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
                                            .shiftInfo,
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
                                            .department,
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
                                        "${shiftInfo?.first.depName}",
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
                                        AppLocalizations.of(context)!.jobTitle,
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
                                        "${shiftInfo?.first.jobTitle}",
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
                                        AppLocalizations.of(context)!.jobDescription,
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
                                        "${shiftInfo?.first.jobDescription}",
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
                                        AppLocalizations.of(context)!.reportingManager,
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
                                        "${shiftInfo?.first.reportingManager}",
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
                                        AppLocalizations.of(context)!.employeeShift,
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
                                        "${shiftInfo?.first.employeeShift}",
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
                                        AppLocalizations.of(context)!.location,
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
                                        "${shiftInfo?.first.location}",
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
            ),
          ],
          if (_selectedOptionIndex2 == 6)...[
            Expanded(
              child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Stack(
                        children: [
                          // Signature Display or Placeholder
                          Column(
                            children: [
                              _isEditing
                                  ? Column(
                                children: [
                                  Signature(
                                    controller: _controller,
                                    height: 400,
                                    backgroundColor: Colors.grey[200]!,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _resetSignature,
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text(AppLocalizations.of(context)!.cancel,
                                          style: GoogleFonts.inter(
                                            color: Colors.white
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _saveSignature,
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        child: Text(AppLocalizations.of(context)!.save,
                                          style: GoogleFonts.inter(
                                              color: Colors.white
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                                  : Column(
                                children: [
                                  singletonClass.signatureModelList.isNotEmpty &&
                                      singletonClass.signatureModelList.first.data!.url != null
                                      ? Image.network(
                                    singletonClass.signatureModelList.first.data!.url!,
                                    height: 250,
                                  )
                                      : Container(
                                    height: 250,
                                    alignment: Alignment.center,
                                    color: Colors.grey[200],
                                    child: Text('No signature available'),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: _startEditing,
                              icon: Icon(
                                _signatureImageFile != null ? Icons.edit : Icons.add,
                                color: Colors.black,
                              ),
                              tooltip: _signatureImageFile != null ? 'Edit Signature' : 'Add Signature',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ],
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
  // Cards
  Widget buildOptionsCard2(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex2 = index;
        });
      },
      child: SizedBox(
        height: 60,
        width: 130,
        child: Card(
          color:
          _selectedOptionIndex2 == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color:
              _selectedOptionIndex2 == index ? Colors.white : Colors.white,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _selectedOptionIndex2 == index
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
          backgroundColor: Colors.white,
          title:  Text(AppLocalizations.of(context)!.confirmUpload,
            style: GoogleFonts.inter(
                color: Colors.black
            ),),
          content:
              Text('${AppLocalizations.of(context)!.areYouSureYouWantToUploadThisFile} ${file.name}?',
                style: GoogleFonts.inter(
                    color: Colors.black
                ),),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.inter(
                    color: Colors.red
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Trigger the API call to upload the file
                await uploadProfile();
              },
              child:  Text(AppLocalizations.of(context)!.yes,
                style: GoogleFonts.inter(
                    color: Colors.black
                ),),
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
      isLoading = true;
    });

    try {
      // Compress the image if it's larger than 1MB
      if (fileBytes.length > 1000000) {
        final compressed = await FlutterImageCompress.compressWithList(
          fileBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
          format: CompressFormat.jpeg,
        );
        print("Compressed from ${fileBytes.length} to ${compressed.length} bytes");
        fileBytes = compressed;
      }

      var request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(selectedFile!.path ?? '', headerBytes: fileBytes) ??
          'application/octet-stream';

      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(fileBytes),
        fileBytes.length,
        filename: selectedFile!.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = selectedFile!.name;
      request.fields['attachmentType'] = selectedFile!.extension ?? '';

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("API Response Body: $responseBody");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        ProfileResponse profileResponse = ProfileResponse.fromJson(decodedJson);
        singletonClass.profileResponseDataList = [profileResponse];

        updateEmployeeData();
        await singletonClass.getEmployeeData();

        setState(() => isLoading = false);

        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.success,
          type: QuickAlertType.success,
        );
      } else {
        print('Upload failed: ${response.statusCode}');
        setState(() => isLoading = false);
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
      print('Error during upload: $e');
      setState(() => isLoading = false);
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: AppLocalizations.of(context)!.errorFetchData,
        type: QuickAlertType.error,
      );
    }
  }


  //Signature CALL
  Future<void> _uploadSignatureToApi(Uint8List data) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
      final mimeType = 'image/png';

      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(data),
        data.length,
        filename: 'signature.png',
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = 'signature.png';
      request.fields['attachmentType'] = 'png';

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        SignatureModel profileResponse = SignatureModel.fromJson(decodedJson);
        singletonClass.signatureModelList = [profileResponse];

        updateSignature();
        singletonClass.getEmployeeData();

        setState(() {
          isLoading = false;
        });

        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.success,
          type: QuickAlertType.success,
        );
      } else {
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
      print('Upload error: $e');
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

  void updateSignature() async {
    String? employeeID = singletonClass.getJWTModel()?.employeeId;
    String url = '${singletonClass.baseURL}/employee/updateEMPSignature/$employeeID';

    // Define the JSON data to send
    Map<String, dynamic> data = {
      "empSignature": "${singletonClass.signatureModelList.first.data!.url}",
    };

    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    log("Signature Json$jsonData");

    // Make the PATCH request
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['statusCode'] == 200) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.success,
            type: QuickAlertType.success,
          );
        } else if (decodedResponse['statusCode'] == 400) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.internalServerError,
            type: QuickAlertType.error,
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.errorFetchData,
          type: QuickAlertType.error,
        );
      } else {
        print('Error: ${response.statusCode}');
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: 'Error: ${response.statusCode}',
          type: QuickAlertType.error,
        );
      }
    } catch (error) {
      print('Failed to send data. Error: $error');
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: 'Failed to send data. Error: $error',
        type: QuickAlertType.error,
      );
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
