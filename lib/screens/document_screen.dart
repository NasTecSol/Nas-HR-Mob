import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/create_hr_letter_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:url_launcher/url_launcher.dart';
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [ Column(
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
                        if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                        IconButton(
                          onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateHrLetterScreen()));
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
                  documentInfo!.isNotEmpty
                      ? ListView.builder(
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
                                  SnackBar(content: Text('Could not open the document!')),
                                );
                              }
                            } else {
                              // Handle other file types if needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unsupported file type!')),
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
              )


            ],
          ),
      ]
      ),
    );
  }
}
