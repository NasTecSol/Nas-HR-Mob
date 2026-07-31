import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/screens/employee_details_screen_assets.dart';
import 'package:nashr/screens/pdf_viewer_screen.dart';
import 'package:nashr/screens/register_biometric_device_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../request_controller/team_model.dart';
import '../widgets/loader.dart';

class BranchEmployeeProfileScreen extends StatefulWidget {
  final Employees? employees;
  final bool isTeamMate;

  const BranchEmployeeProfileScreen(
      {super.key, this.employees, required this.isTeamMate});

  @override
  State<BranchEmployeeProfileScreen> createState() => _BranchEmployeeProfileScreen();
}

class _BranchEmployeeProfileScreen extends State<BranchEmployeeProfileScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _selectedOptionIndex = 0;
  late Future<EmployeeDetailsData?> _employeeDetailsFuture;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _employeeDetailsFuture = getEmployeeDetailsData();
  }

  // ── Header Widget (Gradient Header Matching TeamScreen) ───────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
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
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  singletonClass.employeeDetailsAttendanceDataList.clear();
                  singletonClass.employeeDetailsDataList.clear();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                AppLocalizations.of(context)!.employeeProfile,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
                .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
            [])
        : [];

    /// Check for onboarding
    final hasOnboarding = uiSettings.any((e) {
      if (e.title == "Teams" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Onboarding & Offboarding") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: isLoading
                    ? const Center(child: Loader())
                    : FutureBuilder<EmployeeDetailsData?>(
                        future: _employeeDetailsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Loader());
                          }
                          if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!.errorFetchData,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
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
                          } else {
                            final employeeDetails = snapshot.data!.data;
                            return ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              children: [
                                // ── Employee Summary Card ─────────────────
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: NasColors.lightBlue.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: (employeeDetails != null &&
                                                    employeeDetails.isNotEmpty &&
                                                    (employeeDetails.first.profilePic?.isNotEmpty ?? false))
                                                ? Image.network(
                                                    employeeDetails.first.profilePic!,
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                    errorBuilder: (context, exception, stackTrace) {
                                                      return Image.asset(
                                                        'images/DP.png',
                                                        fit: BoxFit.cover,
                                                        width: 80,
                                                        height: 80,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    'images/DP.png',
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.employees!.userName ?? 'N/A',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                widget.employees?.employeeInfo?.first.designation ?? 'N/A',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  if (widget.employees?.employeeInfo?.first.grade != null) ...[
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: NasColors.darkBlue.withOpacity(0.08),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        widget.employees!.employeeInfo!.first.grade!,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: NasColors.darkBlue,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  if (widget.employees?.employeeInfo?.first.empId != null)
                                                    Text(
                                                      "ID: ${widget.employees!.employeeInfo!.first.empId}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey.shade500,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (hasOnboarding)
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RegisterBiometricDeviceScreen(
                                                    empId: widget.employees!.employeeInfo!.first.empId,
                                                    firstName: widget.employees!.firstName,
                                                    lastName: widget.employees!.lastName,
                                                    userName: widget.employees!.userName,
                                                    fromTeamScreen: true,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'images/fingerprint.png',
                                                  width: 24,
                                                  height: 24,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Options Tabs Row ──────────────────────
                                if (widget.isTeamMate == true) ...[
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        buildOptionsCard(0, AppLocalizations.of(context)!.profile),
                                        buildOptionsCard(1, AppLocalizations.of(context)!.leaveBalance),
                                        buildOptionsCard(2, AppLocalizations.of(context)!.attendance),
                                        buildOptionsCard(3, AppLocalizations.of(context)!.documents),
                                        buildOptionsCard(4, AppLocalizations.of(context)!.assets),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: _selectedOptionIndex == index ? 18.0 : 8.0,
                                        height: 8.0,
                                        decoration: BoxDecoration(
                                          color: _selectedOptionIndex == index
                                              ? NasColors.darkBlue
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // ── Tab 0: Profile / Personal Information ─
                                if (_selectedOptionIndex == 0) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Text(
                                              AppLocalizations.of(context)!.personalInformation,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.gender,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.gender ?? '___'
                                                : '___',
                                            icon: Icons.person_outline_rounded,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.nationality,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.nationality ?? '___'
                                                : '___',
                                            icon: Icons.flag_outlined,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.birthDate,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.dob ?? '___'
                                                : '___',
                                            icon: Icons.cake_outlined,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.age,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.age.toString()
                                                : '___',
                                            icon: Icons.calendar_today_outlined,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.martialStatus,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.martialStatus ?? '___'
                                                : '___',
                                            icon: Icons.favorite_border_rounded,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.phoneNo,
                                            widget.isTeamMate == false
                                                ? maskPhoneNumber(
                                                    (employeeDetails?.isNotEmpty ?? false)
                                                        ? (employeeDetails!.first.phoneNumber?.first.mobileNumber?.toString() ?? '')
                                                        : '',
                                                  )
                                                : (employeeDetails?.isNotEmpty ?? false)
                                                    ? (employeeDetails!.first.phoneNumber?.first.mobileNumber?.toString() ?? '___')
                                                    : '___',
                                            icon: Icons.phone_outlined,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.address,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.address?.streetAddress ?? '___'
                                                : '___',
                                            icon: Icons.location_on_outlined,
                                          ),
                                          _buildDetailField(
                                            AppLocalizations.of(context)!.passportNo,
                                            (employeeDetails?.isNotEmpty ?? false)
                                                ? employeeDetails!.first.passport?.id.toString() ?? '___'
                                                : '___',
                                            icon: Icons.badge_outlined,
                                            isLast: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Tab 1: Leave Balance ──────────────────
                                if (_selectedOptionIndex == 1) ...[
                                  if (employeeDetails != null && employeeDetails.isNotEmpty) ...[
                                    _buildLeaveCard(
                                      context,
                                      title: AppLocalizations.of(context)!.annualLeave,
                                      used: employeeDetails.first.leaveBalance?.annualLeave?.used ?? 0,
                                      remaining: employeeDetails.first.leaveBalance?.annualLeave?.remaining ?? 0,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildLeaveCard(
                                      context,
                                      title: AppLocalizations.of(context)!.sickLeave,
                                      used: employeeDetails.first.leaveBalance?.sickLeave?.used ?? 0,
                                      remaining: employeeDetails.first.leaveBalance?.sickLeave?.remaining ?? 0,
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.leaveHistory,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.history_rounded,
                                            color: NasColors.darkBlue,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Tab 2: Attendance ─────────────────────
                                if (_selectedOptionIndex == 2) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)?.attendance ?? 'Attendance',
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Icon(
                                                Icons.history_rounded,
                                                color: NasColors.darkBlue,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          _buildAttendanceList(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Tab 3: Documents ──────────────────────
                                if (_selectedOptionIndex == 3) ...[
                                  _buildDocumentsSection(context),
                                ],

                                // ── Tab 4: Assets ─────────────────────────
                                if (_selectedOptionIndex == 4) ...[
                                  _buildAssetsSection(context),
                                ],
                              ],
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {IconData? icon, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: NasColors.darkBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: NasColors.darkBlue),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade100, height: 1),
          ],
        ],
      ),
    );
  }

  // ── Helper: Leave Card ───────────────────────────────────────────────────
  Widget _buildLeaveCard(
    BuildContext context, {
    required String title,
    required int used,
    required int remaining,
  }) {
    final bool isSick = title.toLowerCase().contains('sick') || title.contains('مرضي');
    final IconData cardIcon = isSick ? Icons.medical_services_outlined : Icons.beach_access_rounded;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: NasColors.darkBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cardIcon, size: 18, color: NasColors.darkBlue),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.leaveUsed,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$used",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 45,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.leaveRemaining,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$remaining",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: Attendance List ──────────────────────────────────────────────
  Widget _buildAttendanceList(BuildContext context) {
    if (singletonClass.employeeDetailsAttendanceDataList.isEmpty ||
        singletonClass.employeeDetailsAttendanceDataList.first.data == null ||
        singletonClass.employeeDetailsAttendanceDataList.first.data!.isEmpty ||
        singletonClass.employeeDetailsAttendanceDataList.first.data!.first.data == null ||
        singletonClass.employeeDetailsAttendanceDataList.first.data!.first.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 140,
                width: 140,
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

    final attendanceList = singletonClass.employeeDetailsAttendanceDataList.first.data!.first.data!;

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendanceList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final attendance = attendanceList[index];

        int breakTime = attendance.breakTime ?? 0;
        int breakHours = breakTime ~/ 60;
        int breakMinutes = breakTime % 60;

        String date = "___";
        if (attendance.updatedAt != null) {
          try {
            date = DateFormat('dd-MM-yyyy').format(DateTime.parse(attendance.updatedAt!));
          } catch (_) {
            date = "___";
          }
        }

        int? lateMinutes = int.tryParse(formatMinutes(attendance.lateMinutes));
        int? earlyCheckOut = int.tryParse(formatMinutes(attendance.earlyCheckOut));

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipOval(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: Image.asset(
                        'images/DP.png',
                        fit: BoxFit.cover,
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.name?.isNotEmpty == true ? attendance.name! : "___",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _translateStatus(attendance.status, context),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(attendance.status ?? ""),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (_) {
                      int workedMinutes = attendance.totalHoursWorked ?? 0;
                      double progress = (workedMinutes / (11 * 60)).clamp(0.0, 1.0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${workedMinutes ~/ 60}h ${workedMinutes % 60}m",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            height: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0 ? Colors.green : Colors.orange,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    attendance.empId?.isNotEmpty == true ? attendance.empId! : "___",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.coffee_rounded, size: 16, color: Colors.brown.shade400),
                      const SizedBox(width: 4),
                      Text(
                        "${breakHours}h ${breakMinutes}m",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn(
                      AppLocalizations.of(context)?.checkIn ?? "Check In",
                      singletonClass.formatCheckInTime(attendance.clockInTime ?? "", context),
                      icon: Icons.login_rounded,
                      textColor: (lateMinutes != null && lateMinutes > 0) ? NasColors.pending : Colors.black87,
                    ),
                    _buildTimeColumn(
                      AppLocalizations.of(context)?.checkOut ?? "Check Out",
                      singletonClass.formatCheckInTime(attendance.clockOutTime ?? "", context),
                      icon: Icons.logout_rounded,
                      textColor: (lateMinutes != null && lateMinutes > 0) ? NasColors.pending : Colors.black87,
                    ),
                    _buildTimeColumn(
                      AppLocalizations.of(context)?.late ?? "Late",
                      "${lateMinutes! ~/ 60}${AppLocalizations.of(context)!.h} ${lateMinutes % 60}${AppLocalizations.of(context)!.m}",
                      icon: Icons.schedule_rounded,
                      textColor: NasColors.pending,
                    ),
                    _buildTimeColumn(
                      AppLocalizations.of(context)?.earlyLeft ?? "Early Left",
                      "${earlyCheckOut! ~/ 60}${AppLocalizations.of(context)!.h} ${earlyCheckOut % 60}${AppLocalizations.of(context)!.m}",
                      icon: Icons.timer_off_rounded,
                      textColor: NasColors.onTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(String label, String value, {IconData? icon, Color textColor = Colors.black87}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // ── Helper: Documents Section ────────────────────────────────────────────
  Widget _buildDocumentsSection(BuildContext context) {
    final docsInfo = (singletonClass.employeeDetailsDataList.isNotEmpty &&
            singletonClass.employeeDetailsDataList.first.data != null &&
            singletonClass.employeeDetailsDataList.first.data!.isNotEmpty)
        ? singletonClass.employeeDetailsDataList.first.data!.first.documentsInfo
        : null;

    if (docsInfo == null || docsInfo.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: Lottie.asset('images/empty.json'),
              ),
              const SizedBox(height: 12),
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

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docsInfo.length,
      itemBuilder: (BuildContext context, int index) {
        final documents = docsInfo[index];
        const String s3BaseUrl = 'https://nastecsol-hr-store.s3.amazonaws.com/';

        final String url = [
          documents.url,
          documents.remarks,
        ].firstWhere(
          (value) => value != null && value.contains(s3BaseUrl),
          orElse: () => '',
        );

        final fileType = url.split('.').last.toLowerCase();
        final isImage = ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);

        if (documents.type == "Doc_editor_shared") {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                if (url.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileViewerScreen(
                        url: url,
                        fileName: "${documents.type}",
                      ),
                    ),
                  );
                } else {
                  debugPrint('Invalid attachment URL');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: NasColors.darkBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  url,
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                _getFileIcon(url),
                                height: 30,
                                width: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            documents.type == "Doc_Contract_Emp"
                                ? AppLocalizations.of(context)!.employmentContract
                                : documents.type == "Doc_Uploaded_EMP"
                                    ? AppLocalizations.of(context)!.uploadedDocument
                                    : documents.type ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            debugPrint('Could not launch $url');
                          }
                        } else {
                          debugPrint('Invalid download URL');
                        }
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: NasColors.darkBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.asset(
                            'images/download.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: NasColors.darkBlue,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helper: Assets Section ───────────────────────────────────────────────
  Widget _buildAssetsSection(BuildContext context) {
    final assetsInfo = (singletonClass.employeeDetailsDataList.isNotEmpty &&
            singletonClass.employeeDetailsDataList.first.data != null &&
            singletonClass.employeeDetailsDataList.first.data!.isNotEmpty)
        ? singletonClass.employeeDetailsDataList.first.data!.first.assetsInfo
        : null;

    if (assetsInfo == null || assetsInfo.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: Lottie.asset('images/empty.json'),
              ),
              const SizedBox(height: 12),
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

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: assetsInfo.length,
      itemBuilder: (BuildContext context, int index) {
        final assets = assetsInfo[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDetailsScreenAssets(
                      assetsInfo: assets,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [NasColors.darkBlue, NasColors.lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Image.asset(
                          _getImageForEventType(assets.assetType ?? ""),
                          height: 38,
                          width: 38,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  assets.assetName ?? "",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.darkBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: NasColors.onTime,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Active",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assets.assetType ?? "",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.id}# ${assets.assetId ?? ""}",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.assignedAt} ${assets.issueDateFrom ?? ""}",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Option Tab Button (Pill Design Matching TeamScreen) ──────────────────
  Widget buildOptionsCard(int index, String title) {
    final bool isSelected = _selectedOptionIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [NasColors.darkBlue, NasColors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? NasColors.darkBlue.withOpacity(0.25)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : NasColors.darkBlue,
            ),
          ),
        ),
      ),
    );
  }

  String maskPhoneNumber(String number) {
    if (number.length < 4) return number;
    String prefix = number.substring(0, 3);
    String suffix = number.substring(number.length - 1);
    String masked = '*' * (number.length - 4);
    return '$prefix$masked$suffix';
  }

  Future<EmployeeDetailsData?> getEmployeeDetailsData() async {
    String? employeeId = widget.employees!.employeeInfo!.first.empId;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    print(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeDetailsData.fromJson(responseBody);
      singletonClass.setEmployeeDetailsData([employeeData]);
      getEmployeeAttendanceData();
      return employeeData;
    }
    return null;
  }

  ///EMPLOYEE ATTENDANCE DATA API CALL
  Future<EmployeeDetailsAttendanceData?> getEmployeeAttendanceData(
      {
        int limit = 10000,
        int page = 0,
      }
      ) async {
    String? employeeId =
        singletonClass.employeeDetailsDataList.first.data?.first.id;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();

    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);

    String firstDateString =
        '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString =
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '${singletonClass.baseURL}/c-emp-attendance/getDataByEmployeeId/$employeeId/$currentDateString/$firstDateString?limit=$limit&page=$page');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    print("Employee Attendance Data${response.body}");
    print(employeeId);
    print(firstDateString);
    print(currentDateString);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = EmployeeDetailsAttendanceData.fromJson(responseBody);
      singletonClass.setEmployeeAttendanceDataList([attendance]);
      return attendance;
    }

    return null;
  }

  String _getFileIcon(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'images/pdf.png';
      case 'doc':
      case 'docx':
        return 'images/word.png';
      case 'xls':
      case 'xlsx':
        return 'images/excel.png';
      case 'ppt':
      case 'pptx':
        return 'images/powerPoint.png';
      default:
        return 'images/documentIcons.png';
    }
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '--';
    try {
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString();
    } catch (e) {
      return '--';
    }
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (status == null) return localizations.noData;

    switch (status) {
      case 'Absent':
        return localizations.absent;
      case 'Present':
        return localizations.present;
      case 'Quarterly':
        return localizations.quarterly;
      case 'Missing CheckIn/Out':
        return localizations.missingCheckInOut;
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Absent":
        return NasColors.red;
      case "Present":
        return NasColors.completed;
      case "Quarterly":
        return NasColors.pending;
      case "Missing CheckIn/Out":
        return NasColors.pending;
      default:
        return NasColors.completed;
    }
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'laptop':
        return 'images/Laptop.png';
      case 'car':
        return 'images/Car.png';
      default:
        return 'images/Vector.png';
    }
  }
}
