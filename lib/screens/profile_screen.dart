import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
import '../request_controller/profile_response_model.dart';
import '../request_controller/signature_model.dart';
import '../widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import '../widgets/loader.dart';
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
      await singletonClass.getEmployeeData();
      setState(() {
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
    final shiftInfo = singletonClass.employeeDataList.first.data!.employeeInfo;
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [ Column(
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
                            AppLocalizations.of(context)!.loans,
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                        if(_selectedOptionIndex2 == 3)...[
                          Text(
                            AppLocalizations.of(context)!.familyInfo,
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                        if(_selectedOptionIndex2 == 4)...[
                          Text(
                            AppLocalizations.of(context)!.shiftInfo,
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                        if(_selectedOptionIndex2 == 5)...[
                          Text(
                            AppLocalizations.of(context)!.signature,
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                        const Spacer(),
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
                          buildOptionsCard2(2, AppLocalizations.of(context)!.loans),
                          buildOptionsCard2(3, AppLocalizations.of(context)!.familyInfo),
                          buildOptionsCard2(4, AppLocalizations.of(context)!.shiftInfo),
                          buildOptionsCard2(5, AppLocalizations.of(context)!.signature),
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
                                      duration: const Duration(milliseconds: 700),
                                      height: _expanded ? 220 : 125,
                                      width: 400,
                                      margin: const EdgeInsets.only(top: 30),
                                      decoration: BoxDecoration(
                                        color: NasColors.darkBlue.withOpacity(_expanded ? 1 : 0.9), // fade effect
                                        borderRadius: BorderRadius.circular(_expanded ? 30 : 60), // round animation
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  (employeeProfile?.firstName?.isNotEmpty == true ||
                                                      employeeProfile?.middleName?.isNotEmpty == true ||
                                                      employeeProfile?.lastName?.isNotEmpty == true)
                                                      ? "${employeeProfile?.firstName ?? ''} ${employeeProfile?.middleName ?? ''} ${employeeProfile?.lastName ?? ''}".replaceAll(RegExp(r'\s+'), ' ').trim()
                                                      : "---",
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
                                                  (employeeProfile?.profession?.isNotEmpty == true)
                                                      ? employeeProfile!.profession!
                                                      : "---",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (_expanded) ...[
                                                const SizedBox(height: 10),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    (employeeProfile?.employeeInfo?.isNotEmpty == true &&
                                                        (employeeProfile?.employeeInfo?.first.depName?.isNotEmpty ==
                                                            true))
                                                        ? employeeProfile!.employeeInfo!.first.depName!
                                                        : "---",
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
                                                    (employeeProfile?.employeeInfo?.isNotEmpty == true &&
                                                        (employeeProfile?.employeeInfo?.first.workDomain?.isNotEmpty ==
                                                            true))
                                                        ? employeeProfile!.employeeInfo!.first.workDomain!
                                                        : "---",
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
                                                    (employeeProfile?.employeeInfo?.isNotEmpty == true &&
                                                        (employeeProfile?.employeeInfo?.first.grade?.isNotEmpty ==
                                                            true))
                                                        ? employeeProfile!.employeeInfo!.first.grade!
                                                        : "---",
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
                                  )),
                              Positioned(
                                top: -0,
                                left:
                                (MediaQuery.of(context).size.width - 100) /
                                    2,
                                child: Stack(children: [
                                  GestureDetector(
                                    onTap: (){
                                      String url = "${employeeProfile?.profilePic ?? ''}".toLowerCase();
                                      if (url.endsWith(".png") ||
                                          url.endsWith(".jpg") ||
                                          url.endsWith(".jpeg")) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.8,
                                                height: MediaQuery.of(context).size.height * 0.4,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Image.network(
                                                  employeeProfile?.profilePic ?? '',
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
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
                                        child: (employeeProfile?.profilePic != null &&
                                            employeeProfile!.profilePic!.isNotEmpty)
                                            ? Image.network(
                                          employeeProfile.profilePic!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
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
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    right: -5,
                                    child: IconButton(
                                      icon: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(15),
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black, width: 1)),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.black,
                                            size: 27,
                                        ),
                                      ),
                                      onPressed: () async {
                                        FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                          type: FileType
                                              .image,
                                        );

                                        if (result != null &&
                                            result.files.single.path != null) {
                                          PlatformFile file =
                                              result.files.single;
                                          setState(() {
                                            selectedFile = file;
                                          });

                                          print('Selected file: ${file.name}');
                                          _showConfirmationDialog(file);
                                        } else {
                                          print('File selection canceled.');
                                        }
                                      },
                                      color: Colors
                                          .green,
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
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                    offset: const Offset(0,
                                        3),
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
                                        (employeeProfile?.gender?.trim().isNotEmpty ?? false)
                                            ? employeeProfile!.gender!
                                            : "---",
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
                                        (employeeProfile?.nationality?.trim().isNotEmpty ?? false)
                                            ? employeeProfile!.nationality!
                                            : "---",
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
                                        (employeeProfile?.dob?.trim().isNotEmpty ?? false)
                                            ? employeeProfile!.dob!
                                            : "---",
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
                                        (employeeProfile?.age != null && employeeProfile!.age!.toString().trim().isNotEmpty)
                                            ? employeeProfile.age!.toString()
                                            : "---",
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
                                        (employeeProfile?.martialStatus?.trim().isNotEmpty ?? false)
                                            ? employeeProfile!.martialStatus!
                                            : "---",
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
                                        (employeeProfile?.phoneNumber?.isNotEmpty == true &&
                                            (employeeProfile?.phoneNumber?.first.mobileNumber?.toString().isNotEmpty ?? false))
                                            ? employeeProfile!.phoneNumber!.first.mobileNumber!.toString()
                                            : "---",
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
                                        [
                                          employeeProfile?.address?.city,
                                          employeeProfile?.address?.streetAddress,
                                          employeeProfile?.address?.country
                                        ]
                                            .where((e) => e != null && e.trim().isNotEmpty)
                                            .join(" ")
                                            .trim()
                                            .isNotEmpty
                                            ? [
                                          employeeProfile?.address?.city,
                                          employeeProfile?.address?.streetAddress,
                                          employeeProfile?.address?.country
                                        ]
                                            .where((e) => e != null && e.trim().isNotEmpty)
                                            .join(" ")
                                            : "---",
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
                                        (employeeProfile?.passport?.id != null &&
                                            employeeProfile!.passport!.id.toString().isNotEmpty)
                                            ? employeeProfile.passport!.id.toString()
                                            : "---",
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: bankInfo?.length ?? 0,
                                  itemBuilder: (BuildContext context, int index) {
                                    final bank = bankInfo?[index];
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
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(15),
                                                ),
                                                color: Colors.white,
                                                image: DecorationImage(
                                                  image: AssetImage("images/bankicon.png"),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.topLeft,
                                                      child: Text(
                                                        (bank?.title?.isNotEmpty == true) ? bank!.title! : "---",
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
                                                        ((employeeProfile?.firstName?.isNotEmpty == true) ||
                                                            (employeeProfile?.middleName?.isNotEmpty == true) ||
                                                            (employeeProfile?.lastName?.isNotEmpty == true))
                                                            ? "${employeeProfile?.firstName ?? ''} ${employeeProfile?.middleName ?? ''} ${employeeProfile?.lastName ?? ''}".replaceAll(RegExp(r'\s+'), ' ').trim()
                                                            : "---",
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
                                                        (bank?.accountNumber?.isNotEmpty == true)
                                                            ? maskAccountNumber(bank!.accountNumber!)
                                                            : "---",
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
                                                        (bank?.bankName?.isNotEmpty == true) ? bank!.bankName! : "---",
                                                        maxLines: 2,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.normal,
                                                          color: Colors.black,
                                                        ),
                                                      ),
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
                                )
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
                  child: const LoanScreen(),
                ),
              ),
            ],
            if (_selectedOptionIndex2 == 3)...[
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
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: const Offset(0,
                                          3),
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
                                          AppLocalizations.of(context)!.familyInfo,
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      // Father Name
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.fatherName,
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
                                          (familyInfo?.fatherName?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.fatherName.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Mother Name
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.motherName,
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
                                          (familyInfo?.motherName?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.motherName.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Address
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
                                          (familyInfo?.familyAddress?.streetAddress?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.familyAddress!.streetAddress.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Country
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
                                          (familyInfo?.familyAddress?.country?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.familyAddress!.country.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // City
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
                                          (familyInfo?.familyAddress?.city?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.familyAddress!.city.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Family Phone No
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.familyPhoneNo,
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
                                          (familyInfo?.familyContactNumber?.toString().isNotEmpty ?? false)
                                              ? familyInfo!.familyContactNumber.toString()
                                              : "---",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Emergency Contact
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.emergencyContact,
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Relation
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          AppLocalizations.of(context)!.relation,
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
                                          (familyInfo?.emergencyContactInfo?.isNotEmpty ?? false)
                                              ? (familyInfo!.emergencyContactInfo!.first.relationType?.toString().isNotEmpty ?? false
                                              ? familyInfo.emergencyContactInfo!.first.relationType.toString()
                                              : "---")
                                              : "---",
                                          maxLines: 2,
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Emergency Contact Number
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
                                          (familyInfo?.emergencyContactInfo?.isNotEmpty ?? false)
                                              ? (familyInfo!.emergencyContactInfo!.first.relationContactNumber?.toString().isNotEmpty ?? false
                                              ? familyInfo.emergencyContactInfo!.first.relationContactNumber.toString()
                                              : "---")
                                              : "---",
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
                                        AppLocalizations.of(context)!.shiftInfo,
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                    /// Department
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        AppLocalizations.of(context)!.department,
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
                                        shiftInfo?.first.depName?.isNotEmpty == true
                                            ? shiftInfo!.first.depName!
                                            : "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Job Title
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
                                        shiftInfo?.first.jobTitle?.isNotEmpty == true
                                            ? shiftInfo!.first.jobTitle!
                                            : "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Job Description
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
                                        shiftInfo?.first.jobDescription?.isNotEmpty == true
                                            ? shiftInfo!.first.jobDescription!
                                            : "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Reporting Manager
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
                                        shiftInfo?.first.reportingManager?.isNotEmpty == true
                                            ? shiftInfo!.first.reportingManager!
                                            : "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Employee Shift
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
                                        employeeProfile?.shiftInfo?.shiftName?.isNotEmpty ==
                                            true
                                            ? employeeProfile!.shiftInfo!.shiftName!
                                            : "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Shift Info (from - to)
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        AppLocalizations.of(context)!.shiftInfo,
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
                                        "${AppLocalizations.of(context)!.from}: ${employeeProfile?.shiftInfo?.timeFrom != null ? singletonClass.formatWithDateTime(employeeProfile!.shiftInfo!.timeFrom) : "NA"}",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${AppLocalizations.of(context)!.to}: ${employeeProfile?.shiftInfo?.timeTo != null ? singletonClass.formatWithDateTime(employeeProfile!.shiftInfo!.timeTo) : "NA"}",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    /// Location
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
                                        shiftInfo?.first.location?.isNotEmpty == true
                                            ? shiftInfo!.first.location!
                                            : "---",
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
                  ),
                ),
              )

            ],
            if (_selectedOptionIndex2 == 5)...[
              Expanded(
                child: Container(
                    color: Colors.white,
                    child: RefreshIndicator(
                      color: NasColors.darkBlue,
                      backgroundColor: Colors.white,
                      onRefresh: fetchLatestProfileData,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Stack(
                            children: [
                              Column(
                                children: [
                                  _isEditing
                                      ? Column(
                                    children: [
                                      Signature(
                                        controller: _controller,
                                        height: MediaQuery.of(context).size.height * 0.5,
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
                                      singletonClass.employeeDataList.first.data!.employeeInfo!.first.empSignature != null &&
                                          singletonClass.employeeDataList.first.data!.employeeInfo!.first.empSignature!.isNotEmpty
                                          ? Center(
                                            child: Image.network(
                                              singletonClass.employeeDataList.first.data!.employeeInfo!.first.empSignature!,
                                              height: 250,
                                            ),
                                          )
                                          : Container(
                                        height: 250,
                                        alignment: Alignment.center,
                                        color: Colors.grey[200],
                                        child: Text(AppLocalizations.of(context)!.noSignature,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                      ),
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
                                  tooltip: _signatureImageFile != null ? AppLocalizations.of(context)!.editSignature : AppLocalizations.of(context)!.addSignature,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          ],
        ),
          if (isLoading)
             Loader()
        ]
      ),
    );
  }

///Method for Account Number
  String maskAccountNumber(String accountNumber) {
    if (accountNumber.length >= 2) {
      return '*' * (accountNumber.length - 4) +
          accountNumber.substring(accountNumber.length - 4);
    } else {
      return accountNumber;
    }
  }

  ///Cards
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
  ///Upload profile methods
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
                Navigator.of(context).pop();
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
      return;
    }
    if (selectedFile!.bytes == null) {
      print("Loading bytes for the selected file...");
      try {
        final file = File(selectedFile!.path!);
        final fileBytes = await file.readAsBytes();
        if (fileBytes.isEmpty) {
          print("No bytes available for the selected file.");
          return;
        }
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        print('Error reading file: $e');
      }
    } else {
      _uploadFileWithBytes(selectedFile!.bytes!);
    }
  }

  void _uploadFileWithBytes(Uint8List fileBytes) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
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

      request.headers.addAll(singletonClass.getHeaders());
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

  ///Signature CALL
  Future<void> _uploadSignatureToApi(Uint8List data) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
      final mimeType = 'image/png';

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(singletonClass.getHeaders());
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
        SignatureModel signatureResponse = SignatureModel.fromJson(decodedJson);
        singletonClass.signatureModelList = [signatureResponse];

        updateSignature();
        singletonClass.getEmployeeData();

        setState(() {
          isLoading = false;
        });
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

  ///PATCH CALL
  void updateEmployeeData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var uri = Uri.parse('${singletonClass.baseURL}/employee/$employeeId');
    Map<String, dynamic> employeeData = {
      "profilePic": singletonClass.profileResponseDataList.first.data!.url,
    };

    try {
      var response = await http.patch(
        uri,
        headers: singletonClass.getHeaders(),
        body: json.encode(employeeData),
      );
      log("DATA ><><>< $employeeData");
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
    Map<String, dynamic> data = {
      "empSignature": "${singletonClass.signatureModelList.first.data!.url}",
    };
    String jsonData = jsonEncode(data);
    log("Signature Json$jsonData");
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
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
          singletonClass.getEmployeeData();
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

