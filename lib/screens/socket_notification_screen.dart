import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

import '../request_controller/socket_model.dart';
import 'complaints.dart';
import 'main_screen.dart';

class SocketNotificationScreen extends StatefulWidget {
  const SocketNotificationScreen({super.key});

  @override
  State<SocketNotificationScreen> createState() =>
      _SocketNotificationScreenState();
}

class _SocketNotificationScreenState extends State<SocketNotificationScreen> {
  SingletonClass singletonClass = SingletonClass();
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadSocketDataFromPrefs();
  }

  Future<void> loadSocketDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final empId = singletonClass.getJWTModel()?.employeeId ?? "unknown";
    final String? storedJson = prefs.getString("socket_data_$empId");
    if (storedJson != null) {
      final List<dynamic> decodedList = jsonDecode(storedJson);
      final List<SocketModel> restoredList =
      decodedList.map((e) => SocketModel.fromJson(e)).toList();
      setState(() {
        singletonClass.socketDataList
          ..clear()
          ..addAll(restoredList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
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
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.clockingNotification,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Expanded(
              child: () {
                // Filter out chat-only notifications
                final filteredList = singletonClass.socketDataList
                    .where((socketData) => socketData.module != "chat")
                    .toList()
                    .reversed
                    .toList();

                if (filteredList.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final socketData = filteredList[index];

                    final message = isArabic
                        ? socketData.messageAr
                        : socketData.messageEn;

                    return Dismissible(
                      key: Key(socketData.timestamp.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          singletonClass.socketDataList.removeWhere(
                                (item) => item.timestamp == socketData.timestamp,
                          );
                        });
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          color: const Color(0xffF4F7FA),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              _getNotificationImage(socketData.module),
                            ),
                          ),
                          title: Text(
                            socketData.module == 'attendance'
                                ? AppLocalizations.of(context)!.clockingNotification
                                : socketData.module == "request"
                                ? AppLocalizations.of(context)!.requestNotification
                                : socketData.module,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatRelativeTime(socketData.timestamp.toIso8601String()),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            final module = socketData.module.toLowerCase();
                            if (module.contains('attendance')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const TeamAttendanceScreen()),
                              );
                            } else if (module.contains('complain')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Complaints()),
                              );
                            } else if (module.contains('penalty') ||
                                module.contains('fine')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const PenaltyAndFineScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(index: 2 , selectedIndex: 0 , showBanner: false)),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              }(),
            )
          ],
        ),
      ),
    );
  }

  /// Format relative time
  String formatRelativeTime(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    DateTime currentDate = DateTime.now();

    Duration difference = currentDate.difference(createdDate);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${AppLocalizations.of(context)!.m} ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${AppLocalizations.of(context)!.h} ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${AppLocalizations.of(context)!.d} ${AppLocalizations.of(context)!.ago}';
    } else {
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        return DateFormat('dd-MM-yyyy', 'ar').format(createdDate);
      } else {
        return DateFormat('dd-MM-yyyy').format(createdDate);
      }
    }
  }

  /// Pick image depending on module
  String _getNotificationImage(String eventType) {
    final type = eventType.toLowerCase();
    if (type.contains('success') || type.contains('create')) {
      return 'images/sent.png';
    }
    if (type.contains('reject')) {
      return 'images/reject.png';
    }
    if (type.contains('leave')) {
      return 'images/leaveRequest.png';
    }
    if (type.contains('sick')) {
      return 'images/Medicine.png';
    }
    if (type.contains('attendance')) {
      return 'images/clocking.png';
    }
    if (type.contains('meeting')) {
      return 'images/calendarScreen.png';
    }
    if (type.contains('loan')) {
      return 'images/loanRequest.png';
    }
    if (type.contains('complain')) {
      return 'images/Complain.png';
    }
    if (type.contains('penalty') || type.contains('fine')) {
      return 'images/Penalties.png';
    }
    return 'images/time.png';
  }
}
