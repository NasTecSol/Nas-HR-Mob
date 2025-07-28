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
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';


class AssetsDetailsScreen extends StatefulWidget {
  final AssetsInfo? assetsInfo;

  const AssetsDetailsScreen({super.key, this.assetsInfo});

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  final GlobalKey _captureKey = GlobalKey();
  
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
                    future: getAssetsDetailsData(),
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

                        if (objectDetails == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Lottie.asset('images/empty.json'),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RepaintBoundary(
                            key: _captureKey,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
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
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        Text(
                                          objectDetails.objectName ?? 'N/A',
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                       IconButton(
                                          onPressed: () => _captureAndShare(),
                                          icon: const Icon(Icons.print , color:  Colors.black, size: 30,),
                                        ),
                                      ],
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
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                                width: MediaQuery.of(context).size.width * 0.8,
                                                height: MediaQuery.of(context).size.height * 0.3,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: objectDetails.img != null &&
                                                    objectDetails.img!.isNotEmpty
                                                    ? (objectDetails.img!.startsWith('http')
                                                    ? Image.network(
                                                  objectDetails.img!,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                                )
                                                    : Image.memory(
                                                  base64Decode(objectDetails.img!),
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                                ))
                                                    : const Icon(Icons.image_not_supported,
                                                    size: 50, color: Colors.grey),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: objectDetails.img != null && objectDetails.img!.isNotEmpty
                                          ? (objectDetails.img!.startsWith('http')
                                          ? Image.network(
                                        objectDetails.img!,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                      )
                                          : Image.memory(
                                        base64Decode(objectDetails.img!),
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                      ))
                                          : const Icon(Icons.image_not_supported,
                                          size: 50, color: Colors.grey),
                                    ),

                                    const SizedBox(height: 10),

                                    /// Parameters
                                    if (objectDetails.parameters != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: objectDetails.parameters!.entries.map((entry) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Text(
                                              '${entry.key}: ${entry.value}',
                                              style: GoogleFonts.inter(fontSize: 16),
                                            ),
                                          );
                                        }).toList(),
                                      ),

                                    /// Child Objects
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
                        final assetIds = singletonClass.assetsDetailsModel
                            .expand((assetDetail) => assetDetail.data ?? [])
                            .map((e) => e.id.toString())
                            .toSet(); // Unique asset IDs

                        final matchingData = documentNotificationDetails.data
                            ?.where((e) =>
                        e.objectType == "asset" &&
                            e.objectId != null &&
                            assetIds.contains(e.objectId.toString()))
                            .toList() ?? [];

                        if (matchingData.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Lottie.asset('images/empty.json'),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
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
                                  SizedBox(
                                    width:40,
                                    child: Text(AppLocalizations.of(context)!.expiryDate,
                                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  ),
                                  Text(AppLocalizations.of(context)!.status,
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
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Lottie.asset('images/empty.json'),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.noData,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
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

  Future<void> _captureAndShare() async {
    try {
      // Wait until after the current frame has been rendered
      await Future.delayed(Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint("Capture boundary is null");
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint("ByteData is null");
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/asset_capture.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Captured Asset Screenshot');
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
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

