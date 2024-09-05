import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/colors.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  SingletonClass singletonClass = SingletonClass();
  final List<Document> documentInfoDummy = [
    // Example data, replace with your actual document data
    Document(imageUrl: 'images/cnic.png',
        name: 'العمراني، نصار ابراهيم',
        cardNumber: '1027195021',
        dateOfBirthInHijri: '1404/04/05',
        expiryDateInHijri: '1450/11/29',
        placeOfBirth: 'Alqaan'),
    Document(imageUrl: 'images/iqama.png',
        name: 'العمراني، نصار ابراهيم',
        cardNumber: '1027195021',
        dateOfBirthInHijri: '1404/04/05',
        expiryDateInHijri: '1450/11/29',
        placeOfBirth: 'Alqaan'),
  ];

  @override
  Widget build(BuildContext context) {
    final documentInfo = singletonClass.employeeDataList.first.data!
        .documentsInfo;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0 , left: 20 , right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
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
                      Text(
                        AppLocalizations.of(context)!.myDocuments,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 50,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                                  hintText: '${AppLocalizations.of(context)!.search}...',
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
            Column(
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
                                height: MediaQuery
                                    .of(context)
                                    .size
                                    .height *
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
                                        borderRadius: BorderRadius.circular(10),
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
                                                  final byteData = await rootBundle
                                                      .load(
                                                      'images/iqama.png'); // Update with your asset path

                                                  // Get the temporary directory
                                                  final tempDir = await getTemporaryDirectory();

                                                  // Create a temporary file in the directory
                                                  final file = File(
                                                      '${tempDir.path}/iqama.png');

                                                  // Write the image bytes to the temporary file
                                                  await file.writeAsBytes(
                                                      byteData.buffer.asUint8List());

                                                  // Share the temporary file
                                                  await Share.shareXFiles(
                                                      [XFile(file.path)],
                                                      text: 'Check out this image!');
                                                } catch (e) {
                                                  // Handle any errors that occur during the process
                                                  debugPrint(
                                                      'Error sharing image: $e');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(content: Text(
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
                                                    text: images
                                                        .imageUrl)); // Text to be copied
                                              },
                                              icon: const Icon(
                                                  Icons.copy, color: Colors.white),
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
                                              icon: const Icon(
                                                  Icons.star, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.start,
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Column(
                                      //       crossAxisAlignment: CrossAxisAlignment
                                      //           .start, // Align text to start
                                      //       children: [
                                      //         ClipRRect(
                                      //           borderRadius: BorderRadius.circular(
                                      //               10),
                                      //           child: SizedBox(
                                      //             width: 200, // Set a fixed width
                                      //             height: 100, // Set a fixed height
                                      //             child: Image.asset(
                                      //               'images/govtLogo.png',
                                      //               fit: BoxFit.cover,
                                      //               alignment: Alignment.topCenter,
                                      //               errorBuilder: (context, error,
                                      //                   stackTrace) {
                                      //                 return const Icon(
                                      //                   Icons.broken_image,
                                      //                   size: 60,
                                      //                   color: Colors.grey,
                                      //                 );
                                      //               },
                                      //             ),
                                      //           ),
                                      //         ),
                                      //         const SizedBox(height: 10),
                                      //         // Add spacing between image and text
                                      //         SizedBox(
                                      //           width: 220,
                                      //           child: Text(
                                      //             "You must ensure validating the OTP prior to considering the ID an official one",
                                      //             maxLines: 4,
                                      //             softWrap: true,
                                      //             style: GoogleFonts.inter(
                                      //               fontSize: 15,
                                      //               fontWeight: FontWeight.normal,
                                      //               color: Colors.white,
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //     ClipRRect(
                                      //       borderRadius: BorderRadius.circular(10),
                                      //       child: SizedBox(
                                      //         height: 120,// Set a fixed height
                                      //         child: Image.asset(
                                      //           'images/qrCode.png',
                                      //           fit: BoxFit.cover,
                                      //           alignment: Alignment.topCenter,
                                      //           errorBuilder: (context, error,
                                      //               stackTrace) {
                                      //             return const Icon(
                                      //               Icons.broken_image,
                                      //               size: 60,
                                      //               color: Colors.grey,
                                      //             );
                                      //           },
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
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
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text("Name in Arabic",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        images.name,
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                      Clipboard.setData(ClipboardData(
                                                          text: images
                                                              .name)); // Text to be copied
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
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text("Card Number",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        images.cardNumber,
                                                        textAlign: TextAlign.left,
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                      Clipboard.setData(ClipboardData(
                                                          text: images
                                                              .cardNumber)); // Text to be copied
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
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text("Date of Birth in Hijri",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        images
                                                            .dateOfBirthInHijri,
                                                        textAlign: TextAlign.left,
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                      Clipboard.setData(ClipboardData(
                                                          text: images
                                                              .dateOfBirthInHijri)); // Text to be copied
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
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text("Expiry date in Hijri",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        images.expiryDateInHijri,
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                      Clipboard.setData(ClipboardData(
                                                          text: images
                                                              .expiryDateInHijri)); // Text to be copied
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
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text("Place of Birth",
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .normal,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        images.placeOfBirth,
                                                        maxLines: 4,
                                                        softWrap: true,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
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
                                                      Clipboard.setData(ClipboardData(
                                                          text: images
                                                              .placeOfBirth)); // Text to be copied
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
                                offset: Offset(
                                    0, 5), // Bottom shadow to enhance overlap effect
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
          ],
        ),
    );
  }
}
