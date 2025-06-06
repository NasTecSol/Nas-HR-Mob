import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  SingletonClass singletonClass = SingletonClass();

  @override
  void initState(){
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
                    AppLocalizations.of(context)!.notifications,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                // Padding(
                //   padding: const EdgeInsets.only(top: 0.0),
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       backgroundColor: NasColors.darkBlue,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //     ),
                //     onPressed: () {
                //       // Add your onPressed functionality here
                //     },
                //     child: SizedBox(
                //       height: 30,
                //       width: 90,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           const Icon(
                //             Icons.filter_alt,
                //             color: Colors.white,
                //             size: 20,
                //           ),
                //           const SizedBox(width: 5),
                //           Text(
                //             AppLocalizations.of(context)!.filter,
                //             textAlign: TextAlign.center,
                //             style: GoogleFonts.inter(
                //               fontWeight: FontWeight.bold,
                //               color: Colors.white,
                //               fontSize: 15,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
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
                    return singletonClass.notificationModelList.first.data!.isEmpty
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
                      itemCount: singletonClass.notificationModelList.first.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final notificationData = singletonClass
                            .notificationModelList.first.data![index];
                        return Dismissible(
                          key: Key(notificationData.id.toString()), // Ensure each item has a unique key
                          direction: DismissDirection.endToStart, // Allows swipe from right to left
                          onDismissed: (direction) {
                            // Handle item removal
                            setState(() {
                              singletonClass.notificationModelList.first.data!.removeAt(index);
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
                            ),// Background color while swiping
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete_outline_rounded, color: Colors.white),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
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
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          formatRelativeTime("${notificationData.createdAt}"),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${notificationData.notificationType}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "${notificationData.message}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: Image.asset(_getNotificationImage("${notificationData.notificationType}")),
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
