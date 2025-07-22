import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/document_notification_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class AssetsDetailsScreen extends StatefulWidget {
  final AssetsInfo? assetsInfo;

  const AssetsDetailsScreen({super.key, this.assetsInfo});

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;

  @override
  void initState() {
    super.initState();
    getAssetsDetailsData();
    getDocumentNotificationData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        padding: EdgeInsets.zero,
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
                      '${AppLocalizations.of(context)!.assets} ${AppLocalizations.of(context)!.details}',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildOptionsCard(0, AppLocalizations.of(context)!.assetsDetails),
                      buildOptionsCard(1, AppLocalizations.of(context)!.documentNotification),
                    ],
                  ),
                ),
                if(_selectedOptionIndex == 0)...[
                  FutureBuilder<AssetDetailsModel?>(
                    future: getAssetsDetailsData(), // Your API call
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/loader.json'),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        var assetDetails = snapshot.data!;
                        var objectDetails = assetDetails.data?.first.objectDetails;

                        return objectDetails == null
                            ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noData,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              color: NasColors.containerColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    objectDetails.objectName ?? 'N/A',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 4.0,
                                    children: (assetDetails.data?.first.templateType ?? 'N/A')
                                        .split('_')
                                        .where((word) => word.toLowerCase() != 'asset')
                                        .map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: NasColors.darkBlue,
                                      labelStyle: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Container(
                                              width:
                                              MediaQuery.of(context).size.width * 0.8,
                                              height:
                                              MediaQuery.of(context).size.height * 0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: objectDetails.img != null &&
                                                  objectDetails.img!.isNotEmpty
                                                  ? (objectDetails.img!
                                                  .startsWith('http')
                                                  ? Image.network(
                                                objectDetails.img!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.error),
                                              )
                                                  : Image.memory(
                                                base64Decode(
                                                    objectDetails.img!),
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.error),
                                              ))
                                                  : Image.network(
                                                'https://via.placeholder.com/150',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: objectDetails.img != null &&
                                        objectDetails.img!.isNotEmpty
                                        ? (objectDetails.img!.startsWith('http')
                                        ? Image.network(
                                      objectDetails.img!,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                    )
                                        : Image.memory(
                                      base64Decode(objectDetails.img!),
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                    ))
                                        : Image.network(
                                      'https://via.placeholder.com/150',
                                      height: 150,
                                      width: 150,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (objectDetails.parameters != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:
                                      objectDetails.parameters!.entries.map((entry) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text(
                                            '${entry.key}: ${entry.value}',
                                            style: GoogleFonts.inter(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  if (objectDetails.childObjs != null)
                                    ...objectDetails.childObjs!.map((child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(child.objectName ?? ''),
                                          if (child.parameters != null)
                                            ...child.parameters!.entries.map((entry) {
                                              return Text('${entry.key}: ${entry.value}');
                                            }).toList(),
                                          if (child.additionalInfo != null)
                                            ...child.additionalInfo!.entries.map((entry) {
                                              return Text('${entry.key}: ${entry.value}');
                                            }).toList(),
                                        ],
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noData,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }
                    },
                  )
                ],
                if (_selectedOptionIndex == 1)...[
                  FutureBuilder<DocumentNotificationModel?>(
                    future: getDocumentNotificationData(), // Your API call
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/loader.json'),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final documentNotificationDetails = snapshot.data!;
                        final assetId = singletonClass.assetsDetailsModel.isNotEmpty &&
                            singletonClass.assetsDetailsModel.first.data != null &&
                            singletonClass.assetsDetailsModel.first.data!.isNotEmpty
                            ? singletonClass.assetsDetailsModel.first.data!.first.id
                            : null;
                        print("🔍 assetId: $assetId");
                        print("📦 documentNotificationDetails.data: ${documentNotificationDetails.data}");

                        if (assetId == null) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }
                        final matchingData = documentNotificationDetails.data
                            ?.where((e) => e.objectId?.toString() == assetId.toString())
                            .toList() ??
                            [];

                        print("✅ matchingData: $matchingData");

                        if (matchingData.isEmpty) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }

                        final item = matchingData.first;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!.type,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(AppLocalizations.of(context)!.name,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(AppLocalizations.of(context)!.expiryDate,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(AppLocalizations.of(context)!.status,
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("Action",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.objectType ?? '-',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.attachmentName ?? '-',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.expiryDate ?? '-',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.status ?? '-',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("View",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noData,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }
                    },
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 80,
        width: index == 1 ? 160 : 140,
        child: Card(
          color:
          _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
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



  Future<AssetDetailsModel?> getAssetsDetailsData() async {
    int? assetId = widget.assetsInfo?.assetId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/assets/getAssetsByIds?ids=$assetId');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log("ASSETS DETAILS RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var assetData = AssetDetailsModel.fromJson(responseBody);
      singletonClass.assetsDetailsModel.add(assetData);
      return assetData;
    }
    return null;
  }


  Future<DocumentNotificationModel?> getDocumentNotificationData() async {
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/doc-notifications');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log("Document Notification detail response: ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var documentNotificationData = DocumentNotificationModel.fromJson(responseBody);
      singletonClass.documentNotificationDataList.add(documentNotificationData);
      return documentNotificationData;
    }
    return null;
  }
}

