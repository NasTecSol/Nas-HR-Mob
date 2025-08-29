import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:translator/translator.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  SingletonClass singletonClass = SingletonClass();
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    singletonClass.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
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
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Text(
                    AppLocalizations.of(context)!.notifications,
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
            Expanded(
              child: FutureBuilder(
                future: singletonClass.getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset('images/loader.json'),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return singletonClass
                            .notificationModelList.first.data!.isEmpty
                        ? Center(
                        child: Center(
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
                        )
                    )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: singletonClass
                                .notificationModelList.first.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final notificationData = singletonClass.notificationModelList.first.data!.reversed.toList()[index];
                              final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                              Future<List<String>> getTranslatedText() async {
                                if (!isArabic) {
                                  return [
                                    notificationData.notificationType ?? '',
                                    notificationData.message ?? '',
                                    notificationData.metaData ?? '',
                                  ];
                                } else {
                                  final titleTranslation = await translator.translate(notificationData.notificationType ?? '', to: 'ar');
                                  final messageTranslation = await translator.translate(notificationData.message ?? '', to: 'ar');
                                  final metaDataTranslation = await translator.translate(notificationData.metaData ?? '', to: 'ar');
                                  return [
                                    titleTranslation.text,
                                    messageTranslation.text,
                                    metaDataTranslation.text,
                                  ];
                                }
                              }

                              return FutureBuilder<List<String>>(
                                future: getTranslatedText(),
                                builder: (context, snapshot) {
                                  final translatedTitle = snapshot.hasData ? snapshot.data![0] : notificationData.notificationType ?? '';
                                  final translatedMessage = snapshot.hasData ? snapshot.data![1] : notificationData.message ?? '';
                                  final translateMetaMessage = snapshot.hasData ? snapshot.data![2] : notificationData.metaData ?? '';

                                  return Dismissible(
                                    key: Key(notificationData.id.toString()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      setState(() {
                                        singletonClass.notificationModelList.first.data!.removeAt(index);
                                        if (kDebugMode) {
                                          print(notificationData.id);
                                        }
                                        deleteNotification(notificationData.id!);
                                      });
                                    },
                                    background: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                          onTap: () {
                                            final type = notificationData.notificationType!.toLowerCase();
                                            if (type.contains('leave')){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MainScreen(index: 2)),
                                              );
                                            } else if (type.contains('employee') && type.contains('late')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => TeamAttendanceScreen()),
                                              );
                                            } else if (type.contains('meeting')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MainScreen(index: 3)),
                                              );
                                            } else if (type.contains('complain')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => Complaints()),
                                              );
                                            } else if (type.contains('penalty') || type.contains('fine')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => PenaltyAndFineScreen()),
                                              );
                                            } else if (type.contains('request')) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MainScreen(index: 2)),
                                              );
                                            }
                                          },
                                          child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(15)),
                                            color: Color(0xffF4F7FA),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 2,
                                                offset: const Offset(3, 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            translatedTitle,
                                                            style:
                                                                GoogleFonts.inter(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          if (singletonClass.employeeDataList.first.data!.email!.first.workEmail  == notificationData.from!.first.email)...[
                                                            Text(
                                                              translatedMessage,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.grey,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 4,
                                                            ),
                                                          ]else...[
                                                            Text(
                                                              translateMetaMessage,
                                                              style:
                                                              GoogleFonts.inter(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.grey,
                                                              ),
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                              maxLines: 4,
                                                            ),
                                                          ],
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                formatRelativeTime(
                                                                    "${notificationData.createdAt}"),
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: Image.asset(_getNotificationImage("${notificationData.notificationType}"))
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                  } else {
                    return Center(
                        child: Center(
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
                        )
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  ///Delete Api call
  Future<bool> deleteNotification(String notificationId) async {
    try {
      var client = http.Client();
      var uri = Uri.parse('${singletonClass.baseURL}/notification-data/$notificationId');
      var response = await client.delete(uri, headers: singletonClass.getHeaders());
      if (kDebugMode) {
        print(response.body);
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      return false;
    }
  }


  String formatRelativeTime(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    DateTime currentDate = DateTime.now();

    Duration difference = currentDate.difference(createdDate);

    if (difference.inMinutes < 1) {
      return  AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}${AppLocalizations.of(context)!.m} ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}${AppLocalizations.of(context)!.h} ${AppLocalizations.of(context)!.ago}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${AppLocalizations.of(context)!.d} ${AppLocalizations.of(context)!.ago}';
    } else {
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        return DateFormat('dd-MM-yyyy','ar').format(createdDate);
      } else {
        return DateFormat('dd-MM-yyyy').format(createdDate);
      }
    }
  }

  String _getNotificationImage(String eventType) {
    final type = eventType.toLowerCase();
    if (type.contains('success') || type.contains('create')) {
      return 'images/sent.png';
    }
    if (type.contains('reject')) {
      return 'images/reject.png';
    }
    if (type.contains('special leave') ||
        type.contains('marriage') ||
        type.contains('exam') ||
        type.contains('maternity')) {
      return 'images/leaveRequest.png';
    }
    if (type.contains('sick leave') || type.contains('leave request')) {
      return 'images/Medicine.png';
    }
    if (type.contains('employee late') ||
        type.contains('early check') ||
        type.contains('attendance')) {
      return 'images/clocking.png';
    }
    if (type.contains('meeting') ||
        type.contains('standup') ||
        type.contains('celebration')) {
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
