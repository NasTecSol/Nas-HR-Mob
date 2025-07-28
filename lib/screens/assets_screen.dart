import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart' show Lottie;
import 'package:nashr/screens/assets_details_screen.dart';
import 'package:nashr/screens/company_assets_details_screen.dart';
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
  int _selectedOptionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final assetsInfo = (singletonClass.employeeDataList.isNotEmpty &&
        singletonClass.employeeDataList.first.data?.assetsInfo != null)
        ? singletonClass.employeeDataList.first.data!.assetsInfo
        : [];

    final companyAssetsInfo = (singletonClass.companyDataList.isNotEmpty &&
        singletonClass.companyDataList.first.data?.assets != null)
        ? singletonClass.companyDataList.first.data!.assets
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
              if(singletonClass.getJWTModel()?.grade == "L3" || singletonClass.getJWTModel()?.grade == "L4")...[
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
                                offset: const Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Set the main axis size
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.15, // Responsive height
                                width: MediaQuery.of(context).size.width * 0.25, // Responsive width
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                  color: NasColors.darkBlue,
                                  image: DecorationImage(
                                    image: AssetImage(
                                      _getImageForEventType(assets.assetType), // Use a method to get the appropriate image
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
                                            "${assets.assetName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Handle overflow
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
                                          "${assets.assetId}",
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
                                      "${AppLocalizations.of(context)!.id}# ${assets.assetId}",
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
               if(singletonClass.getJWTModel()?.grade == "L0" || singletonClass.getJWTModel()?.grade == "L1" || singletonClass.getJWTModel()?.grade == "L2")...[
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       buildOptionsCard(0, AppLocalizations.of(context)!.companyNotifications),
                       buildOptionsCard(1, AppLocalizations.of(context)!.assignedAssets),
                     ],
                   ),
                 ),
                 if (_selectedOptionIndex == 0)...[
                   companyAssetsInfo!.isNotEmpty
                       ? ListView.builder(
                     padding: const EdgeInsets.all(5),
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: companyAssetsInfo.length,
                     itemBuilder: (BuildContext context, int index) {
                       final companyAssets = companyAssetsInfo[index];
                       return Directionality(
                         textDirection: TextDirection.ltr,
                         child: GestureDetector(
                           onTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => CompanyAssetsDetailsScreen(
                                   assetsInfo: companyAssets,
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
                                   offset: const Offset(0, 0), // changes position of shadow
                                 ),
                               ],
                             ),
                             child: Padding(
                                   padding: const EdgeInsets.all(15.0),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         children: [
                                           Container(
                                             constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5), // Set max width
                                             child: Text(
                                               "${AppLocalizations.of(context)!.id} : ${companyAssets.randomId}",
                                               style: GoogleFonts.inter(
                                                 fontSize: 15,
                                                 fontWeight: FontWeight.bold,
                                                 color: Colors.black,
                                               ),
                                               overflow: TextOverflow.ellipsis, // Handle overflow
                                             ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 12),
                                       Row(
                                         children: [
                                           Text(
                                             "${AppLocalizations.of(context)!.assignedTo}: ${companyAssets.currentAssignedEmpName}",
                                             style: GoogleFonts.inter(
                                               fontSize: 12,
                                               fontWeight: FontWeight.w500,
                                               color: NasColors.darkBlue,
                                             ),
                                           ),
                                           Spacer(),
                                           Container(
                                             height: MediaQuery.of(context).size.height * 0.04, // Responsive height
                                             width: MediaQuery.of(context).size.width * 0.19, // Responsive width
                                             decoration: BoxDecoration(
                                               shape: BoxShape.rectangle,
                                               color: NasColors.onTime,
                                               borderRadius: BorderRadius.circular(8),
                                             ),
                                             child: Center(
                                               child: Text(
                                                 _translateStatus(companyAssets.status , context),
                                                 textAlign: TextAlign.center,
                                                 style: GoogleFonts.inter(
                                                   fontWeight: FontWeight.bold,
                                                   color: Colors.white,
                                                   fontSize: 12,
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                       const SizedBox(height: 12),
                                       Text(
                                         "${AppLocalizations.of(context)!.assignedAt}: ${companyAssets.currentAssignedDate}",
                                         style: GoogleFonts.inter(
                                           fontSize: 12,
                                           fontWeight: FontWeight.bold,
                                           color: NasColors.darkBlue,
                                         ),
                                       ),
                                     ],
                                   ),
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
                 if (_selectedOptionIndex == 1)...[
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
                                   offset: const Offset(0, 0), // changes position of shadow
                                 ),
                               ],
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min, // Set the main axis size
                               children: [
                                 Container(
                                   height: MediaQuery.of(context).size.height * 0.15, // Responsive height
                                   width: MediaQuery.of(context).size.width * 0.25, // Responsive width
                                   decoration: BoxDecoration(
                                     borderRadius: const BorderRadius.only(
                                       topLeft: Radius.circular(15),
                                       bottomLeft: Radius.circular(15),
                                     ),
                                     color: NasColors.darkBlue,
                                     image: DecorationImage(
                                       image: AssetImage(
                                         _getImageForEventType(assets.assetType), // Use a method to get the appropriate image
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
                                               "${assets.assetName}",
                                               style: GoogleFonts.inter(
                                                 fontSize: 15,
                                                 fontWeight: FontWeight.bold,
                                                 color: Colors.black,
                                               ),
                                               overflow: TextOverflow.ellipsis, // Handle overflow
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
                                             "${assets.assetId}",
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
                                         "${AppLocalizations.of(context)!.id}# ${assets.assetId}",
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
                 ]
               ],
            ],
          ),
        ),
      ]),
    );
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null) return localizations.noData;

    switch (status) {
      case 'assigned':
        return localizations.assigned;
      case 'deactive':
        return localizations.deactive;
      case 'unassigned':
        return localizations.unAssigned;
      default:
        return status;
    }
  }

  String _getImageForEventType(String? eventType) {
    switch (eventType) {
      case 'laptop':
        return 'images/Laptop.png';
      case 'car':
        return 'images/Car.png';
      default:
        return 'images/Vector.png'; // Default image for company or other types
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
        height: 75,
        width: 160,
        child: Card(
          color:
          _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
}
