import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/document_notification_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../request_controller/employee_model.dart';
import '../widgets/loader.dart';

class AssetsDetailsScreen extends StatefulWidget {
  final AssetsInfo? assetsInfo;

  const AssetsDetailsScreen({super.key, this.assetsInfo});

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  AssetDetailsModel? cachedAssetDetails;
  ObjectDetails? cachedObjectDetails;

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
                      onPressed: () => Navigator.pop(context),
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
                        child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.assets} ${AppLocalizations.of(context)!.details}',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: NasColors.darkBlue),
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
                if (_selectedOptionIndex == 0) ...[
                  FutureBuilder<AssetDetailsModel?>(
                    future: getAssetsDetailsData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        cachedAssetDetails = snapshot.data!;
                        cachedObjectDetails = cachedAssetDetails!.data?.first.objectDetails;

                        if (cachedObjectDetails == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 200, width: 200, child: Lottie.asset('images/empty.json')),
                                  Text(AppLocalizations.of(context)!.noData, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: NasColors.darkBlue)),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: NasColors.containerColor,
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 0)),
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
                                      Text(cachedObjectDetails!.objectName ?? 'N/A', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                                      IconButton(onPressed: _printPdf, icon: const Icon(Icons.print, color: Colors.black, size: 30)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 4.0,
                                    children: (cachedAssetDetails!.data?.first.templateType ?? 'N/A')
                                        .split('_')
                                        .where((word) => word.toLowerCase() != 'asset')
                                        .map((tag) => Chip(label: Text(tag), backgroundColor: NasColors.darkBlue, labelStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          height: MediaQuery.of(context).size.height * 0.3,
                                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12.0)),
                                          child: cachedObjectDetails!.img != null && cachedObjectDetails!.img!.isNotEmpty
                                              ? (cachedObjectDetails!.img!.startsWith('http')
                                              ? Image.network(cachedObjectDetails!.img!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))
                                              : Image.memory(base64Decode(cachedObjectDetails!.img!), fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error)))
                                              : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    child: cachedObjectDetails!.img != null && cachedObjectDetails!.img!.isNotEmpty
                                        ? (cachedObjectDetails!.img!.startsWith('http')
                                        ? Image.network(cachedObjectDetails!.img!, height: 150, width: 150, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))
                                        : Image.memory(base64Decode(cachedObjectDetails!.img!), height: 150, width: 150, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error)))
                                        : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 10),
                                  if (cachedObjectDetails!.parameters != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: cachedObjectDetails!.parameters!.entries.map((entry) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text('${entry.key}: ${entry.value}', style: GoogleFonts.inter(fontSize: 16)))).toList(),
                                    ),
                                  if (cachedObjectDetails!.childObjs != null)
                                    ...cachedObjectDetails!.childObjs!.map((child) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(child.objectName ?? ''),
                                        if (child.parameters != null) ...child.parameters!.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
                                        if (child.additionalInfo != null) ...child.additionalInfo!.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
                                      ],
                                    )),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(child: Text(AppLocalizations.of(context)!.noData, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15)));
                      }
                    },
                  )
                ],
                if (_selectedOptionIndex == 1) ...[
                  FutureBuilder<DocumentNotificationModel?>(
                    future: getDocumentNotificationData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final documentNotificationDetails = snapshot.data!;
                        final assetIds = singletonClass.assetsDetailsModel.expand((assetDetail) => assetDetail.data ?? []).map((e) => e.id.toString()).toSet();
                        final matchingData = documentNotificationDetails.data?.where((e) => e.objectType == "asset" && e.objectId != null && assetIds.contains(e.objectId.toString())).toList() ?? [];

                        if (matchingData.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 200, width: 200, child: Lottie.asset('images/empty.json')),
                                  Text(AppLocalizations.of(context)!.noData, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: NasColors.darkBlue)),
                                ],
                              ),
                            ),
                          );
                        }

                        final item = matchingData.first;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))]),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!.type, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(AppLocalizations.of(context)!.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  SizedBox(width: 40, child: Text(AppLocalizations.of(context)!.expiryDate, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey))),
                                  Text(AppLocalizations.of(context)!.status, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.objectType ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.attachmentName ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.expiryDate ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(item.status ?? '-', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                                SizedBox(height: 200, width: 200, child: Lottie.asset('images/empty.json')),
                                Text(AppLocalizations.of(context)!.noData, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: NasColors.darkBlue)),
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

  Widget buildOptionsCard(int index, String title) => GestureDetector(
    onTap: () => setState(() => _selectedOptionIndex = index),
    child: SizedBox(
      height: 80,
      width: index == 1 ? 160 : 140,
      child: Card(
        color: _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35), side: BorderSide(color: _selectedOptionIndex == index ? Colors.white : Colors.white, width: 0)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(title, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _selectedOptionIndex == index ? Colors.white : NasColors.darkBlue))]),
      ),
    ),
  );

  Future<AssetDetailsModel?> getAssetsDetailsData() async {
    int? assetId = widget.assetsInfo?.assetId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/assets/getAssetsByIds?ids=$assetId');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
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
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    log("Document Notification detail response: ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var documentNotificationData = DocumentNotificationModel.fromJson(responseBody);
      singletonClass.documentNotificationDataList.add(documentNotificationData);
      return documentNotificationData;
    }
    return null;
  }

  Future<void> _printPdf() async {
    if (!mounted) return;

    try {
      await Printing.layoutPdf(onLayout: (format) async {
        final objDetails = cachedObjectDetails;
        final assetDetails = cachedAssetDetails;

        final StringBuffer contentBuffer = StringBuffer();

        contentBuffer.write('<div style="margin-bottom: 10px;"><strong>Asset Name:</strong> <span>');
        contentBuffer.write(objDetails?.objectName ?? 'N/A');
        contentBuffer.write('</span></div>');

        if (assetDetails?.data?.first.templateType != null) {
          contentBuffer.write('<div style="margin-bottom: 10px;"><strong>Type:</strong> <span>');
          contentBuffer.write((assetDetails!.data!.first.templateType ?? '').split('_').where((word) => word.toLowerCase() != 'asset').join(', '));
          contentBuffer.write('</span></div>');
        }

        if (objDetails?.img != null && objDetails!.img!.isNotEmpty) {
          final String imgSrc = objDetails.img!.startsWith('http') ? objDetails.img! : 'data:image/png;base64,${objDetails.img!}';
          contentBuffer.write('<div style="margin: 20px 0;"><img src="');
          contentBuffer.write(imgSrc);
          contentBuffer.write('" alt="Asset Image" style="max-width: 300px; max-height: 300px; margin: 20px 0; border-radius: 8px;" /></div>');
        }

        if (objDetails?.parameters != null && objDetails!.parameters!.isNotEmpty) {
          contentBuffer.write('<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">Parameters</h3>');
          objDetails.parameters!.forEach((key, value) {
            contentBuffer.write('<div style="margin-bottom: 10px;"><strong>');
            contentBuffer.write(key);
            contentBuffer.write(':</strong> <span>');
            contentBuffer.write(value?.toString() ?? 'N/A');
            contentBuffer.write('</span></div>');
          });
          contentBuffer.write('</div>');
        }

        if (objDetails?.childObjs != null && objDetails!.childObjs!.isNotEmpty) {
          contentBuffer.write('<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">Child Objects</h3>');
          for (var child in objDetails.childObjs!) {
            contentBuffer.write('<div style="background-color: #f5f5f5; border-radius: 8px; padding: 15px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"><h4 style="margin: 0 0 10px 0; color: black;">');
            contentBuffer.write(child.objectName ?? 'N/A');
            contentBuffer.write('</h4>');

            if (child.parameters != null && child.parameters!.isNotEmpty) {
              child.parameters!.forEach((key, value) {
                contentBuffer.write('<div style="margin-bottom: 10px;"><strong>');
                contentBuffer.write(key);
                contentBuffer.write(':</strong> <span>');
                contentBuffer.write(value?.toString() ?? 'N/A');
                contentBuffer.write('</span></div>');
              });
            }

            if (child.additionalInfo != null && child.additionalInfo!.isNotEmpty) {
              child.additionalInfo!.forEach((key, value) {
                contentBuffer.write('<div style="margin-bottom: 10px;"><strong>');
                contentBuffer.write(key);
                contentBuffer.write(':</strong> <span>');
                contentBuffer.write(value?.toString() ?? 'N/A');
                contentBuffer.write('</span></div>');
              });
            }

            contentBuffer.write('</div>');
          }
          contentBuffer.write('</div>');
        }

        final String content = contentBuffer.toString();

        final StringBuffer htmlBuffer = StringBuffer();
        htmlBuffer.write('<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { font-family: Arial, sans-serif; margin: 0; padding: 0; } img { display: block; width: 100%; } .header-img, .footer-img { margin: 0; padding: 0; } .content { margin: 20px; padding: 20px; } strong { color: black; font-weight: bold; } span { color: black; } div { line-height: 1.6; } h3, h4 { color: black; font-weight: bold; margin: 20px 0 15px 0; }</style></head><body><img class="header-img" src="');
        htmlBuffer.write(singletonClass.headerUrl);
        htmlBuffer.write('" alt="Header Image"/><div class="content">');
        htmlBuffer.write(content);
        htmlBuffer.write('</div><img class="footer-img" src="');
        htmlBuffer.write(singletonClass.footerUrl);
        htmlBuffer.write('" alt="Footer Image"/></body></html>');

        final String html = htmlBuffer.toString();

        return await Printing.convertHtml(format: format, html: html);
      });
    } catch (e) {
      if (kDebugMode) print('Error printing PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}