import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import '../request_controller/employee_details_assets_model.dart';
import '../request_controller/employee_details_model.dart';
import '../singleton_class.dart';
import '../widgets/colors.dart';

class EmployeeDetailsScreenAssets extends StatefulWidget {
  final AssetsInfo? assetsInfo;

  const EmployeeDetailsScreenAssets({super.key, this.assetsInfo});

  @override
  State<EmployeeDetailsScreenAssets> createState() => _EmployeeDetailsScreenAssetsState();
}

class _EmployeeDetailsScreenAssetsState extends State<EmployeeDetailsScreenAssets> {
  SingletonClass singletonClass = SingletonClass();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                FutureBuilder<EmployeeDetailsAssetsModel?>(
                  future: getEmployeeAssetsDetailsData(), // Your API call
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'), // Adjust path as necessary
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
                          child:Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                              color: NasColors.containerColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            child:  Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    objectDetails.objectName ?? 'N/A',
                                    style:  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 4.0, // Space between tags
                                    children: (assetDetails.data?.first.templateType ?? 'N/A')
                                        .split('_')
                                        .where((word) => word.toLowerCase() != 'asset')
                                        .map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: NasColors.darkBlue, // Customize tag color
                                      labelStyle:  GoogleFonts.inter(
                                        color: Colors.white, // Customize text color
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
                                        final img = objectDetails.img ?? '';
                                        final bool isUrl = img.startsWith('http') || img.startsWith('https');

                                        final imageWidget = isUrl
                                            ? Image.network(
                                          img,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                                        )
                                            : Image.memory(
                                          base64Decode(img),
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                                        );

                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            height: MediaQuery.of(context).size.height * 0.3,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: imageWidget,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Builder(
                                    builder: (_) {
                                      final img = objectDetails.img ?? '';
                                      final bool isUrl = img.startsWith('http') || img.startsWith('https');

                                      if (img.isEmpty) {
                                        return Image.network(
                                          'https://via.placeholder.com/150',
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                        );
                                      }

                                      if (isUrl) {
                                        return Image.network(
                                          img,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                        );
                                      } else {
                                        return Image.memory(
                                          base64Decode(img),
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),

                                  // Displaying Parameters
                                  if (objectDetails.parameters != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: objectDetails.parameters!.entries.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text(
                                            '${entry.key}: ${entry.value}',
                                            style:  GoogleFonts.inter(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  if (objectDetails.childObjs != null)
                                    ...objectDetails.childObjs!.map((child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(child.objectName ?? '',
                                          ),
                                          if (child.parameters != null)
                                            ...child.parameters!.entries.map((entry) {
                                              return Text('${entry.key}: ${entry.value}');
                                            }),
                                          if (child.additionalInfo != null)
                                            ...child.additionalInfo!.entries.map((entry) {
                                              return Text('${entry.key}: ${entry.value}');
                                            }),
                                        ],
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ));
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
            ),
          )
        ],
      ),
    );
  }
  Future<EmployeeDetailsAssetsModel?> getEmployeeAssetsDetailsData() async {
    try {
      int? assetId = widget.assetsInfo?.assetId;
      var client = http.Client();
      var uri = Uri.parse('${singletonClass.baseURL}/assets/getAssetsByIds?ids=$assetId');
      var response = await client.get(uri,headers: singletonClass.getHeaders());

      log("EMPLOYEE ASSETS DETAILS RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var assetData = EmployeeDetailsAssetsModel.fromJson(responseBody);
        singletonClass.employeeDetailsAssetsModel.add(assetData);
        return assetData;
      } else {
        log("ERROR: Failed to fetch asset details. Status Code: ${response.statusCode}");
        log("Response Body: ${response.body}");
      }
    } catch (e, stackTrace) {
      log("Exception occurred while fetching employee asset details: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

}
