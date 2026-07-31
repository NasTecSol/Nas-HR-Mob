import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/document_notification_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

import '../request_controller/employee_model.dart';
import '../widgets/loader.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    final local = AppLocalizations.of(context)!;
    final assetNameHeader =
        widget.assetsInfo?.assetName?.toString() ?? local.assets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          /// Curved Gradient Header (NO icon in title text)
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NasColors.darkBlue,
                  NasColors.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: NasColors.darkBlue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${local.assets} ${local.details}",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        assetNameHeader,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Glassmorphic Tab Controller Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildOptionTab(
                    index: 0,
                    title: local.assetsDetails,
                    icon: Icons.info_outline_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOptionTab(
                    index: 1,
                    title: local.documentNotification,
                    icon: Icons.notifications_none_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Tab Content Views
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (_selectedOptionIndex == 0) ...[
                    FutureBuilder<AssetDetailsModel?>(
                      future: getAssetsDetailsData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        } else if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        } else if (snapshot.hasData && snapshot.data != null) {
                          cachedAssetDetails = snapshot.data;
                          cachedObjectDetails =
                              (snapshot.data?.data?.isNotEmpty ?? false)
                                  ? snapshot.data!.data!.first.objectDetails
                                  : null;

                          if (cachedObjectDetails == null) {
                            return _buildEmptyState(local.noData);
                          }

                          final templateTypeStr =
                              cachedAssetDetails?.data?.first.templateType ??
                                  'N/A';
                          final tags = templateTypeStr
                              .split('_')
                              .where((word) => word.toLowerCase() != 'asset')
                              .toList();

                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Top Title Row & Print Action Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cachedObjectDetails!.objectName ??
                                            'N/A',
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _printPdf,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: NasColors.darkBlue
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.print_rounded,
                                          color: NasColors.darkBlue,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// Category Chip Tags
                                if (tags.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: NasColors.darkBlue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          tag.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                /// Asset Image Card (Tap to View)
                                if (cachedObjectDetails!.img != null &&
                                    cachedObjectDetails!.img!.isNotEmpty) ...[
                                  GestureDetector(
                                    onTap: () => _showImageZoomDialog(
                                        cachedObjectDetails!.img!),
                                    child: Center(
                                      child: Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: _buildAssetImageWidget(
                                            cachedObjectDetails!.img!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                /// Parameters Key-Value Section
                                if (cachedObjectDetails!.parameters != null &&
                                    cachedObjectDetails!
                                        .parameters!.isNotEmpty) ...[
                                  Text(
                                    local.details,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...cachedObjectDetails!.parameters!.entries
                                      .map((entry) => _buildDetailItemRow(
                                          entry.key,
                                          entry.value?.toString() ?? '---')),
                                  const SizedBox(height: 14),
                                ],

                                /// Child Objects Section
                                if (cachedObjectDetails!.childObjs != null &&
                                    cachedObjectDetails!
                                        .childObjs!.isNotEmpty) ...[
                                  const Divider(),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Child Objects",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...cachedObjectDetails!.childObjs!
                                      .map((child) {
                                    return Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            child.objectName ?? '---',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          if (child.parameters != null)
                                            ...child.parameters!.entries.map(
                                              (e) => _buildDetailItemRow(
                                                  e.key,
                                                  e.value?.toString() ?? '---'),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          );
                        } else {
                          return _buildEmptyState(local.noData);
                        }
                      },
                    )
                  ],

                  /// Document Notifications Tab
                  if (_selectedOptionIndex == 1) ...[
                    FutureBuilder<DocumentNotificationModel?>(
                      future: getDocumentNotificationData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        } else if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final documentNotificationDetails = snapshot.data!;
                          final assetIds = singletonClass.assetsDetailsModel
                              .expand(
                                  (assetDetail) => assetDetail.data ?? [])
                              .map((e) => e.id.toString())
                              .toSet();

                          final matchingData = documentNotificationDetails.data
                                  ?.where((e) =>
                                      e.objectType == "asset" &&
                                      e.objectId != null &&
                                      assetIds
                                          .contains(e.objectId.toString()))
                                  .toList() ??
                              [];

                          if (matchingData.isEmpty) {
                            return _buildEmptyState(local.noData);
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matchingData.length,
                            itemBuilder: (context, index) {
                              final item = matchingData[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                      color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  children: [
                                    _buildNotificationRow(
                                        local.type, item.objectType ?? '-'),
                                    const Divider(height: 16),
                                    _buildNotificationRow(
                                        local.name,
                                        item.attachmentName ?? '-'),
                                    const Divider(height: 16),
                                    _buildNotificationRow(
                                        local.expiryDate,
                                        item.expiryDate ?? '-'),
                                    const Divider(height: 16),
                                    _buildNotificationRow(
                                      local.status,
                                      item.status ?? '-',
                                      isStatus: true,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return _buildEmptyState(local.noData);
                        }
                      },
                    )
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Option Tab Widget
  Widget _buildOptionTab(
      {required int index, required String title, required IconData icon}) {
    final isSelected = _selectedOptionIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOptionIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? NasColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? NasColors.darkBlue.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isSelected ? NasColors.darkBlue : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : NasColors.darkBlue,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : NasColors.darkBlue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Key-Value Detail Row Item
  Widget _buildDetailItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: NasColors.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Notification Table Row
  Widget _buildNotificationRow(String label, String value,
      {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: value.toLowerCase() == 'active'
                  ? Colors.green.shade50
                  : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value.toLowerCase() == 'active'
                    ? Colors.green.shade300
                    : Colors.amber.shade300,
              ),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value.toLowerCase() == 'active'
                    ? Colors.green.shade700
                    : Colors.amber.shade800,
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: NasColors.darkBlue,
            ),
          ),
      ],
    );
  }

  /// Image Widget with network & base64 support and error fallbacks
  Widget _buildAssetImageWidget(String imageStr, {required BoxFit fit}) {
    try {
      if (imageStr.startsWith('http')) {
        return Image.network(
          imageStr,
          fit: fit,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: Colors.grey,
          ),
        );
      } else {
        return Image.memory(
          base64Decode(imageStr),
          fit: fit,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.broken_image_rounded,
            size: 40,
            color: Colors.grey,
          ),
        );
      }
    } catch (_) {
      return const Icon(
        Icons.image_not_supported_rounded,
        size: 40,
        color: Colors.grey,
      );
    }
  }

  /// Tap to Zoom Modal Dialog for Asset Image
  void _showImageZoomDialog(String imageStr) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildAssetImageWidget(imageStr, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: Lottie.asset('images/empty.json'),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NasColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMsg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        "Error: $errorMsg",
        style: GoogleFonts.inter(color: Colors.red.shade700),
      ),
    );
  }

  Future<AssetDetailsModel?> getAssetsDetailsData() async {
    try {
      int? assetId = widget.assetsInfo?.assetId;
      if (assetId == null) return null;
      var client = http.Client();
      var uri = Uri.parse(
          '${singletonClass.baseURL}/assets/getAssetsByIds?ids=$assetId');
      var response =
          await client.get(uri, headers: singletonClass.getHeaders());
      log("ASSETS DETAILS RESPONSE: ${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var assetData = AssetDetailsModel.fromJson(responseBody);
        singletonClass.assetsDetailsModel.add(assetData);
        return assetData;
      }
    } catch (e) {
      log("Error fetching asset details: $e");
    }
    return null;
  }

  Future<DocumentNotificationModel?> getDocumentNotificationData() async {
    try {
      var client = http.Client();
      var uri = Uri.parse('${singletonClass.baseURL}/doc-notifications');
      var response =
          await client.get(uri, headers: singletonClass.getHeaders());
      log("Document Notification detail response: ${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var documentNotificationData =
            DocumentNotificationModel.fromJson(responseBody);
        singletonClass.documentNotificationDataList
            .add(documentNotificationData);
        return documentNotificationData;
      }
    } catch (e) {
      log("Error fetching document notifications: $e");
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

          // Load Arabic font safely
          pw.Font? ttf;
          try {
            final arabicFont =
                await rootBundle.load("images/fonts/Tajawal-Regular.ttf");
            ttf = pw.Font.ttf(arabicFont);
          } catch (_) {}

          // Load header and footer images safely
          pw.ImageProvider? headerImage;
          pw.ImageProvider? footerImage;

          try {
            if (singletonClass.headerUrl.isNotEmpty) {
              final headerResponse =
                  await http.get(Uri.parse(singletonClass.headerUrl));
              if (headerResponse.statusCode == 200) {
                headerImage = pw.MemoryImage(headerResponse.bodyBytes);
              }
            }
            if (singletonClass.footerUrl.isNotEmpty) {
              final footerResponse =
                  await http.get(Uri.parse(singletonClass.footerUrl));
              if (footerResponse.statusCode == 200) {
                footerImage = pw.MemoryImage(footerResponse.bodyBytes);
              }
            }
          } catch (e) {
            if (kDebugMode) print('Error loading header/footer images: $e');
          }

          // Text styles
          final textStyle =
              pw.TextStyle(font: ttf, fontSize: 14);
          final boldTextStyle = pw.TextStyle(
              font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold);
          final headingStyle = pw.TextStyle(
              font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold);
          final smallTextStyle =
              pw.TextStyle(font: ttf, fontSize: 12);
          final smallBoldTextStyle = pw.TextStyle(
              font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold);
          final childTextStyle =
              pw.TextStyle(font: ttf, fontSize: 11);
          final childBoldTextStyle = pw.TextStyle(
              font: ttf, fontSize: 11, fontWeight: pw.FontWeight.bold);

          final List<pw.Widget> contentWidgets = [];

          // Asset Name
          contentWidgets.add(
            pw.Row(
              children: [
                pw.Text('Asset Name: ', style: boldTextStyle),
                pw.Expanded(
                    child:
                        pw.Text(objDetails?.objectName ?? 'N/A', style: textStyle)),
              ],
            ),
          );
          contentWidgets.add(pw.SizedBox(height: 10));

          // Template Type
          if (assetDetails?.data?.isNotEmpty == true &&
              assetDetails?.data?.first.templateType != null) {
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
          if (objDetails?.parameters != null &&
              objDetails!.parameters!.isNotEmpty) {
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
                      child: pw.Text(value?.toString() ?? 'N/A',
                          style: smallTextStyle),
                    ),
                  ],
                ),
              );
              contentWidgets.add(pw.SizedBox(height: 5));
            });
            contentWidgets.add(pw.SizedBox(height: 10));
          }

          // Child Objects
          if (objDetails?.childObjs != null &&
              objDetails!.childObjs!.isNotEmpty) {
            contentWidgets.add(
              pw.Text('Child Objects', style: headingStyle),
            );
            contentWidgets.add(pw.SizedBox(height: 10));

            for (var child in objDetails.childObjs!) {
              contentWidgets.add(
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius:
                        pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        child.objectName ?? 'N/A',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      if (child.parameters != null &&
                          child.parameters!.isNotEmpty)
                        ...child.parameters!.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('${entry.key}: ',
                                      style: childBoldTextStyle),
                                  pw.Expanded(
                                    child: pw.Text(
                                        entry.value?.toString() ?? 'N/A',
                                        style: childTextStyle),
                                  ),
                                ],
                              ),
                            )),
                      if (child.additionalInfo != null &&
                          child.additionalInfo!.isNotEmpty)
                        ...child.additionalInfo!.entries.map((entry) =>
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 4),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('${entry.key}: ',
                                      style: childBoldTextStyle),
                                  pw.Expanded(
                                    child: pw.Text(
                                        entry.value?.toString() ?? 'N/A',
                                        style: childTextStyle),
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

          // Build PDF document
          pdf.addPage(
            pw.MultiPage(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(20),
              theme: ttf != null
                  ? pw.ThemeData.withFont(
                      base: ttf,
                      bold: ttf,
                    )
                  : null,
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