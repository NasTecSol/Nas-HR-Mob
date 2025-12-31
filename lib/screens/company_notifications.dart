import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/create_company_notifications.dart';
import 'package:nashr/screens/edit_company_notification_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/loader.dart';

class CompanyNotifications extends StatefulWidget {
  const CompanyNotifications({super.key});

  @override
  State<CompanyNotifications> createState() => _CompanyNotificationsState();
}

class _CompanyNotificationsState extends State<CompanyNotifications> {
  SingletonClass singletonClass = SingletonClass();
  late Future companyNotificationFuture;
  int _selectedOptionIndex = 0;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
    singletonClass.getTeamBranchData(),
    companyNotificationFuture = singletonClass.getCompanyNotificationData(),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final activeCount = singletonClass.companyNotificationDataList.first.data!
        .where((e) =>
    e.companyId == singletonClass.selectedCompanyId &&
        e.status == "active")
        .length;

    final nearExpiryCount = singletonClass.companyNotificationDataList.first.data!
        .where((e) {
      if (e.companyId != singletonClass.selectedCompanyId ||
          e.expiryDate == null ||
          e.status == "expired") {
        return false;
      }

      final expiry = DateTime.tryParse(e.expiryDate!);
      if (expiry == null) return false;

      final diff = expiry.difference(now).inDays;
      return diff >= 0 && diff <= 10;
    }).length;

    final expiredCount = singletonClass.companyNotificationDataList.first.data!
        .where((e) =>
    e.companyId == singletonClass.selectedCompanyId &&
        e.status == "expired")
        .length;

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
        child: Stack(
          children: [
            RefreshIndicator(
              color: NasColors.darkBlue,
              backgroundColor: Colors.white,
              onRefresh: fetchLatestCompanyNotifications,
              child: Column(
              children: [
                /// HEADER
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
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.companyNotifications,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateCompanyNotifications()));
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
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildOptionsCard(0, AppLocalizations.of(context)!.all),
                      buildOptionsCard(1, AppLocalizations.of(context)!.company),
                      buildOptionsCard(2, AppLocalizations.of(context)!.employee),
                      buildOptionsCard(3, AppLocalizations.of(context)!.assets),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if(_selectedOptionIndex == 0)...[
                  /// CONTENT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: NasColors.completed,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "$activeCount ${AppLocalizations.of(context)!.active}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 30,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "$nearExpiryCount ${AppLocalizations.of(context)!.nearToExpire}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                          color: NasColors.red,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            "$expiredCount ${AppLocalizations.of(context)!.expired}",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder(
                      future: companyNotificationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }
                        if (!snapshot.hasData ||
                            singletonClass
                                .companyNotificationDataList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child:
                                    Lottie.asset('images/empty.json'),
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

                        return ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          itemCount: singletonClass.companyNotificationDataList.first.data!.length,
                          itemBuilder: (ctx, i) {
                            final notification = singletonClass.companyNotificationDataList.first.data![i];
                            final employee = singletonClass.teamBranchDataList
                                .first.data!.employees!
                                .where((e) => e.id == notification.objectId)
                                .isNotEmpty
                                ? singletonClass.teamBranchDataList.first.data!.employees!
                                .firstWhere((e) => e.id == notification.objectId)
                                : null;
                            String date = '--';
                            try {
                              final parsed =
                              DateTime.parse(notification.expiryDate!);
                              final locale = Localizations.localeOf(context).languageCode;
                              date = DateFormat(
                                  'dd-MM-yyyy', locale == 'ar' ? 'ar' : null).format(parsed);
                            } catch (_) {}
                            if(singletonClass.selectedCompanyId != notification.companyId){
                              return SizedBox.shrink();
                            }
                            return Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      (notification.objectType == "company")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/site.png'),
                                      )
                                          : (notification.objectType == "employee")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/person.png'),
                                      )
                                          : SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/pc.png'),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          notification.attachmentName ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: getStatusColor(notification.status!),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${notification.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (notification.objectType == "employee" &&
                                      employee != null &&
                                      employee.employeeInfo != null &&
                                      employee.employeeInfo!.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        Text(
                                          "${employee.firstName ?? ''} ${employee.lastName ?? ''}".trim(),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          employee.employeeInfo!.first.empId ?? '--',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.expiryDate}: $date",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(Icons.more_horiz, size: 25),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditCompanyNotificationScreen(companyNotifications: notification,)));
                                          } else if (value == 'delete') {
                                            deleteNotification(i);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.edit, size: 18),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.edit,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.delete, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.delete,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                if(_selectedOptionIndex == 1)...[
                  Expanded(
                    child: FutureBuilder(
                      future: companyNotificationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }
                        if (!snapshot.hasData ||
                            singletonClass
                                .companyNotificationDataList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child:
                                    Lottie.asset('images/empty.json'),
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

                        return ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          itemCount: singletonClass.companyNotificationDataList.first.data!.length,
                          itemBuilder: (ctx, i) {
                            final notification = singletonClass.companyNotificationDataList.first.data![i];

                            String date = '--';
                            try {
                              final parsed =
                              DateTime.parse(notification.expiryDate!);
                              final locale = Localizations.localeOf(context).languageCode;
                              date = DateFormat(
                                  'dd-MM-yyyy', locale == 'ar' ? 'ar' : null).format(parsed);
                            } catch (_) {}
                            if (singletonClass.selectedCompanyId != notification.companyId ||
                                notification.objectType != "company") {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      (notification.objectType == "company")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/site.png'),
                                      )
                                          : (notification.objectType == "employee")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/person.png'),
                                      )
                                          : SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/pc.png'),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          notification.attachmentName ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: getStatusColor(notification.status!),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${notification.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.expiryDate}: $date",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(Icons.more_horiz, size: 25),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditCompanyNotificationScreen(companyNotifications: notification,)));
                                          } else if (value == 'delete') {
                                            deleteNotification(i);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.edit, size: 18),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.edit,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.delete, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.delete,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                if(_selectedOptionIndex == 2)...[
                  Expanded(
                    child: FutureBuilder(
                      future: companyNotificationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }
                        if (!snapshot.hasData || singletonClass.companyNotificationDataList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child:
                                    Lottie.asset('images/empty.json'),
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

                        return ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          itemCount: singletonClass.companyNotificationDataList.first.data!.length,
                          itemBuilder: (ctx, i) {
                            final notification = singletonClass.companyNotificationDataList.first.data![i];
                            final employeeExists = singletonClass.teamBranchDataList.first.data!.employees!.any((e) => e.id == notification.objectId);
                            String date = '--';
                            final employee = singletonClass.teamBranchDataList
                                .first.data!.employees!
                                .where((e) => e.id == notification.objectId)
                                .isNotEmpty
                                ? singletonClass.teamBranchDataList.first.data!.employees!
                                .firstWhere((e) => e.id == notification.objectId)
                                : null;
                            try {
                              final parsed =
                              DateTime.parse(notification.expiryDate!);
                              final locale = Localizations.localeOf(context).languageCode;
                              date = DateFormat(
                                  'dd-MM-yyyy', locale == 'ar' ? 'ar' : null).format(parsed);
                            } catch (_) {}
                            if (singletonClass.selectedCompanyId != notification.companyId ||
                                notification.objectType != "employee" ||
                                !employeeExists) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      (notification.objectType == "company")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/site.png'),
                                      )
                                          : (notification.objectType == "employee")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/person.png'),
                                      )
                                          : SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/pc.png'),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          notification.attachmentName ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: getStatusColor(notification.status!),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${notification.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${employee!.firstName} ${employee.lastName}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "${employee.employeeInfo!.first.empId}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.expiryDate}: $date",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(Icons.more_horiz, size: 25),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditCompanyNotificationScreen(companyNotifications: notification,)));
                                          } else if (value == 'delete') {
                                            deleteNotification(i);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.edit, size: 18),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.edit,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.delete, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.delete,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                if(_selectedOptionIndex == 3)...[
                  Expanded(
                    child: FutureBuilder(
                      future: companyNotificationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
                        }
                        if (!snapshot.hasData ||
                            singletonClass
                                .companyNotificationDataList.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child:
                                    Lottie.asset('images/empty.json'),
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

                        return ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          itemCount: singletonClass.companyNotificationDataList.first.data!.length,
                          itemBuilder: (ctx, i) {
                            final notification = singletonClass.companyNotificationDataList.first.data![i];
                            String date = '--';
                            try {
                              final parsed =
                              DateTime.parse(notification.expiryDate!);
                              final locale = Localizations.localeOf(context).languageCode;
                              date = DateFormat(
                                  'dd-MM-yyyy', locale == 'ar' ? 'ar' : null).format(parsed);
                            } catch (_) {}
                            if (singletonClass.selectedCompanyId != notification.companyId ||
                                notification.objectType != "asset") {
                              // If this is the last item and nothing is shown yet, show "no data"
                              if (i == singletonClass.companyNotificationDataList.first.data!.length - 1) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: Lottie.asset('images/empty.json'),
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
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      (notification.objectType == "company")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/site.png'),
                                      )
                                          : (notification.objectType == "employee")
                                          ? SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/person.png'),
                                      )
                                          : SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset('images/pc.png'),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          notification.attachmentName ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 30,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: getStatusColor(notification.status!),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${notification.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.expiryDate}: $date",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(Icons.more_horiz, size: 25),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EditCompanyNotificationScreen( companyNotifications: notification,)));
                                          } else if (value == 'delete') {
                                            deleteNotification(i);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.edit, size: 18),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.edit,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children:  [
                                                Icon(Icons.delete, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.delete,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],

              ),
            ),
            if(isLoading)
              Loader()
          ]
        ),
      ),
    );
  }

  ///Helper Methods
  Widget buildOptionsCard(int index, String title) {
    final data = singletonClass.companyNotificationDataList.first.data!;
    final count = index == 0
        ? data.where((e) =>
    e.companyId == singletonClass.selectedCompanyId).length
        : index == 1
        ? data.where((e) =>
    e.companyId == singletonClass.selectedCompanyId &&
        e.objectType == "company").length
        : index == 2
        ? data.where((e) =>
    e.companyId == singletonClass.selectedCompanyId &&
        e.objectType == "employee").length
        : data.where((e) =>
    e.companyId == singletonClass.selectedCompanyId &&
        e.objectType == "asset").length;

    final isSelected = _selectedOptionIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 140,
        child: Card(
          color: _selectedOptionIndex == index
              ? NasColors.darkBlue
              : Colors.white,
          elevation: 0.0,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$count",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: NasColors.darkBlue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$count",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
              const SizedBox(width: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
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


  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'expired':
        return NasColors.red;
      case 'active':
        return NasColors.completed;

      default:
        return NasColors.orange;
    }
  }
  ///API CALL
  Future<void> deleteNotification(int index) async {
    final notification =
    singletonClass.companyNotificationDataList.first.data![index];

    final url =
    Uri.parse('${singletonClass.baseURL}/doc-notifications/${notification.id}');
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.delete(
        url,
        headers: singletonClass.getHeaders(),
      );
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          singletonClass.companyNotificationDataList.first.data!.removeAt(index);
        });
      } else {
        debugPrint('Delete failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> fetchLatestCompanyNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      await singletonClass.getCompanyNotificationData();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
