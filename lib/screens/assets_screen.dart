import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:nashr/screens/assets_details_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../widgets/colors.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  SingletonClass singletonClass = SingletonClass();

  @override
  Widget build(BuildContext context) {
    final assetsInfo = (singletonClass.employeeDataList.isNotEmpty &&
        singletonClass.employeeDataList.first.data?.assetsInfo != null)
        ? singletonClass.employeeDataList.first.data!.assetsInfo
        : [];



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
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: IconButton(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                    child: Text(
                      AppLocalizations.of(context)!.assets,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              if(singletonClass.getJWTModel()?.grade == "L0" || singletonClass.getJWTModel()?.grade == "L1" || singletonClass.getJWTModel()?.grade == "L2" || singletonClass.getJWTModel()?.grade == "L3" || singletonClass.getJWTModel()?.grade == "L4")...[
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.assignedAssets,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: NasColors.darkBlue,
                      ),
                    )
                  ],
                ),
                assetsInfo!.isNotEmpty
                    ? ListView.builder(
                  padding: const EdgeInsets.all(5),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assetsInfo.length,
                  itemBuilder: (BuildContext context, int index) {
                    final assets = assetsInfo[index];
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetsDetailsScreen(
                                assetsInfo: assets,
                              ),
                            ),
                          );
                        },
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.15,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                  color: NasColors.darkBlue,
                                  image: DecorationImage(
                                    image: AssetImage(
                                      _getImageForEventType(assets.assetType),
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5), // Set max width
                                          child: Text(
                                            "${assets.assetName ?? "---"}",
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${assets.assetId ?? "---"}",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "${AppLocalizations.of(context)!.id}# ${assets.assetId ?? "---"}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "${AppLocalizations.of(context)!.assignedAt}: ${assets.issueDateFrom}",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                  ],
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
                ),
              ],
            ],
          ),
        ),
      ]),
    );
  }



  String _getImageForEventType(String? eventType) {
    switch (eventType) {
      case 'laptop':
        return 'images/Laptop.png';
      case 'car':
        return 'images/Car.png';
      default:
        return 'images/Vector.png';
    }
  }
}
