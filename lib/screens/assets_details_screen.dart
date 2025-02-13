import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class AssetsDetailsScreen extends StatefulWidget {
  final AssetsInfo? assetsInfo;

  const AssetsDetailsScreen({super.key, this.assetsInfo});

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen> {
  SingletonClass singletonClass = SingletonClass();

  @override
  void initState() {
    super.initState();
    getAssetsDetailsData();
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
                FutureBuilder<AssetDetailsModel?>(
                  future: getAssetsDetailsData(), // Your API call
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
                      var objectDetails = assetDetails.data?.objectDetails;

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
                                children: (assetDetails.data?.templateType ?? 'N/A')
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

                              // Image display logic
                              GestureDetector(
                                onTap: () {
                                  // Open a dialog or a new screen to display the large image
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent, // Transparent background
                                        child: Container(
                                          // Adjust the width and height to suit your design
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          height: MediaQuery.of(context).size.height * 0.3,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(12.0), // Optional: Rounded corners
                                          ),
                                          child: objectDetails.img != null && objectDetails.img!.isNotEmpty
                                              ? Image.memory(
                                            base64Decode(objectDetails.img!),
                                            fit: BoxFit.contain,
                                          )
                                              : Image.network(
                                            'https://via.placeholder.com/150',
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: objectDetails.img != null && objectDetails.img!.isNotEmpty
                                    ? Image.memory(
                                  base64Decode(objectDetails.img!), // Assuming img now holds the Base64 string directly
                                  height: 150,
                                  width: 150,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                )
                                    : Image.network(
                                  'https://via.placeholder.com/150',
                                  height: 150,
                                  width: 150,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
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
          ),
        ],
      ),
    );
  }


  Future<AssetDetailsModel?> getAssetsDetailsData() async {
    int? assetId = widget.assetsInfo?.assetId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/assets/getAssetById/$assetId');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var assetData = AssetDetailsModel.fromJson(responseBody);
      singletonClass.assetsDetailsModel.add(assetData);
      return assetData;
    }
    return null;
  }
}

