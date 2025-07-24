import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/create_hr_letter_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/colors.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _iqamaContainerKey = GlobalKey();
  final GlobalKey _passportContainerKey = GlobalKey();
  final GlobalKey _employeeContractContainerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final documentInfo =
        singletonClass.employeeDataList.first.data!.documentsInfo;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(padding: EdgeInsets.zero, children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
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
                      Text(
                        AppLocalizations.of(context)!.myDocuments,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (singletonClass.getJWTModel()?.grade == 'L0' ||
                          singletonClass.getJWTModel()?.grade == 'L1')
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CreateHrLetterScreen()));
                          },
                          icon: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NasColors.darkBlue,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
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
                        buildOptionsCard(
                            0, AppLocalizations.of(context)!.documents),
                        buildOptionsCard(1, AppLocalizations.of(context)!.card),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if(_selectedOptionIndex == 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  setState(() {
                                    isSearching = true;
                                  });
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  hintText:
                                      '${AppLocalizations.of(context)!.search}...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.search,
                              color: NasColors.darkBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_selectedOptionIndex == 0) ...[
              Column(
                children: [
                  documentInfo!.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: documentInfo.length,
                    itemBuilder: (BuildContext context, int index) {
                      final documents = documentInfo[index];
                      final url = documents.remarks ?? '';
                      final fileType = url.split('.').last.toLowerCase();
                      final isImage = ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);
                      final isPdf = fileType == 'pdf';
                      final searchText = searchController.text.toLowerCase();
                      if (isSearching &&
                          !(documents.type?.toLowerCase().contains(searchText) ?? false)) {
                        return const SizedBox.shrink();
                      }
                      return Transform.translate(
                        offset: Offset(0, index == 0 ? 0 : -10),
                        child: GestureDetector(
                          onTap: () async {
                            if (isImage || isPdf || url.isNotEmpty) {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open the document!')),
                                );
                              }
                            } else {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  documents.type == "Doc_Contract_Emp"
                                      ? AppLocalizations.of(context)!.employmentContract
                                      : documents.type ?? '',
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
                                    url,
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
              )
            ],
            if (_selectedOptionIndex == 1) ...[
              SizedBox(height: 30),
              Column(children: [
                GestureDetector(
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
                            height: MediaQuery.of(context).size.height * 0.9,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.cnic,
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
                                            AppLocalizations.of(context)!.done,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  RepaintBoundary(
                                    key: _containerKey,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: NasColors.lightGrey,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFC3DBCB), // Start color
                                            Color(0xFFDBDBCF), // Middle color
                                            Color(0xFFC3DBCB), // End color
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Logos Row
                                          ClipRRect(
                                            borderRadius: BorderRadius.zero,
                                            child: Expanded(
                                              child: Image.asset(
                                                "images/cnicLogo.png",
                                                height: 50,
                                                width: double.infinity,
                                                fit: BoxFit.fitWidth,
                                                alignment: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Profile Image
                                              Padding(
                                                padding: const EdgeInsets.only(left: 18.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.zero,
                                                  child: (singletonClass.employeeDataList.first.data?.profilePic?.isNotEmpty ?? false)
                                                      ? Image.network(
                                                    singletonClass.employeeDataList.first.data!.profilePic!,
                                                    fit: BoxFit.cover,
                                                    width: 110,
                                                    height: 110,
                                                    errorBuilder: (context, error, stackTrace) => Image.asset(
                                                      'images/DP.png',
                                                      fit: BoxFit.cover,
                                                      width: 110,
                                                      height: 110,
                                                    ),
                                                  )
                                                      : Image.asset(
                                                    'images/DP.png',
                                                    fit: BoxFit.cover,
                                                    width: 110,
                                                    height: 110,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context)!.idNumber}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.nic ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    SizedBox(
                                                      width:170,
                                                      child: Text(
                                                        "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.dob ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.nationality ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.address != null ? singletonClass.employeeDataList.first.data!.address!.city ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
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
                                              RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                              var image = await boundary.toImage(pixelRatio: 3.0);
                                              ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                              Uint8List pngBytes = byteData!.buffer.asUint8List();
                                              final tempDir = await getTemporaryDirectory();
                                              final file = await File('${tempDir.path}/container_image.png').create();
                                              await file.writeAsBytes(pngBytes);
                                              await Share.shareXFiles([XFile(file.path)], text: 'Check out this container image!');
                                            } catch (e) {
                                              debugPrint('Error sharing container image: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to share container: $e')),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.ios_share,
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
                                            Clipboard.setData(ClipboardData(
                                                text: "images/cnic.png")); // Text to be copied
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: NasColors.lightBlue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.name,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.firstName}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.firstName}")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.cardNumber,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.nic}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.nic}",));
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.dateOfBirthInHijri,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.dob}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.dob}"));
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.expiryDateInHijri,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                      "N/A",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "N/A")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.placeOfBirth,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                      "${singletonClass.employeeDataList.first.data!.address!.city}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text:  "${singletonClass.employeeDataList.first.data!.address!.city}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 30, right: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 10,
                              offset: Offset(0,
                                  -6),
                            ),
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0,
                                5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.cnic,
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
                              "images/cnic.png",
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                    ))
              ]),
              Column(children: [
                GestureDetector(
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
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.9,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.iqama,
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
                                            AppLocalizations.of(context)!.done,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          )),
                                    ],
                                  ),
                                  RepaintBoundary(
                                    key: _iqamaContainerKey,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: NasColors.lightGrey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.asset(
                                                  "images/iqamaLogoLeft.png",
                                                  width: 100,
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.topCenter,
                                                ),
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.asset(
                                                  "images/iqamaLogo.png",
                                                  width: 100,
                                                  fit: BoxFit.contain,
                                                  alignment: Alignment.topCenter,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                child: Image.network(
                                                  singletonClass.employeeDataList.first.data?.profilePic ?? '',
                                                  fit: BoxFit.cover,
                                                  width: 110,
                                                  height: 130,
                                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                                    'images/DP.png',
                                                    fit: BoxFit.cover,
                                                    width: 110,
                                                    height: 130,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              SizedBox(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context)!.idNumber}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.iqamaNumber?.id ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    SizedBox(
                                                      width:170,
                                                      child: Text(
                                                        "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.dob ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.nationality ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.occupation}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.employeeInfo!.first.jobRank : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.address != null ? singletonClass.employeeDataList.first.data!.address!.city ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.religion}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.religion ?? 'N/A' : 'N/A'}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
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
                                              RenderRepaintBoundary boundary = _iqamaContainerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                              var image = await boundary.toImage(pixelRatio: 3.0);
                                              ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                              Uint8List pngBytes = byteData!.buffer.asUint8List();
                                              final tempDir = await getTemporaryDirectory();
                                              final file = await File('${tempDir.path}/iqama.png').create();
                                              await file.writeAsBytes(pngBytes);
                                              await Share.shareXFiles([XFile(file.path)], text: 'Check out this container image!');
                                            } catch (e) {
                                              debugPrint('Error sharing container image: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to share container: $e')),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.ios_share,
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
                                            Clipboard.setData(ClipboardData(
                                                text: "images/iqama.png"));
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: NasColors.lightBlue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.name,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.firstName}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.firstName}")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.cardNumber,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.iqamaNumber!.id}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                    text: "${singletonClass.employeeDataList.first.data!.iqamaNumber!.id}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                            CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.dateOfBirth,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.dob}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.dob}")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.expiryDate,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.iqamaNumber!.expiryDate}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.iqamaNumber!.expiryDate}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.placeOfBirth,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.address!.city}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                    text:  "${singletonClass.employeeDataList.first.data!.address!.city}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                      padding:
                      const EdgeInsets.only(top: 10.0, left: 30, right: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
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
                            AppLocalizations.of(context)!.iqama,
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
                              "images/iqama.png",
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                    ))
              ]),
              Column(children: [
                GestureDetector(
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
                            height: MediaQuery.of(context).size.height * 0.9,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.passport,
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
                                            AppLocalizations.of(context)!.done,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  RepaintBoundary(
                                    key: _passportContainerKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: NasColors.lightGrey,
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFF4F1E3),
                                            Color(0xFFEFF0E6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                              child: Image.asset(
                                                "images/passportHeader.png",
                                                height: 80,
                                                width: double.infinity,
                                                fit: BoxFit.fitWidth,
                                                alignment: Alignment.topCenter,
                                              ),
                                            ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 20.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.zero,
                                                  child:Image.network(
                                                    singletonClass.employeeDataList.first.data?.profilePic ?? '',
                                                    // URL for the network image, empty string if null
                                                    fit: BoxFit.cover,
                                                    width: 110,
                                                    height: 130,
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
                                              Spacer(),
                                              SizedBox(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.nationality?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.nationality : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.dob?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.dob : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppLocalizations.of(context)!.gender}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.gender?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.gender : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppLocalizations.of(context)!.fatherName}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.familyInfo!.fatherName : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "issue date: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.passport!.issueDate : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Expiry date: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.passport!.expiryDate : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.address!.city : 'N/A'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              Spacer()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
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
                                              RenderRepaintBoundary boundary = _passportContainerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                              var image = await boundary.toImage(pixelRatio: 3.0);
                                              ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                              Uint8List pngBytes = byteData!.buffer.asUint8List();
                                              final tempDir = await getTemporaryDirectory();
                                              final file = await File('${tempDir.path}/passport.png').create();
                                              await file.writeAsBytes(pngBytes);
                                              await Share.shareXFiles([XFile(file.path)], text: 'Check out this container image!');
                                            } catch (e) {
                                              debugPrint('Error sharing container image: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to share container: $e')),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.ios_share,
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
                                            Clipboard.setData(ClipboardData(
                                                text: "images/passport.png")); // Text to be copied
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: NasColors.lightBlue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.name,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.firstName}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.firstName}")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.cardNumber,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.passport!.id}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                    text: "${singletonClass.employeeDataList.first.data!.passport!.id}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                            CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.dateOfBirth,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.dob}",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.dob}")); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.expiryDate,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.passport!.expiryDate}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                      text: "${singletonClass.employeeDataList.first.data!.passport!.expiryDate}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.placeOfBirth,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "${singletonClass.employeeDataList.first.data!.address!.city}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  // Copy the image URL or any text to the clipboard
                                                  Clipboard.setData(ClipboardData(
                                                    text:  "${singletonClass.employeeDataList.first.data!.address!.city}",)); // Text to be copied
                                                },
                                                icon: const Icon(Icons.copy,
                                                    color: Colors.white),
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
                      padding:
                      const EdgeInsets.only(top: 10.0, left: 30, right: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
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
                            AppLocalizations.of(context)!.passport,
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
                              "images/passport.png",
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                    ))
              ]),
              Column(children: [
                GestureDetector(
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
                            height: MediaQuery.of(context).size.height * 0.9,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.employmentContract,
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
                                            AppLocalizations.of(context)!.done,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  RepaintBoundary(
                                    key: _employeeContractContainerKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: NasColors.lightGrey,
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFD7DCE0),
                                            Color(0xFFE6EBEE),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("${singletonClass.companyDataList.first.data!.name}",
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 15
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.zero,
                                                  child:Image.network(
                                                    singletonClass.employeeDataList.first.data?.profilePic ?? '',
                                                    // URL for the network image, empty string if null
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                    errorBuilder: (BuildContext context,
                                                        Object exception,
                                                        StackTrace? stackTrace) {
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
                                              Spacer(),
                                              SizedBox(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context)!.contractId}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractId : 'N/A'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:170,
                                                      child: Text(
                                                        "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.employeeNumber}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.employeeInfo!.first.empId : 'N/A'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.expiryDate}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractExpiry : 'N/A'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.contractStatus}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractStatus : 'N/A'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ),
                                              Spacer()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10.0),
                                                child: Container(
                                                  width: 86,
                                                  height: 37,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.zero,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.zero,
                                                    child: Image.network(
                                                      singletonClass.employeeDataList.first.data?.employeeInfo!.first.empSignature ?? '',
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                        return  Icon(
                                                          Icons.broken_image,
                                                          size: 30,
                                                          color: NasColors.darkBlue,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
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
                                              RenderRepaintBoundary boundary = _employeeContractContainerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                              var image = await boundary.toImage(pixelRatio: 3.0);
                                              ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                              Uint8List pngBytes = byteData!.buffer.asUint8List();
                                              final tempDir = await getTemporaryDirectory();
                                              final file = await File('${tempDir.path}/employee_contract.png').create();
                                              await file.writeAsBytes(pngBytes);
                                              await Share.shareXFiles([XFile(file.path)], text: 'Check out this container image!');
                                            } catch (e) {
                                              debugPrint('Error sharing container image: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to share container: $e')),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.ios_share,
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
                                          onPressed: () async {
                                            try {
                                              RenderRepaintBoundary boundary = _employeeContractContainerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                              ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                                              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                              Uint8List pngBytes = byteData!.buffer.asUint8List();

                                              final tempDir = await getTemporaryDirectory();
                                              final file = File('${tempDir.path}/copied_image.png');
                                              await file.writeAsBytes(pngBytes);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('image copied')),
                                              );
                                            } catch (e) {
                                              debugPrint('Error copying image: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to copy image: $e')),
                                              );
                                            }
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
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                                      color: NasColors.lightBlue,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.name,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    singletonClass.employeeDataList.isNotEmpty &&
                                                        singletonClass.employeeDataList.first.data != null
                                                        ? "${singletonClass.employeeDataList.first.data!.firstName}"
                                                        : "N/A",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: singletonClass.employeeDataList.isNotEmpty &&
                                                          singletonClass.employeeDataList.first.data != null
                                                          ? "${singletonClass.employeeDataList.first.data!.firstName}"
                                                          : "N/A",
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1, color: Colors.white),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.employeeNumber,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    singletonClass.employeeDataList.isNotEmpty &&
                                                        singletonClass.employeeDataList.first.data != null &&
                                                        singletonClass.employeeDataList.first.data!.employeeInfo != null &&
                                                        singletonClass.employeeDataList.first.data!.employeeInfo!.isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data!.employeeInfo!.first.empId}"
                                                        : "N/A",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: singletonClass.employeeDataList.isNotEmpty &&
                                                          singletonClass.employeeDataList.first.data != null &&
                                                          singletonClass.employeeDataList.first.data!.employeeInfo != null &&
                                                          singletonClass.employeeDataList.first.data!.employeeInfo!.isNotEmpty
                                                          ? "${singletonClass.employeeDataList.first.data!.employeeInfo!.first.empId}"
                                                          : "N/A",
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1, color: Colors.white),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.contractId,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    singletonClass.employeeDataList.isNotEmpty &&
                                                        singletonClass.employeeDataList.first.data != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractId}"
                                                        : "N/A",
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: singletonClass.employeeDataList.isNotEmpty &&
                                                          singletonClass.employeeDataList.first.data != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                          ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractId}"
                                                          : "N/A",
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1, color: Colors.white),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.expiryDate,
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    singletonClass.employeeDataList.isNotEmpty &&
                                                        singletonClass.employeeDataList.first.data != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractExpiry}"
                                                        : "N/A",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: singletonClass.employeeDataList.isNotEmpty &&
                                                          singletonClass.employeeDataList.first.data != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                          ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractExpiry}"
                                                          : "N/A",
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1, color: Colors.white),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${AppLocalizations.of(context)!.contract}${AppLocalizations.of(context)!.type}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    singletonClass.employeeDataList.isNotEmpty &&
                                                        singletonClass.employeeDataList.first.data != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                        singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractType}"
                                                        : "N/A",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: singletonClass.employeeDataList.isNotEmpty &&
                                                          singletonClass.employeeDataList.first.data != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo != null &&
                                                          singletonClass.employeeDataList.first.data!.contractInfo!.isNotEmpty
                                                          ? "${singletonClass.employeeDataList.first.data!.contractInfo!.first.contractType}"
                                                          : "N/A",
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.copy, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(height: 1, color: Colors.white),
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
                      padding:
                      const EdgeInsets.only(top: 10.0, left: 30, right: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 10,
                            offset: Offset(0,
                                -6),
                          ),
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0,
                                5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.employmentContract,
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
                              "images/companyCard.png",
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                    ))
              ]),
            ],
          ],
        ),
      ]),
    );
  }

  //CARDS
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
          elevation: 100.0,
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
                  fontSize: 17,
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
