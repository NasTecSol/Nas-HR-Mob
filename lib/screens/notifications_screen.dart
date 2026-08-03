import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

import '../widgets/loader.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  SingletonClass singletonClass = SingletonClass();

  @override
  void initState() {
    super.initState();
    _fetchNotificationsData();
  }

  Future<void> _fetchNotificationsData() async {
    try {
      await singletonClass.getNotifications();
    } catch (e) {
      if (kDebugMode) print("Error loading notifications: $e");
    }
  }

  /// Safe helper to extract current employee work email
  String _getCurrentUserEmail() {
    try {
      final empList = singletonClass.employeeDataList;
      if (empList.isEmpty) return '';
      final empData = empList.first.data;
      if (empData.isEmpty) return '';
      final emails = empData.first.email;
      if (emails == null || emails.isEmpty) return '';
      return emails.first.workEmail?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Safe helper to extract notification sender email
  String _getNotificationFromEmail(dynamic notificationData) {
    try {
      final fromList = notificationData.from;
      if (fromList == null || fromList.isEmpty) return '';
      return fromList.first.email?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  IconData _getIconForNotificationType(String? eventType) {
    final type = (eventType ?? '').toLowerCase();
    if (type.contains('success') || type.contains('create')) {
      return Icons.check_circle_outline_rounded;
    }
    if (type.contains('reject')) {
      return Icons.cancel_outlined;
    }
    if (type.contains('leave') || type.contains('maternity')) {
      return Icons.event_available_rounded;
    }
    if (type.contains('sick') || type.contains('medicine')) {
      return Icons.medical_services_rounded;
    }
    if (type.contains('late') || type.contains('attendance')) {
      return Icons.access_time_filled_rounded;
    }
    if (type.contains('meeting') || type.contains('calendar')) {
      return Icons.calendar_month_rounded;
    }
    if (type.contains('loan')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (type.contains('complain')) {
      return Icons.report_problem_rounded;
    }
    if (type.contains('penalty') || type.contains('fine')) {
      return Icons.gavel_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final currentUserEmail = _getCurrentUserEmail();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          /// Curved Gradient Header (NO icon in title text)
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NasColors.darkBlue,
                  NasColors.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: NasColors.darkBlue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.notifications,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Expanded Notification List
          Expanded(
            child: FutureBuilder(
              future: singletonClass.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                } else if (snapshot.hasError) {
                  return Center(
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      child: Lottie.asset('images/error.json'),
                    ),
                  );
                } else {
                  List<dynamic> notificationsList = [];
                  try {
                    if (singletonClass.notificationModelList.isNotEmpty &&
                        singletonClass.notificationModelList.first.data !=
                            null) {
                      notificationsList =
                          singletonClass.notificationModelList.first.data!;
                    }
                  } catch (_) {}

                  if (notificationsList.isEmpty) {
                    return _buildEmptyState(local.noData);
                  }

                  final reversedList = notificationsList.reversed.toList();

                  return RefreshIndicator(
                    onRefresh: _fetchNotificationsData,
                    color: NasColors.darkBlue,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: reversedList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final notificationData = reversedList[index];
                        final notifId =
                            notificationData.id?.toString() ?? "notif_$index";

                        final title = notificationData.notificationType
                                ?.toString() ??
                            local.notifications;
                        final message =
                            notificationData.message?.toString() ?? '';
                        final metaMessage =
                            notificationData.metaData?.toString() ?? '';

                        final fromEmail =
                            _getNotificationFromEmail(notificationData);
                        final displayBody =
                            (currentUserEmail.isNotEmpty &&
                                    currentUserEmail == fromEmail)
                                ? message
                                : (metaMessage.isNotEmpty
                                    ? metaMessage
                                    : message);

                        final relativeTime = formatRelativeTime(
                            notificationData.createdAt?.toString());

                        return Dismissible(
                          key: Key(notifId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            try {
                              if (singletonClass
                                      .notificationModelList.isNotEmpty &&
                                  singletonClass.notificationModelList.first
                                          .data !=
                                      null) {
                                singletonClass
                                    .notificationModelList.first.data!
                                    .removeWhere((e) =>
                                        e.id?.toString() ==
                                        notificationData.id?.toString());
                              }
                            } catch (_) {}

                            if (notificationData.id != null) {
                              deleteNotification(
                                  notificationData.id.toString());
                            }
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.red.shade600,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.delete_outline_rounded,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  _handleNotificationTap(title);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Left Category Icon Badge
                                      Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          color: NasColors.darkBlue
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          _getIconForNotificationType(title),
                                          color: NasColors.darkBlue,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      /// Middle Text Information
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                            if (displayBody.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                displayBody,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: Colors.grey.shade700,
                                                  height: 1.3,
                                                ),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                            if (relativeTime.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_rounded,
                                                    size: 13,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    relativeTime,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  /// Navigation route handler based on notification title type
  void _handleNotificationTap(String titleRaw) {
    try {
      final type = titleRaw.toLowerCase();
      if (type.contains('leave')) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MainScreen(
                    index: 2, selectedIndex: 0, showBanner: false)));
      } else if (type.contains('employee') && type.contains('late')) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TeamAttendanceScreen()));
      } else if (type.contains('meeting')) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MainScreen(
                    index: 3, selectedIndex: 0, showBanner: false)));
      } else if (type.contains('complain')) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Complaints()));
      } else if (type.contains('penalty') || type.contains('fine')) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PenaltyAndFineScreen()));
      } else if (type.contains('request')) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const MainScreen(
                    index: 2, selectedIndex: 0, showBanner: false)));
      }
    } catch (e) {
      if (kDebugMode) print("Navigation error: $e");
    }
  }

  /// Delete API Call
  Future<bool> deleteNotification(String notificationId) async {
    try {
      if (notificationId.isEmpty) return false;
      var client = http.Client();
      var uri = Uri.parse(
          '${singletonClass.baseURL}/notification-data/$notificationId');
      var response =
          await client.delete(uri, headers: singletonClass.getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      return false;
    }
  }

  /// Relative Time Formatting
  String formatRelativeTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty || createdAt == 'null') {
      return '';
    }
    try {
      DateTime? createdDate = DateTime.tryParse(createdAt);
      if (createdDate == null) return '';
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
    } catch (e) {
      return '';
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset('images/empty.json'),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NasColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
