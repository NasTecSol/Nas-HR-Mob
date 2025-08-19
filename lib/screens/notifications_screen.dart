import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
                                    notificationData.message ?? ''
                                  ];
                                } else {
                                  final titleTranslation =
                                      await translator.translate(notificationData.notificationType ?? '',
                                          to: 'ar');
                                  final messageTranslation = await translator.translate(notificationData.message ?? '',
                                          to: 'ar');
                                  return [
                                    titleTranslation.text,
                                    messageTranslation.text
                                  ];
                                }
                              }

                              return FutureBuilder<List<String>>(
                                future: getTranslatedText(),
                                builder: (context, snapshot) {
                                  final translatedTitle = snapshot.hasData
                                      ? snapshot.data![0]
                                      : notificationData.notificationType ?? '';
                                  final translatedMessage = snapshot.hasData
                                      ? snapshot.data![1]
                                      : notificationData.notificationMessage ?? '';

                                  return Dismissible(
                                    key: Key(notificationData.id.toString()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      setState(() {
                                        singletonClass.notificationModelList.first.data!.removeAt(index);
                                        print(notificationData.id);
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
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          color: Colors.white,
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
                                                  Text(
                                                    "${singletonClass.getJWTModel()!.userName}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const Spacer(),
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
                                                        Text(
                                                          translatedMessage,
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
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 80,
                                                    width: 80,
                                                    child: Image.asset(
                                                        _getNotificationImage(
                                                            "${notificationData.notificationType}")),
                                                  ),
                                                ],
                                              ),
                                            ],
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
      print(response.body);
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
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // For dates older than a week, show the full date
      return DateFormat('dd-MM-yyyy').format(createdDate);
    }
  }

  String _getNotificationImage(String eventType) {
    switch (eventType) {
      case 'Leave Request':
        return 'images/Medicine.png';
      case 'Loan Request':
        return 'images/loan.png';
      case 'Penalty and Fine Requests':
        return 'images/leaveRequest.png';
      case 'Complaint Request':
        return 'images/Team.png';
      default:
        return 'images/time.png'; // Default image for company or other types
    }
  }
}
