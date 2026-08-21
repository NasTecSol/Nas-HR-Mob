import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../request_controller/socket_model.dart';

class SocketNotificationScreen extends StatefulWidget {
  const SocketNotificationScreen({super.key});

  @override
  State<SocketNotificationScreen> createState() =>
      _SocketNotificationScreenState();
}

class _SocketNotificationScreenState extends State<SocketNotificationScreen> {
  SingletonClass singletonClass = SingletonClass();

  @override
  void initState() {
    super.initState();
    loadSocketDataFromPrefs();
  }

  Future<void> loadSocketDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = singletonClass.getJWTModel()?.employeeId ?? "unknown";
      final String? storedJson = prefs.getString("socket_data_$empId");
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(storedJson);
        final List<SocketModel> restoredList =
            decodedList.map((e) => SocketModel.fromJson(e)).toList();
        if (mounted) {
          setState(() {
            singletonClass.socketDataList
              ..clear()
              ..addAll(restoredList);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading socket notifications: $e");
    }
  }

  IconData _getIconForModule(String? moduleStr) {
    final module = (moduleStr ?? '').toLowerCase();
    if (module.contains('attendance') || module.contains('clock')) {
      return Icons.access_time_filled_rounded;
    }
    if (module.contains('complain')) {
      return Icons.report_problem_rounded;
    }
    if (module.contains('penalty') || module.contains('fine')) {
      return Icons.gavel_rounded;
    }
    if (module.contains('request')) {
      return Icons.assignment_turned_in_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                        local.clockingNotification,
                        style: GoogleFonts.inter(
                          fontSize: 20,
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

          /// Expanded Socket Notification List
          Expanded(
            child: () {
              final filteredList = singletonClass.socketDataList
                  .where((socketData) => socketData.module != "chat")
                  .toList()
                  .reversed
                  .toList();

              if (filteredList.isEmpty) {
                return _buildEmptyState(local.noData);
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredList.length,
                itemBuilder: (BuildContext context, int index) {
                  final socketData = filteredList[index];
                  final notifKey = socketData.timestamp.toString();

                  final message = isArabic
                      ? (socketData.messageAr.isNotEmpty ? socketData.messageAr : socketData.messageEn)
                      : (socketData.messageEn.isNotEmpty ? socketData.messageEn : socketData.messageAr);

                  final moduleTitle = socketData.module == 'attendance'
                      ? local.clockingNotification
                      : socketData.module == "request"
                          ? local.requestNotification
                          : (socketData.module.isNotEmpty ? socketData.module : local.notifications);

                  final relativeTime =
                      formatRelativeTime(socketData.timestamp);

                  return Dismissible(
                    key: Key(notifKey),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        singletonClass.socketDataList.removeWhere(
                          (item) => item.timestamp == socketData.timestamp,
                        );
                      });
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
                            _handleSocketNotificationTap(socketData.module);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Left Category Icon Badge
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: NasColors.darkBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _getIconForModule(socketData.module),
                                    color: NasColors.darkBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                /// Middle Text Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        moduleTitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                      if (message.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          message,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey.shade700,
                                            height: 1.3,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
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
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade500,
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
              );
            }(),
          )
        ],
      ),
    );
  }

  void _handleSocketNotificationTap(String? moduleStr) {
    try {
      final module = (moduleStr ?? '').toLowerCase();
      if (module.contains('attendance')) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TeamAttendanceScreen()),
        );
      } else if (module.contains('complain')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Complaints()),
        );
      } else if (module.contains('penalty') || module.contains('fine')) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PenaltyAndFineScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MainScreen(
                  index: 2, selectedIndex: 0, showBanner: false)),
        );
      }
    } catch (e) {
      debugPrint("Navigation error: $e");
    }
  }

  /// Relative Time Formatting with safe parsing
  String formatRelativeTime(DateTime? createdDate) {
    if (createdDate == null) return '';
    try {
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
