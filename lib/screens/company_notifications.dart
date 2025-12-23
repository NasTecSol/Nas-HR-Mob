import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'company_assets_details_screen.dart';

class CompanyNotifications extends StatefulWidget {
  const CompanyNotifications({super.key});

  @override
  State<CompanyNotifications> createState() => _CompanyNotificationsState();
}

class _CompanyNotificationsState extends State<CompanyNotifications> {
  SingletonClass singletonClass = SingletonClass();
  @override
  Widget build(BuildContext context) {
    final companyAssetsInfo = (singletonClass.companyDataList.isNotEmpty &&
        singletonClass.companyDataList.first.data?.assets != null)
        ? singletonClass.companyDataList.first.data!.assets
        : [];
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
        child: Column(
          children: [
            ///header
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
                  AppLocalizations.of(context)!.companyNotifications,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
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
                            offset: const Offset(0, 0),
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.assignedTo}: ${companyAssets.currentAssignedEmpName ?? "---"}",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.04,
                                  width: MediaQuery.of(context).size.width * 0.19,
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
                              "${AppLocalizations.of(context)!.assignedAt}: ${companyAssets.currentAssignedDate ?? "---"}",
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
        ),
      ),
    );
  }

  ///helper methods
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
}
