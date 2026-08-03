import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/company_notification_assets_detail_screen.dart';
import 'package:nashr/screens/create_company_notifications.dart';
import 'package:nashr/screens/edit_company_notification_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

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

    final activeCount = singletonClass
        .companyNotificationDataList.first.data!
        .where((e) =>
            e.companyId == singletonClass.selectedCompanyId &&
            e.status == "active")
        .length;

    final nearExpiryCount = singletonClass
        .companyNotificationDataList.first.data!
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

    final expiredCount = singletonClass
        .companyNotificationDataList.first.data!
        .where((e) =>
            e.companyId == singletonClass.selectedCompanyId &&
            e.status == "expired")
        .length;

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              /// Curved Header (NO icon in header text)
              _buildHeader(context),

              Expanded(
                child: RefreshIndicator(
                  color: NasColors.darkBlue,
                  backgroundColor: Colors.white,
                  onRefresh: fetchLatestCompanyNotifications,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Filter Tabs ("All", "Company", "Employee", "Assets")
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                buildOptionsCard(0, AppLocalizations.of(context)!.all),
                                buildOptionsCard(1, AppLocalizations.of(context)!.company),
                                buildOptionsCard(2, AppLocalizations.of(context)!.employee),
                                buildOptionsCard(3, AppLocalizations.of(context)!.assets),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          /// Status Summary Row (Active, Near Expiry, Expired)
                          if (_selectedOptionIndex == 0) ...[
                            _buildStatusSummaryRow(
                              activeCount: activeCount,
                              nearExpiryCount: nearExpiryCount,
                              expiredCount: expiredCount,
                            ),
                            const SizedBox(height: 12),
                          ],

                          /// Content List based on selected tab
                          if (_selectedOptionIndex == 0) _buildAllTabContent(),
                          if (_selectedOptionIndex == 1) _buildCompanyTabContent(),
                          if (_selectedOptionIndex == 2) _buildEmployeeTabContent(),
                          if (_selectedOptionIndex == 3) _buildAssetsTabContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  // ── Header (Gradient with Back & Add buttons, NO decorative logo icon) ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.documentNotification,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCompanyNotifications(),
                ),
              );
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.18),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Tab Pills ──────────────────────────────────────────────────
  Widget buildOptionsCard(int index, String title) {
    final data = singletonClass.companyNotificationDataList.first.data!;
    final count = index == 0
        ? data
            .where((e) => e.companyId == singletonClass.selectedCompanyId)
            .length
        : index == 1
            ? data
                .where((e) =>
                    e.companyId == singletonClass.selectedCompanyId &&
                    e.objectType == "company")
                .length
            : index == 2
                ? data
                    .where((e) =>
                        e.companyId == singletonClass.selectedCompanyId &&
                        e.objectType == "employee")
                    .length
                : data
                    .where((e) =>
                        e.companyId == singletonClass.selectedCompanyId &&
                        e.objectType == "asset")
                    .length;

    final isSelected = _selectedOptionIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? NasColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? NasColors.darkBlue : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NasColors.darkBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : NasColors.darkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$count",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? NasColors.darkBlue : NasColors.darkBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Summary Row ────────────────────────────────────────────────
  Widget _buildStatusSummaryRow({
    required int activeCount,
    required int nearExpiryCount,
    required int expiredCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusPill(
            count: activeCount,
            label: AppLocalizations.of(context)!.active,
            color: NasColors.completed,
            icon: Icons.check_circle_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusPill(
            count: nearExpiryCount,
            label: AppLocalizations.of(context)!.nearToExpire,
            color: Colors.orange,
            icon: Icons.error_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusPill(
            count: expiredCount,
            label: AppLocalizations.of(context)!.expired,
            color: NasColors.red,
            icon: Icons.cancel_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              "$count $label",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification Card Item Widget ──────────────────────────────────────
  Widget _buildNotificationCardItem({
    required dynamic notification,
    required dynamic employee,
    required String date,
    required int index,
    VoidCallback? onTap,
  }) {
    IconData typeIcon;
    Color typeColor = NasColors.darkBlue;

    if (notification.objectType == "company") {
      typeIcon = Icons.domain_rounded;
    } else if (notification.objectType == "employee") {
      typeIcon = Icons.person_rounded;
    } else {
      typeIcon = Icons.devices_rounded;
    }

    Widget cardChild = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notification.attachmentName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(notification.status ?? ''),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${notification.status}",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (notification.objectType == "employee" && employee != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_rounded, size: 14, color: NasColors.darkBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${employee.firstName ?? ''} ${employee.middleName ?? ''} ${employee.lastName ?? ''}".trim(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    employee.employeeInfo != null && employee.employeeInfo!.isNotEmpty
                        ? (employee.employeeInfo!.first.empId ?? '--')
                        : '--',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: NasColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                "${AppLocalizations.of(context)!.expiryDate}: $date",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade700, size: 22),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCompanyNotificationScreen(
                          companyNotifications: notification,
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    deleteNotification(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16, color: NasColors.darkBlue),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.edit,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.delete,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
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

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardChild);
    }
    return cardChild;
  }

  // ── Tab 0: ALL Notifications ──────────────────────────────────────────
  Widget _buildAllTabContent() {
    return FutureBuilder(
      future: companyNotificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Loader());
        }
        final notifications =
            singletonClass.companyNotificationDataList.first.data ?? [];

        final filteredNotifications = notifications
            .where((n) => n.companyId == singletonClass.selectedCompanyId)
            .toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filteredNotifications.length,
          itemBuilder: (ctx, i) {
            final notification = filteredNotifications[i];
            final employeesList = singletonClass
                    .teamBranchDataList.first.data?.employees ??
                [];
            final employee = employeesList.any((e) => e.id == notification.objectId)
                ? employeesList.firstWhere((e) => e.id == notification.objectId)
                : null;

            String date = '--';
            try {
              final parsed = (DateTime.tryParse(notification.expiryDate ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0));
              final locale = Localizations.localeOf(context).languageCode;
              date = DateFormat('dd-MM-yyyy', locale == 'ar' ? 'ar' : null)
                  .format(parsed);
            } catch (_) {}

            return _buildNotificationCardItem(
              notification: notification,
              employee: employee,
              date: date,
              index: i,
            );
          },
        );
      },
    );
  }

  // ── Tab 1: COMPANY Notifications ──────────────────────────────────────
  Widget _buildCompanyTabContent() {
    return FutureBuilder(
      future: companyNotificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Loader());
        }
        final notifications =
            singletonClass.companyNotificationDataList.first.data ?? [];

        final filteredNotifications = notifications.where((n) {
          return n.companyId == singletonClass.selectedCompanyId &&
              n.objectType == 'company';
        }).toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filteredNotifications.length,
          itemBuilder: (ctx, i) {
            final notification = filteredNotifications[i];
            String date = '--';
            try {
              final parsed = (DateTime.tryParse(notification.expiryDate ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0));
              final locale = Localizations.localeOf(context).languageCode;
              date = DateFormat('dd-MM-yyyy', locale == 'ar' ? 'ar' : null)
                  .format(parsed);
            } catch (_) {}

            return _buildNotificationCardItem(
              notification: notification,
              employee: null,
              date: date,
              index: i,
            );
          },
        );
      },
    );
  }

  // ── Tab 2: EMPLOYEE Notifications ─────────────────────────────────────
  Widget _buildEmployeeTabContent() {
    return FutureBuilder(
      future: companyNotificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Loader());
        }
        final notifications =
            singletonClass.companyNotificationDataList.first.data ?? [];
        final employees =
            singletonClass.teamBranchDataList.first.data?.employees ?? [];

        final filteredNotifications = notifications.where((n) {
          final employeeExists = employees.any((e) => e.id == n.objectId);
          return n.companyId == singletonClass.selectedCompanyId &&
              employeeExists &&
              n.objectType == 'employee';
        }).toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filteredNotifications.length,
          itemBuilder: (ctx, i) {
            final notification = filteredNotifications[i];
            final employee = employees.any((e) => e.id == notification.objectId)
                ? employees.firstWhere((e) => e.id == notification.objectId)
                : null;

            String date = '--';
            try {
              final parsed = (DateTime.tryParse(notification.expiryDate ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0));
              final locale = Localizations.localeOf(context).languageCode;
              date = DateFormat('dd-MM-yyyy', locale == 'ar' ? 'ar' : null)
                  .format(parsed);
            } catch (_) {}

            return _buildNotificationCardItem(
              notification: notification,
              employee: employee,
              date: date,
              index: i,
            );
          },
        );
      },
    );
  }

  // ── Tab 3: ASSETS Notifications ───────────────────────────────────────
  Widget _buildAssetsTabContent() {
    return FutureBuilder(
      future: companyNotificationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Loader());
        }
        final notifications =
            singletonClass.companyNotificationDataList.first.data ?? [];

        final filteredNotifications = notifications.where((n) {
          return n.companyId == singletonClass.selectedCompanyId &&
              n.objectType == 'asset';
        }).toList();

        if (filteredNotifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filteredNotifications.length,
          itemBuilder: (ctx, i) {
            final notification = filteredNotifications[i];
            String date = '--';
            try {
              final parsed = (DateTime.tryParse(notification.expiryDate ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0));
              final locale = Localizations.localeOf(context).languageCode;
              date = DateFormat('dd-MM-yyyy', locale == 'ar' ? 'ar' : null)
                  .format(parsed);
            } catch (_) {}

            return _buildNotificationCardItem(
              notification: notification,
              employee: null,
              date: date,
              index: i,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyNotificationAssetsDetailScreen(
                      assetsInfo: notification,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset('images/empty.json'),
            ),
            Text(
              AppLocalizations.of(context)!.noData,
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

  /// API CALL
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
