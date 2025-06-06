import 'dart:io';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/create_hr_letter_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
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
                            final fileType = documents.format
                                ?.split('.')
                                .last
                                .toLowerCase(); // Null check for documents.type
                            final isImage = fileType != null &&
                                ['png', 'jpg', 'jpeg', 'gif']
                                    .contains(fileType);
                            final isPdf = fileType == 'pdf';

                            return Transform.translate(
                              offset: Offset(0, index == 0 ? 0 : -10),
                              child: GestureDetector(
                                onTap: () async {
                                  if (isImage || isPdf) {
                                    if (await canLaunch(documents.url)) {
                                      await launch(documents.url);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Could not open the document!')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Unsupported file type!')),
                                    );
                                  }
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
                                        "CNIC",
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
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  Container(
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
                                          borderRadius: BorderRadius.circular(10),
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Profile Image
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: (singletonClass.employeeDataList.first.data?.profilePic?.isNotEmpty ?? false)
                                                  ? Image.network(
                                                singletonClass.employeeDataList.first.data!.profilePic!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                                  'images/DP.png',
                                                  fit: BoxFit.cover,
                                                  width: 100,
                                                  height: 100,
                                                ),
                                              )
                                                  : Image.asset(
                                                'images/DP.png',
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            // Info Texts
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ID Number: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.nic ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Name: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Date of Birth: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.dob ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Nationality: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.nationality ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Place of Birth: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.address != null ? singletonClass.employeeDataList.first.data!.address!.city ?? 'N/A' : 'N/A'}",
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
                                      ],
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
                                              final byteData = await rootBundle
                                                  .load('images/iqama.png');
                                              final tempDir =
                                                  await getTemporaryDirectory();
                                              final file = File(
                                                  '${tempDir.path}/iqama.png');
                                              await file.writeAsBytes(byteData
                                                  .buffer
                                                  .asUint8List());

                                              // Share the temporary file
                                              await Share.shareXFiles([
                                                XFile(file.path)
                                              ], text: 'Check out this image!');
                                            } catch (e) {
                                              // Handle any errors that occur during the process
                                              debugPrint(
                                                  'Error sharing image: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to share image: $e')),
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
                                                    "Name in Arabic",
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
                                                    "Card Number",
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
                                                      text: "${singletonClass.employeeDataList.first.data!.nic}",)); // Text to be copied
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
                                                    "Date of Birth in Hijri",
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
                                                    "Expiry date in Hijri",
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
                                                    "Place of Birth",
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
                            "CNIC",
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
                                        "Iqama",
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
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: NasColors.lightGrey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Logos Row
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Profile Image
                                            ClipRRect(
                                              child: Image.network(
                                                singletonClass.employeeDataList.first.data?.profilePic ?? '',
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                                  'images/DP.png',
                                                  fit: BoxFit.cover,
                                                  width: 100,
                                                  height: 100,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            // Info Texts
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ID Number: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data!.iqamaNumber?.id ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Name: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Date of Birth: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.dob ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Nationality: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.nationality ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Occupation: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.employeeInfo!.first.jobRank : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Place of Birth: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.address != null ? singletonClass.employeeDataList.first.data!.address!.city ?? 'N/A' : 'N/A'}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "Religion: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data?.religion ?? 'N/A' : 'N/A'}",
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
                                      ],
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
                                              final byteData = await rootBundle
                                                  .load('images/iqama.png');
                                              final tempDir =
                                              await getTemporaryDirectory();
                                              final file = File(
                                                  '${tempDir.path}/iqama.png');
                                              await file.writeAsBytes(byteData
                                                  .buffer
                                                  .asUint8List());

                                              // Share the temporary file
                                              await Share.shareXFiles([
                                                XFile(file.path)
                                              ], text: 'Check out this image!');
                                            } catch (e) {
                                              // Handle any errors that occur during the process
                                              debugPrint(
                                                  'Error sharing image: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to share image: $e')),
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
                                                text: "images/iqama.png")); // Text to be copied
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
                                                    "Name in Arabic",
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
                                                    "Card Number",
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
                                                    "Date of Birth in Hijri",
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
                                                    "Expiry date in Hijri",
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
                                                    "Place of Birth",
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
                            "Iqama",
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
                                        "Passport",
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
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      "images/passport.png",
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
                                              final byteData = await rootBundle
                                                  .load('images/passport.png');
                                              final tempDir =
                                              await getTemporaryDirectory();
                                              final file = File(
                                                  '${tempDir.path}/passport.png');
                                              await file.writeAsBytes(byteData
                                                  .buffer
                                                  .asUint8List());

                                              // Share the temporary file
                                              await Share.shareXFiles([
                                                XFile(file.path)
                                              ], text: 'Check out this image!');
                                            } catch (e) {
                                              // Handle any errors that occur during the process
                                              debugPrint(
                                                  'Error sharing image: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to share image: $e')),
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
                                                    "Name in Arabic",
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
                                                    "Card Number",
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
                                                    "Date of Birth in Hijri",
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
                                                    "Expiry date in Hijri",
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
                                                    "Place of Birth",
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
                            "Passport",
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
                                        "Employment Contract",
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
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ))
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NasColors.lightGrey,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset(
                                            "images/employeeContractHeader.png",
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
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child:Image.network(
                                                  singletonClass.employeeDataList.first.data?.profilePic ?? '',
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
                                            Spacer(),
                                            SizedBox(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Contract ID: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractId : 'N/A'}",
                                                    maxLines: 4,
                                                    textAlign: TextAlign.left,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Name: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data?.firstName ?? ''} ${singletonClass.employeeDataList.first.data?.middleName ?? ''} ${singletonClass.employeeDataList.first.data?.lastName ?? ''}' : 'N/A'}",
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Employee Number: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.employeeInfo!.first.empId : 'N/A'}",
                                                    maxLines: 4,
                                                    textAlign: TextAlign.left,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Expiry Date: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractExpiry : 'N/A'}",
                                                    maxLines: 4,
                                                    textAlign: TextAlign.left,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Contract Status: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data?.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data!.contractInfo!.first.contractStatus : 'N/A'}",
                                                    maxLines: 4,
                                                    textAlign: TextAlign.left,
                                                    softWrap: true,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
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
                                        SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10) , bottomRight:  Radius.circular(10)),
                                          child: Image.asset(
                                            "images/employeeContractFooter.png",

                                            fit: BoxFit.fitWidth,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ],
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
                                              final byteData = await rootBundle
                                                  .load('images/companyCard.png');
                                              final tempDir =
                                              await getTemporaryDirectory();
                                              final file = File(
                                                  '${tempDir.path}/companyCard.png');
                                              await file.writeAsBytes(byteData
                                                  .buffer
                                                  .asUint8List());

                                              // Share the temporary file
                                              await Share.shareXFiles([
                                                XFile(file.path)
                                              ], text: 'Check out this image!');
                                            } catch (e) {
                                              // Handle any errors that occur during the process
                                              debugPrint(
                                                  'Error sharing image: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to share image: $e')),
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
                                                text: "images/companyCard.png")); // Text to be copied
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
                                                    "Name",
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
                                                    "Employee Number",
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
                                                    "Contract ID",
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
                                                    "Contract expiry",
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
                                                    "Contract Type",
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
                            "Employent Contract",
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
