import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DocumentCardsTab extends StatefulWidget {
  final SingletonClass singletonClass;

  const DocumentCardsTab({super.key, required this.singletonClass});

  @override
  State<DocumentCardsTab> createState() => _DocumentCardsTabState();
}

class _DocumentCardsTabState extends State<DocumentCardsTab> {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _iqamaContainerKey = GlobalKey();
  final GlobalKey _passportContainerKey = GlobalKey();
  final GlobalKey _employeeContractContainerKey = GlobalKey();

  SingletonClass get singletonClass => widget.singletonClass;

  @override
  Widget build(BuildContext context) {
    if (singletonClass.employeeDataList.isEmpty || 
        singletonClass.employeeDataList.first.data.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 30),
            if (singletonClass.employeeDataList.first.data.first.nationality ==
                "Saudi Arabia" || singletonClass.employeeDataList.first.data.first.nationality ==
                "العربية السعودية")
              Column(
                  children: [
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
                                                AppLocalizations.of(context)!
                                                    .done,
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
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              // Logos Row
                                              ClipRRect(
                                                borderRadius: BorderRadius.zero,
                                                child: Image.asset(
                                                  "images/cnicLogo.png",
                                                  height: 50,
                                                  width: double.infinity,
                                                  fit: BoxFit.fitWidth,
                                                  alignment: Alignment.topCenter,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  // Profile Image
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        left: 18.0),
                                                    child:  ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.zero,
                                                        child: singletonClass.employeeDataList.first.data.first.profilePic != "https://www.profilePic.com" ? Image.network(
                                                          singletonClass
                                                              .employeeDataList
                                                              .first
                                                              .data.first
                                                              .profilePic ??
                                                              '',
                                                          fit: BoxFit.cover,
                                                          width: 100,
                                                          height: 100,
                                                          errorBuilder:
                                                              (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                              stackTrace) {
                                                            return Image.asset(
                                                              'images/DP.png',
                                                              fit: BoxFit.cover,
                                                              width: 100,
                                                              height: 100,
                                                            );
                                                          },
                                                        ) : Image.asset(
                                                          'images/DP.png',
                                                          fit: BoxFit.cover,
                                                          width: 100,
                                                          height: 100,
                                                        )
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Text(
                                                          "${AppLocalizations.of(context)!.idNumber}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.nic ?? '---' : '---'}",
                                                          style:
                                                          GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: NasColors
                                                                .darkBlue,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.5),
                                                        SizedBox(
                                                          width: 170,
                                                          child: Text(
                                                            "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data.first.firstName ?? '---'} ${singletonClass.employeeDataList.first.data.first.middleName ?? '---'} ${singletonClass.employeeDataList.first.data.first.lastName ?? '---'}' : '---'}",
                                                            style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12,
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              color: NasColors
                                                                  .darkBlue,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.5),
                                                        Text(
                                                          "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.dob ?? '---' : '---'}",
                                                          style:
                                                          GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: NasColors
                                                                .darkBlue,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.5),
                                                        Text(
                                                          "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.nationality ?? '---' : '---'}",
                                                          style:
                                                          GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: NasColors
                                                                .darkBlue,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2.5),
                                                        Text(
                                                          "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.address != null ? singletonClass.employeeDataList.first.data.first.address!.city ?? '---' : '---'}",
                                                          style:
                                                          GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: NasColors
                                                                .darkBlue,
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
                                                  RenderRepaintBoundary boundary =
                                                  _containerKey
                                                      .currentContext!
                                                      .findRenderObject()
                                                  as RenderRepaintBoundary;
                                                  var image = await boundary
                                                      .toImage(pixelRatio: 3.0);
                                                  ByteData? byteData =
                                                  await image.toByteData(
                                                      format: ImageByteFormat
                                                          .png);
                                                  Uint8List pngBytes = byteData!
                                                      .buffer
                                                      .asUint8List();
                                                  final tempDir =
                                                  await getTemporaryDirectory();
                                                  final file = await File(
                                                      '${tempDir.path}/container_image.png')
                                                      .create();
                                                  await file
                                                      .writeAsBytes(pngBytes);
                                                  await Share.shareXFiles(
                                                      [XFile(file.path)],
                                                      text:
                                                      'Check out this container image!');
                                                } catch (e) {
                                                  debugPrint(
                                                      'Error sharing container image: $e');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Failed to share container: $e')),
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
                                                    text:
                                                    "images/cnic.png")); // Text to be copied
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
                                                        AppLocalizations.of(
                                                            context)!
                                                            .name,
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
                                                        "${singletonClass.employeeDataList.first.data.first.firstName}",
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
                                                          text:
                                                          "${singletonClass.employeeDataList.first.data.first.firstName}"));
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
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(
                                                            context)!
                                                            .cardNumber,
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
                                                        "${singletonClass.employeeDataList.first.data.first.nic}",
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
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                            text:
                                                            "${singletonClass.employeeDataList.first.data.first.nic}",
                                                          ));
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
                                                        AppLocalizations.of(
                                                            context)!
                                                            .dateOfBirthInHijri,
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
                                                        "${singletonClass.employeeDataList.first.data.first.dob}",
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
                                                          text:
                                                          "${singletonClass.employeeDataList.first.data.first.dob}"));
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
                                                        AppLocalizations.of(
                                                            context)!
                                                            .expiryDateInHijri,
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
                                                        "---",
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
                                                          text:
                                                          "---")); // Text to be copied
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
                                                        AppLocalizations.of(
                                                            context)!
                                                            .placeOfBirth,
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
                                                        "${singletonClass.employeeDataList.first.data.first.address!.city}",
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
                                                      Clipboard.setData(
                                                          ClipboardData(
                                                            text:
                                                            "${singletonClass.employeeDataList.first.data.first.address!.city}",
                                                          )); // Text to be copied
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
                          padding: const EdgeInsets.only(top: 10.0, left: 30, right: 30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
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
                                  height: 50,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ],
                          ),
                        ))
                  ]),

            ///Iqama
            (singletonClass.employeeDataList.first.data.first.nationality == "Saudi Arabia" ||
                singletonClass.employeeDataList.first.data.first.nationality == "العربية السعودية"
            )
                ? const SizedBox.shrink()
                : Column(children: [
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
                          height:
                          MediaQuery.of(context).size.height * 0.9,
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .iqama,
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
                                          AppLocalizations.of(context)!
                                              .done,
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
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              child: Image.asset(
                                                "images/iqamaLogoLeft.png",
                                                width: 100,
                                                fit: BoxFit.contain,
                                                alignment:
                                                Alignment.topCenter,
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              child: Image.asset(
                                                "images/iqamaLogo.png",
                                                width: 100,
                                                fit: BoxFit.contain,
                                                alignment:
                                                Alignment.topCenter,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                BorderRadius.zero,
                                                child: singletonClass.employeeDataList.first.data.first.profilePic != "https://www.profilePic.com" ? Image.network(
                                                  singletonClass
                                                      .employeeDataList
                                                      .first
                                                      .data.first
                                                      .profilePic ??
                                                      '',
                                                  fit: BoxFit.cover,
                                                  width: 100,
                                                  height: 100,
                                                  errorBuilder:
                                                      (BuildContext context,
                                                      Object exception,
                                                      StackTrace?
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'images/DP.png',
                                                      fit: BoxFit.cover,
                                                      width: 100,
                                                      height: 100,
                                                    );
                                                  },
                                                ) : Image.asset(
                                                  'images/DP.png',
                                                  fit: BoxFit.cover,
                                                  width: 100,
                                                  height: 100,
                                                )
                                            ),
                                            SizedBox(width: 10),
                                            SizedBox(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    "${AppLocalizations.of(context)!.idNumber}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.iqamaNumber?.id ?? '---' : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  SizedBox(
                                                    width: 170,
                                                    child: Text(
                                                      "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data.first.firstName ?? '---'} ${singletonClass.employeeDataList.first.data.first.middleName ?? '---'} ${singletonClass.employeeDataList.first.data.first.lastName ?? '---'}' : '---'}",
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                        color: NasColors
                                                            .darkBlue,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.dob ?? '---' : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.nationality ?? '---' : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.occupation}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.employeeInfo!.first.jobRank : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.address != null ? singletonClass.employeeDataList.first.data.first.address!.city ?? '---' : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.5),
                                                  Text(
                                                    "${AppLocalizations.of(context)!.religion}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.religion ?? '---' : '---'}",
                                                    style: GoogleFonts
                                                        .inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                      color: NasColors
                                                          .darkBlue,
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
                                            RenderRepaintBoundary
                                            boundary =
                                            _iqamaContainerKey
                                                .currentContext!
                                                .findRenderObject()
                                            as RenderRepaintBoundary;
                                            var image =
                                            await boundary.toImage(
                                                pixelRatio: 3.0);
                                            ByteData? byteData =
                                            await image.toByteData(
                                                format:
                                                ImageByteFormat
                                                    .png);
                                            Uint8List pngBytes =
                                            byteData!.buffer
                                                .asUint8List();
                                            final tempDir =
                                            await getTemporaryDirectory();
                                            final file = await File(
                                                '${tempDir.path}/iqama.png')
                                                .create();
                                            await file
                                                .writeAsBytes(pngBytes);
                                            await Share.shareXFiles(
                                                [XFile(file.path)],
                                                text:
                                                'Check out this container image!');
                                          } catch (e) {
                                            debugPrint(
                                                'Error sharing container image: $e');
                                            ScaffoldMessenger.of(
                                                context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to share container: $e')),
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
                                          Clipboard.setData(ClipboardData(
                                              text:
                                              "images/iqama.png"));
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
                                    borderRadius:
                                    const BorderRadius.all(
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
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .name,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  "${singletonClass.employeeDataList.first.data.first.firstName}",
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
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
                                                        "${singletonClass.employeeDataList.first.data.first.firstName}"));
                                              },
                                              icon: const Icon(
                                                  Icons.copy,
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
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .cardNumber,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 5),
                                                Text(
                                                  "${singletonClass.employeeDataList.first.data.first.iqamaNumber!.id}",
                                                  textAlign:
                                                  TextAlign.left,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
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
                                                      "${singletonClass.employeeDataList.first.data.first.iqamaNumber!.id}",
                                                    ));
                                              },
                                              icon: const Icon(
                                                  Icons.copy,
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
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .dateOfBirth,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 5),
                                                Text(
                                                  "${singletonClass.employeeDataList.first.data.first.dob}",
                                                  textAlign:
                                                  TextAlign.left,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
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
                                                        "${singletonClass.employeeDataList.first.data.first.dob}"));
                                              },
                                              icon: const Icon(
                                                  Icons.copy,
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
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .expiryDate,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 5),
                                                Text(
                                                  "${singletonClass.employeeDataList.first.data.first.iqamaNumber!.expiryDate}",
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
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
                                                      "${singletonClass.employeeDataList.first.data.first.iqamaNumber!.expiryDate}",
                                                    )); // Text to be copied
                                              },
                                              icon: const Icon(
                                                  Icons.copy,
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
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .placeOfBirth,
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 5),
                                                Text(
                                                  "${singletonClass.employeeDataList.first.data.first.address!.city}",
                                                  maxLines: 4,
                                                  softWrap: true,
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                    color: Colors.white,
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
                                                      "${singletonClass.employeeDataList.first.data.first.address!.city}",
                                                    )); // Text to be copied
                                              },
                                              icon: const Icon(
                                                  Icons.copy,
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
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 30, right: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
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

            ///Passport
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
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          child: Image.asset(
                                            "images/passportHeader.png",
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.zero,
                                                  child: singletonClass.employeeDataList.first.data.first.profilePic != "https://www.profilePic.com" ? Image.network(
                                                    singletonClass
                                                        .employeeDataList
                                                        .first
                                                        .data.first
                                                        .profilePic ??
                                                        '',
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                        Object exception,
                                                        StackTrace?
                                                        stackTrace) {
                                                      return Image.asset(
                                                        'images/DP.png',
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      );
                                                    },
                                                  ) : Image.asset(
                                                    'images/DP.png',
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                  )
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data.first.firstName ?? '---'} ${singletonClass.employeeDataList.first.data.first.middleName ?? '---'} ${singletonClass.employeeDataList.first.data.first.lastName ?? '---'}' : '---'}",
                                                      maxLines: 4,
                                                      softWrap: true,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.nationality}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.nationality?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.nationality : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.dateOfBirth}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.dob?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.dob : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.gender}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.gender?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.gender : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.fatherName}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.familyInfo!.fatherName : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "issue date: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.passport!.issueDate : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Expiry date: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.passport!.expiryDate : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.placeOfBirth}: ${singletonClass.employeeDataList.isNotEmpty ? singletonClass.employeeDataList.first.data.first.address!.city : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                )),
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
                                            RenderRepaintBoundary boundary =
                                            _passportContainerKey
                                                .currentContext!
                                                .findRenderObject()
                                            as RenderRepaintBoundary;
                                            var image = await boundary
                                                .toImage(pixelRatio: 3.0);
                                            ByteData? byteData =
                                            await image.toByteData(
                                                format:
                                                ImageByteFormat.png);
                                            Uint8List pngBytes = byteData!
                                                .buffer
                                                .asUint8List();
                                            final tempDir =
                                            await getTemporaryDirectory();
                                            final file = await File(
                                                '${tempDir.path}/passport.png')
                                                .create();
                                            await file.writeAsBytes(pngBytes);
                                            await Share.shareXFiles(
                                                [XFile(file.path)],
                                                text:
                                                'Check out this container image!');
                                          } catch (e) {
                                            debugPrint(
                                                'Error sharing container image: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to share container: $e')),
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
                                              text:
                                              "images/passport.png")); // Text to be copied
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .name,
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
                                                  "${singletonClass.employeeDataList.first.data.first.firstName}",
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
                                                    text:
                                                    "${singletonClass.employeeDataList.first.data.first.firstName}"));
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .cardNumber,
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
                                                  "${singletonClass.employeeDataList.first.data.first.passport!.id}",
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
                                                Clipboard.setData(
                                                    ClipboardData(
                                                      text:
                                                      "${singletonClass.employeeDataList.first.data.first.passport!.id}",
                                                    ));
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .dateOfBirth,
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
                                                  "${singletonClass.employeeDataList.first.data.first.dob}",
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
                                                    text:
                                                    "${singletonClass.employeeDataList.first.data.first.dob}")); // Text to be copied
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .expiryDate,
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
                                                  "${singletonClass.employeeDataList.first.data.first.passport!.expiryDate}",
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
                                                Clipboard.setData(
                                                    ClipboardData(
                                                      text:
                                                      "${singletonClass.employeeDataList.first.data.first.passport!.expiryDate}",
                                                    )); // Text to be copied
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .placeOfBirth,
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
                                                  "${singletonClass.employeeDataList.first.data.first.address!.city}",
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
                                                Clipboard.setData(
                                                    ClipboardData(
                                                      text:
                                                      "${singletonClass.employeeDataList.first.data.first.address!.city}",
                                                    )); // Text to be copied
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

            ///Employee Contract
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
                                      AppLocalizations.of(context)!
                                          .employmentContract,
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
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                BorderRadius.zero,
                                                child: Image.network(
                                                  singletonClass
                                                      .companyDataList
                                                      .first
                                                      .data
                                                      ?.logo ??
                                                      '',
                                                  fit: BoxFit.fill,
                                                  width: 40,
                                                  height: 40,
                                                  errorBuilder:
                                                      (BuildContext context,
                                                      Object exception,
                                                      StackTrace?
                                                      stackTrace) {
                                                    return Image.asset(
                                                      'images/site.png',
                                                      fit: BoxFit.fill,
                                                      width: 40,
                                                      height: 40,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            Text(
                                              "${singletonClass.companyDataList.first.data!.name}",
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.zero,
                                                  child: singletonClass.employeeDataList.first.data.first.profilePic != "https://www.profilePic.com" ? Image.network(
                                                    singletonClass
                                                        .employeeDataList
                                                        .first
                                                        .data.first
                                                        .profilePic ??
                                                        '',
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                        Object exception,
                                                        StackTrace?
                                                        stackTrace) {
                                                      return Image.asset(
                                                        'images/DP.png',
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      );
                                                    },
                                                  ) : Image.asset(
                                                    'images/DP.png',
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                  )
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 170,
                                                      child: Text(
                                                        "${AppLocalizations.of(context)!.name}: ${singletonClass.employeeDataList.isNotEmpty ? '${singletonClass.employeeDataList.first.data.first.firstName ?? '---'} ${singletonClass.employeeDataList.first.data.first.middleName ?? '---'} ${singletonClass.employeeDataList.first.data.first.lastName ?? '---'}' : '---'}",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        textAlign: TextAlign.left,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          color:
                                                          NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 200,
                                                      child: Text(
                                                        "${AppLocalizations.of(context)!.designation}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.employeeInfo!.first.designation : '---'}",
                                                        maxLines: 4,
                                                        textAlign: TextAlign.left,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.employeeNumber}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.employeeInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.employeeInfo!.first.empId : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 200,
                                                      child: Divider(
                                                        color: Colors.black,
                                                        thickness: 1,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.contractId}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractId : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.expiryDate}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractExpiry : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${AppLocalizations.of(context)!.contractStatus}: ${singletonClass.employeeDataList.isNotEmpty && singletonClass.employeeDataList.first.data.first.contractInfo?.isNotEmpty == true ? singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractStatus : '---'}",
                                                      maxLines: 4,
                                                      textAlign: TextAlign.left,
                                                      softWrap: true,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        color: NasColors.darkBlue,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Spacer()
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Container(
                                                width: 86,
                                                height: 37,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.zero,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.zero,
                                                  child: Image.network(
                                                    singletonClass
                                                        .employeeDataList
                                                        .first
                                                        .data.first
                                                        .employeeInfo!
                                                        .first
                                                        .empSignature ??
                                                        '---',
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                        Object exception,
                                                        StackTrace?
                                                        stackTrace) {
                                                      return Text(AppLocalizations.of(context)!.noSignature,
                                                        style: GoogleFonts.inter(
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.normal,
                                                         color: Colors.black
                                                        ),
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
                                            RenderRepaintBoundary boundary =
                                            _employeeContractContainerKey
                                                .currentContext!
                                                .findRenderObject()
                                            as RenderRepaintBoundary;
                                            var image = await boundary
                                                .toImage(pixelRatio: 3.0);
                                            ByteData? byteData =
                                            await image.toByteData(
                                                format:
                                                ImageByteFormat.png);
                                            Uint8List pngBytes = byteData!
                                                .buffer
                                                .asUint8List();
                                            final tempDir =
                                            await getTemporaryDirectory();
                                            final file = await File(
                                                '${tempDir.path}/employee_contract.png')
                                                .create();
                                            await file.writeAsBytes(pngBytes);
                                            await Share.shareXFiles(
                                                [XFile(file.path)],
                                                text:
                                                'Check out this container image!');
                                          } catch (e) {
                                            debugPrint(
                                                'Error sharing container image: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to share container: $e')),
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
                                            RenderRepaintBoundary boundary =
                                            _employeeContractContainerKey
                                                .currentContext!
                                                .findRenderObject()
                                            as RenderRepaintBoundary;
                                            ui.Image image = await boundary
                                                .toImage(pixelRatio: 3.0);
                                            ByteData? byteData =
                                            await image.toByteData(
                                                format: ui
                                                    .ImageByteFormat.png);
                                            Uint8List pngBytes = byteData!
                                                .buffer
                                                .asUint8List();

                                            final tempDir =
                                            await getTemporaryDirectory();
                                            final file = File(
                                                '${tempDir.path}/copied_image.png');
                                            await file.writeAsBytes(pngBytes);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content:
                                                  Text('image copied')),
                                            );
                                          } catch (e) {
                                            debugPrint(
                                                'Error copying image: $e');
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to copy image: $e')),
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .name,
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
                                                  singletonClass
                                                      .employeeDataList
                                                      .isNotEmpty
                                                      ? "${singletonClass.employeeDataList.first.data.first.firstName}"
                                                      : "---",
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
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: singletonClass
                                                        .employeeDataList
                                                        .isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data.first.firstName}"
                                                        : "---",
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            height: 1, color: Colors.white),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .employeeNumber,
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
                                                  singletonClass
                                                      .employeeDataList
                                                      .isNotEmpty &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .employeeInfo !=
                                                          null &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .employeeInfo!
                                                          .isNotEmpty
                                                      ? "${singletonClass.employeeDataList.first.data.first.employeeInfo!.first.empId}"
                                                      : "---",
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
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: singletonClass
                                                        .employeeDataList
                                                        .isNotEmpty &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .employeeInfo !=
                                                            null &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .employeeInfo!
                                                            .isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data.first.employeeInfo!.first.empId}"
                                                        : "---",
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            height: 1, color: Colors.white),
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
                                                  AppLocalizations.of(
                                                      context)!
                                                      .contractId,
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
                                                  singletonClass
                                                      .employeeDataList
                                                      .isNotEmpty &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo !=
                                                          null &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo!
                                                          .isNotEmpty
                                                      ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractId}"
                                                      : "---",
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
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: singletonClass
                                                        .employeeDataList
                                                        .isNotEmpty &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo !=
                                                            null &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo!
                                                            .isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractId}"
                                                        : "---",
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            height: 1, color: Colors.white),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(
                                                      context)!
                                                      .expiryDate,
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
                                                  singletonClass
                                                      .employeeDataList
                                                      .isNotEmpty &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo !=
                                                          null &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo!
                                                          .isNotEmpty
                                                      ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractExpiry}"
                                                      : "---",
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
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: singletonClass
                                                        .employeeDataList
                                                        .isNotEmpty &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo !=
                                                            null &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo!
                                                            .isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractExpiry}"
                                                        : "---",
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            height: 1, color: Colors.white),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${AppLocalizations.of(context)!.contract}${AppLocalizations.of(context)!.type}",
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
                                                  singletonClass
                                                      .employeeDataList
                                                      .isNotEmpty &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo !=
                                                          null &&
                                                      singletonClass
                                                          .employeeDataList
                                                          .first
                                                          .data.first
                                                          .contractInfo!
                                                          .isNotEmpty
                                                      ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractType}"
                                                      : "---",
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
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: singletonClass
                                                        .employeeDataList
                                                        .isNotEmpty &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo !=
                                                            null &&
                                                        singletonClass
                                                            .employeeDataList
                                                            .first
                                                            .data.first
                                                            .contractInfo!
                                                            .isNotEmpty
                                                        ? "${singletonClass.employeeDataList.first.data.first.contractInfo!.first.contractType}"
                                                        : "---",
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.copy,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        const Divider(
                                            height: 1, color: Colors.white),
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
                          AppLocalizations.of(context)!.employmentContract,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: NasColors.lightGrey,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.zero,
                                      child: Image.network(
                                        (singletonClass.companyDataList
                                            .isNotEmpty &&
                                            singletonClass.companyDataList
                                                .first.data?.logo !=
                                                null)
                                            ? singletonClass.companyDataList
                                            .first.data!.logo!
                                            : '',
                                        fit: BoxFit.fill,
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'images/site.png',
                                            fit: BoxFit.fill,
                                            width: 40,
                                            height: 40,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 100),
                                  Expanded(
                                    child: Text(
                                      (singletonClass.companyDataList
                                          .isNotEmpty &&
                                          singletonClass.companyDataList
                                              .first.data?.name !=
                                              null)
                                          ? singletonClass.companyDataList
                                          .first.data!.name!
                                          : '',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
            ]),
        ],
    );
  }
}
