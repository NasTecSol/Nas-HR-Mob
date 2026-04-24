import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
                        cachedObjectDetails = (snapshot.data?.data?.isNotEmpty ?? false)
                            ? snapshot.data!.data!.first.objectDetails
                            : null;

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
                                  SizedBox(width: 40, child: Text(AppLocalizations.of(context)!.expiryDate, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
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
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final pdf = pw.Document();
          final objDetails = cachedObjectDetails;
          final assetDetails = cachedAssetDetails;

          // Load Arabic font
          final arabicFont = await rootBundle.load("images/fonts/Tajawal-Regular.ttf");
          final ttf = pw.Font.ttf(arabicFont);

          // Load header and footer images
          pw.ImageProvider? headerImage;
          pw.ImageProvider? footerImage;

          try {
            if (singletonClass.headerUrl.isNotEmpty) {
              final headerResponse = await http.get(Uri.parse(singletonClass.headerUrl));
              if (headerResponse.statusCode == 200) {
                headerImage = pw.MemoryImage(headerResponse.bodyBytes);
              }
            }
            if (singletonClass.footerUrl.isNotEmpty) {
              final footerResponse = await http.get(Uri.parse(singletonClass.footerUrl));
              if (footerResponse.statusCode == 200) {
                footerImage = pw.MemoryImage(footerResponse.bodyBytes);
              }
            }
          } catch (e) {
            if (kDebugMode) print('Error loading header/footer images: $e');
          }

          // Text style with Arabic support
          final textStyle = pw.TextStyle(font: ttf, fontSize: 14);
          final boldTextStyle = pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold);
          final headingStyle = pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold);
          final smallTextStyle = pw.TextStyle(font: ttf, fontSize: 12);
          final smallBoldTextStyle = pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold);
          final childTextStyle = pw.TextStyle(font: ttf, fontSize: 11);
          final childBoldTextStyle = pw.TextStyle(font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold);

          // Build content widgets
          final List<pw.Widget> contentWidgets = [];

          // Asset Name
          contentWidgets.add(
            pw.Row(
              children: [
                pw.Text('Asset Name: ', style: boldTextStyle),
                pw.Expanded(child: pw.Text(objDetails?.objectName ?? 'N/A', style: textStyle)),
              ],
            ),
          );
          contentWidgets.add(pw.SizedBox(height: 10));

          // Template Type
          if (assetDetails?.data?.first.templateType != null) {
            final tags = (assetDetails!.data!.first.templateType ?? '')
                .split('_')
                .where((word) => word.toLowerCase() != 'asset')
                .join(', ');
            contentWidgets.add(
              pw.Row(
                children: [
                  pw.Text('Type: ', style: boldTextStyle),
                  pw.Expanded(child: pw.Text(tags, style: textStyle)),
                ],
              ),
            );
            contentWidgets.add(pw.SizedBox(height: 10));
          }

          // Asset Image
          if (objDetails?.img != null && objDetails!.img!.isNotEmpty) {
            try {
              pw.ImageProvider? assetImage;
              if (objDetails.img!.startsWith('http')) {
                final imgResponse = await http.get(Uri.parse(objDetails.img!));
                if (imgResponse.statusCode == 200) {
                  assetImage = pw.MemoryImage(imgResponse.bodyBytes);
                }
              } else {
                assetImage = pw.MemoryImage(base64Decode(objDetails.img!));
              }

              if (assetImage != null) {
                contentWidgets.add(
                  pw.Container(
                    height: 200,
                    width: 200,
                    child: pw.Image(assetImage, fit: pw.BoxFit.contain),
                  ),
                );
                contentWidgets.add(pw.SizedBox(height: 20));
              }
            } catch (e) {
              if (kDebugMode) print('Error loading asset image: $e');
            }
          }

          // Parameters
          if (objDetails?.parameters != null && objDetails!.parameters!.isNotEmpty) {
            contentWidgets.add(
              pw.Text('Parameters', style: headingStyle),
            );
            contentWidgets.add(pw.SizedBox(height: 10));

            objDetails.parameters!.forEach((key, value) {
              contentWidgets.add(
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('$key: ', style: smallBoldTextStyle),
                    pw.Expanded(
                      child: pw.Text(value?.toString() ?? 'N/A', style: smallTextStyle),
                    ),
                  ],
                ),
              );
              contentWidgets.add(pw.SizedBox(height: 5));
            });
            contentWidgets.add(pw.SizedBox(height: 10));
          }

          // Child Objects
          if (objDetails?.childObjs != null && objDetails!.childObjs!.isNotEmpty) {
            contentWidgets.add(
              pw.Text('Child Objects', style: headingStyle),
            );
            contentWidgets.add(pw.SizedBox(height: 10));

            for (var child in objDetails.childObjs!) {
              contentWidgets.add(
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        child.objectName ?? 'N/A',
                        style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      if (child.parameters != null && child.parameters!.isNotEmpty)
                        ...child.parameters!.entries.map((entry) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${entry.key}: ', style: childBoldTextStyle),
                              pw.Expanded(
                                child: pw.Text(entry.value?.toString() ?? 'N/A', style: childTextStyle),
                              ),
                            ],
                          ),
                        )),
                      if (child.additionalInfo != null && child.additionalInfo!.isNotEmpty)
                        ...child.additionalInfo!.entries.map((entry) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${entry.key}: ', style: childBoldTextStyle),
                              pw.Expanded(
                                child: pw.Text(entry.value?.toString() ?? 'N/A', style: childTextStyle),
                              ),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              );
              contentWidgets.add(pw.SizedBox(height: 10));
            }
          }

          // Add pages with header and footer on each page
          pdf.addPage(
            pw.MultiPage(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(20),
              theme: pw.ThemeData.withFont(
                base: ttf,
                bold: ttf,
              ),
              build: (pw.Context context) => contentWidgets,
              header: (pw.Context context) {
                return headerImage != null
                    ? pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Image(headerImage, fit: pw.BoxFit.fitWidth),
                )
                    : pw.SizedBox();
              },
              footer: (pw.Context context) {
                return footerImage != null
                    ? pw.Container(
                  margin: const pw.EdgeInsets.only(top: 10),
                  child: pw.Image(footerImage, fit: pw.BoxFit.fitWidth),
                )
                    : pw.SizedBox();
              },
            ),
          );

          return pdf.save();
        },
      );
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