import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:locale_plus/locale_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/assets_screen.dart';
import 'package:nashr/screens/company_notifications.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/document_screen.dart';
import 'package:nashr/screens/manage_time_screen.dart';
import 'package:nashr/screens/my_clocking_screen.dart';
import 'package:nashr/screens/notifications_screen.dart';
import 'package:nashr/screens/onboarding_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/setting_screen.dart';
import 'package:nashr/screens/slack_screen.dart';
import 'package:nashr/screens/socket_notification_screen.dart';
import 'package:nashr/screens/socket_screen.dart';
import 'package:nashr/screens/stores_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/screens/team_clocking.dart';
import 'package:nashr/screens/team_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UTILS/auth_services.dart';
import '../request_controller/attendance_model.dart' hide Data;
import '../widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import '../widgets/loader.dart';
import 'onsite_checkin.dart';
import 'dart:io';
import 'package:reorderables/reorderables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  SingletonClass singletonClass = SingletonClass();
  double blurAmount = 10.0;
  double opacityAmount = 1.0;
  bool showHeaderContent = true;
  bool isExpanded = true;
  bool isLoading = false;
  double _dragPosition = 0.0;
  bool _isSliderCompleted = false;
  String? _openLocation;
  String? selectedCompanyId;
  String? selectedBranchId;
  bool isLoadingBranches = false;
  double allowedRadius = 50;
  double? _companyLatitude;
  double? _companyLongitude;
  Duration _accumulatedWorkedDuration = Duration.zero;
  DateTime? _currentCheckIn;
  Timer? _timer;
  String _displayWorkedHours = '00:00:00';

  @override
  void initState() {
    super.initState();
    _parseCompanyLocation();
    singletonClass.getRoleAndAccessData();
    singletonClass.getCompanyNotificationData();
    singletonClass.getTeamBranchData();
    singletonClass.getEmployeeAttendanceData();
    singletonClass.getClockingData();
    singletonClass.getPolicyData();
    singletonClass.getHRLetter();
    singletonClass.fetchCompanyHeaderFooter("${singletonClass.getJWTModel()?.companyId}");
    calculateTodayWorkedTime();
    WidgetsBinding.instance.addObserver(this);
    trackOpenLocation();
    SocketService2().initSocket();
    setState(() {
      singletonClass.getChats();
      _calculateUnreadCount();
    });
    final locale = WidgetsBinding.instance.window.locale.languageCode;
    SocketService().initializeSocket('${singletonClass.tenantId}', locale);
    _draggableScrollableController.addListener(() {
      if (mounted) {
        setState(() {
          isExpanded = _draggableScrollableController.size > 0.3;
          showHeaderContent = isExpanded;
          blurAmount = isExpanded ? 10.0 : 0.0;
        });
      }
    });
    if (singletonClass.isFirstTimeSelectionDone == false) {
      autoSelectCompanyAndBranch();
      singletonClass.isFirstTimeSelectionDone = true;
    }
  }

  ///Drop down selection
  void autoSelectCompanyAndBranch(){
    final uiModules = singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!;
    final dashboardModule = uiModules.firstWhere(
          (e) => (e.title == "Dashboard" || e.name == "Dashboard") && e.hidden == false,
    );

    final companies = dashboardModule.accessLevel?.companies ?? [];

    if (companies.isNotEmpty && selectedCompanyId == null) {
      // Auto select 0 index company
      selectedCompanyId = companies.first.companyId;
      singletonClass.selectedCompanyId = selectedCompanyId;
      singletonClass.companyName = companies.first.companyName ?? '';

      // Populate branches of this company
      singletonClass.availableBranches = companies.first.branches ?? [];

      if (singletonClass.availableBranches.isNotEmpty && selectedBranchId == null) {
        // Auto select 0 index branch
        selectedBranchId = singletonClass.availableBranches.first.branchId;
        singletonClass.branchID = selectedBranchId;
        singletonClass.branchName = singletonClass.availableBranches.first.branchName ?? '';

        // Call your API
        singletonClass.getTeamBranchData();
        singletonClass.getBranchesData();
      }

      setState(() {});
    }
  }
  void _calculateUnreadCount() {
    try {
      if (singletonClass.slackDataList.isEmpty ||
          singletonClass.slackDataList.first.data == null ||
          singletonClass.slackDataList.first.data!.isEmpty) {
        debugPrint("⚠️ No chat data available in singleton");
        singletonClass.unreadCount = 0;
        return;
      }
      final allChats = singletonClass.slackDataList.first.data!;
      final userId = singletonClass.getJWTModel()?.employeeId;

      final unreadChats = allChats.where((chat) {
        // Only consider direct rooms
        if (chat.roomType != "direct") return false;

        // Ensure chat has messages
        final messages = chat.chatHistory ?? [];

        // Only count if there is at least one unread message not sent by the user
        return messages.any((m) => m.isRead == false && m.senderId != userId);
      }).toList();

      singletonClass.unreadCount = unreadChats.length;

      debugPrint("✅ Direct chats with unread messages: ${unreadChats.length}");
    } catch (e) {
      debugPrint("⚠️ Error counting unread chats: $e");
      setState(() => singletonClass.unreadCount = 0);
    }
  }
  void _parseCompanyLocation() {
    final list = singletonClass.remoteAttendanceModelList;

    if (list.isEmpty) return;

    final dataList = list.first.data;
    if (dataList == null || dataList.isEmpty) return;

    final locString = dataList.first.remoteAttendanceLoc;
    if (locString == null || locString.isEmpty) return;

    final parts = locString.split('|');
    if (parts.length != 2) return;

    _companyLatitude = double.tryParse(parts[0].trim()) ?? 0.0;
    _companyLongitude = double.tryParse(parts[1].trim()) ?? 0.0;
  }

  ///Timer
  void startWorkTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateWorkedTime();
    });
  }

  void stopWorkTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateWorkedTime() {
    Duration total = _accumulatedWorkedDuration;
    if (_currentCheckIn != null) {
      total += DateTime.now().difference(_currentCheckIn!);
    }

    _displayWorkedHours = '${total.inHours.toString().padLeft(2, '0')}:'
        '${(total.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(total.inSeconds % 60).toString().padLeft(2, '0')}';

    if (mounted) setState(() {});
  }

  void calculateTodayWorkedTime() {
    try {
      final today = DateTime.now();
      final dataList = singletonClass.attendanceDataList.first.data!.data;
      if (dataList == null || dataList.isEmpty) {
        stopWorkTimer();
        _displayWorkedHours = "00:00:00";
        return;
      }

      final todayEntries = dataList.where((entry) {
        final createdAt = DateTime.tryParse(entry.date ?? '');
        return createdAt != null &&
            createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).toList();

      _accumulatedWorkedDuration = Duration.zero;
      _currentCheckIn = null;

      if (todayEntries.isEmpty) {
        stopWorkTimer();
        _displayWorkedHours = "00:00:00";
        return;
      }

      final todayData = todayEntries.last;
      final checkInTime = todayData.clockInTime;
      final checkOutTime = todayData.clockOutTime;

      // 🔹 Both checkin/checkout empty → no work today
      if ((checkInTime == null || checkInTime.isEmpty || checkInTime == 'null') &&
          (checkOutTime == null || checkOutTime.isEmpty || checkOutTime == 'null')) {
        stopWorkTimer();
        _displayWorkedHours = "00:00:00";
        return;
      }

      // 🔹 Case 1: Only check-in available → running session
      if (checkInTime != null &&
          checkInTime.isNotEmpty && checkInTime != 'null') {
        _currentCheckIn = DateTime.tryParse(checkInTime);
        startWorkTimer();
        return;
      }

      if (checkOutTime != null &&
          checkOutTime.isNotEmpty && checkOutTime != 'null') {
        stopWorkTimer();
        _updateWorkedTime();
        return;
      }
      // Default fallback
      stopWorkTimer();
      _displayWorkedHours = "00:00:00";
    } catch (e) {
      _displayWorkedHours = '00:00:00';
      stopWorkTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draggableScrollableController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      trackBackgroundLocation();
    }
  }

  Future<void> trackOpenLocation() async {
    _openLocation = await getCurrentLatLong();
    updateRemoteLocation();
  }

  Future<void> trackBackgroundLocation() async {
    await getCurrentLatLong();
    updateRemoteLocation();
  }

  final DraggableScrollableController _draggableScrollableController = DraggableScrollableController();

  ///Slider
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: () {
            _removeOverlay();
          },
          child: Material(
            color: Colors.grey.withValues(alpha: 0.8), // Set the opacity
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.clockInType,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if ( singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!.any((e){
                    final title = (e.title ?? '').toLowerCase();
                    if (title == 'dashboard' && e.hidden == false) {
                      return e.onSiteCheckIn == true;
                    }
                    return false;
                  })) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnsiteCheckin()));
                        _removeOverlay();
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset("images/site.png"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!.location,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if(singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!.any((e){
                    final title = (e.title ?? '').toLowerCase();
                    if (title == 'dashboard' && e.hidden == false) {
                      return e.biometricCheckIn == true;
                    }
                    return false;
                  }))...[
                    GestureDetector(
                      onTap: () async {
                        if (!(await _authService.checkBiometricAvailability())) {
                          _removeOverlay();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.pleaseSetupBiometric,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )),
                          );
                          return;
                        }

                        bool isAuthenticated = await _authService
                            .authenticateWithBiometrics(context);
                        if (isAuthenticated) {
                          _removeOverlay();
                          await checkIn('biometric');
                        } else {
                          _removeOverlay();
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset("images/fingerprint.png"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!.biometricCheckIn,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///2ND OverLay
  OverlayEntry? _overlayEntry2;

  OverlayEntry _createViewAllOverlay() {
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
                .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
            [])
        : [];

    /// Check for Documents module
    final hasDocuments = uiSettings.any((e) =>
        (e.title == "Document" || e.title == "Documents") && e.hidden == false);

    /// Check for Stores
    final hasStores = uiSettings.any((e) =>
    (e.title == "stores" || e.title == "Stores") && e.hidden == false);
    /// Check for Teams module
    final hasTeams = uiSettings.any(
        (e) => (e.title == "teams" || e.title == "Teams") && e.hidden == false);

    /// Check for Assets module
    final hasAssets = uiSettings.any((e) =>
        (e.title == "assets" || e.title == "Asset" || e.title == "Assets") &&
        e.hidden == false);

    /// Check for Complaints - in Approval submenu
    final hasComplaints = uiSettings.any((e) {
      if (e.title == "Approval" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Complaints" || sub.title == "complaints") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Penalties and Fines - in Approval submenu
    final hasPenaltiesAndFines = uiSettings.any((e) {
      if (e.title == "Approval" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "PenaltiesandFines" || sub.title == "request") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

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

    /// Check for Manage Shifts - in ManageTime submenu
    final hasManageShifts = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Manage Shifts" || sub.title == "shifts") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Team Clocking (Attendance History) - in ManageTime submenu
    final hasAttendance = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Attendance History" ||
                    sub.title == "attendancehistory") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Biometric Checkins - in ManageTime submenu
    final hasBiometricCheckins = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Biometric Checkin`s" ||
                    sub.title == "admin-bio") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    ///Company notifications
    final hasCompanyNotifications = uiSettings.any((e) {
      if (e.title == "Document" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
        (sub.title == "Document Notification" || sub.title == "Document Notification") &&
            sub.hidden == false) ??
            false;
      }
      return false;
    });
     Future<List<Map<String, String>>> loadQuickActions() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = singletonClass.getJWTModel()?.employeeId ?? "default";
      List<Map<String, String>> defaultQuickActions = [
        {
          "icon": "images/files.png",
          "label": AppLocalizations.of(context)!.documents
        },
        {
          "icon": "images/assets.png",
          "label": AppLocalizations.of(context)!.assets
        },
        {
          "icon": "images/Team.png",
          "label": AppLocalizations.of(context)!.teams
        },
        {
          "icon": "images/Complain.png",
          "label": AppLocalizations.of(context)!.complaints
        },
        {
          "icon": "images/Penalties.png",
          "label": AppLocalizations.of(context)!.penalties
        },
        {
          "icon": "images/attendance.png",
          "label": AppLocalizations.of(context)!.attendance
        },
        {
          "icon": "images/fingerprint.png",
          "label": AppLocalizations.of(context)!.biometricCheckIn
        },
        {
          "icon": "images/clock.png",
          "label": AppLocalizations.of(context)!.manageShifts
        },
        {
          "icon": "images/schedule.png",
          "label": AppLocalizations.of(context)!.onBoarding
        },
        {
          "icon": "images/pc.png",
          "label": AppLocalizations.of(context)!.companyNotifications
        },
        {
          "icon": "images/thisMonth.png",
          "label": AppLocalizations.of(context)!.stores
        },
      ];
      List<String>? savedOrder = prefs.getStringList("quickActions_$userId");
      if (savedOrder != null && savedOrder.isNotEmpty) {
        defaultQuickActions.sort((a, b) {
          int indexA = savedOrder.indexOf(a["label"]!);
          int indexB = savedOrder.indexOf(b["label"]!);
          return indexA.compareTo(indexB);
        });
      }
      return defaultQuickActions;
    }

    return OverlayEntry(
        builder: (context) => FutureBuilder<List<Map<String, String>>>(
            future: loadQuickActions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Map<String, String>> quickActions = snapshot.data!;
              return Positioned.fill(
                child: GestureDetector(
                  onTap: _removeOverlay,
                  child: Material(
                    color: NasColors.darkBlue.withValues(alpha: 0.8),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF444658),
                            Color(0xFF83869B),
                            Color(0xFFBCC0E7),
                            Color(0xFF727694),
                            Color(0xFF444658),
                          ],
                        ),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 40),
                          child: ReorderableWrap(
                            spacing: 40,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            needsLongPressDraggable: true,
                            onReorder: (oldIndex, newIndex) async {
                              final item = quickActions.removeAt(oldIndex);
                              quickActions.insert(newIndex, item);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId =
                                  singletonClass.getJWTModel()?.employeeId ??
                                      "default";
                              List<String> labelsOrder =
                                  quickActions.map((e) => e["label"]!).toList();
                              prefs.setStringList(
                                  "quickActions_$userId", labelsOrder);
                            },
                            buildDraggableFeedback:
                                (context, constraints, child) {
                              return Material(
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                            children: quickActions.where((item) {
                              if (item["label"] ==
                                      AppLocalizations.of(context)!.documents &&
                                  !hasDocuments) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!.assets &&
                                  !hasAssets) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!.teams &&
                                  !hasTeams) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .complaints &&
                                  !hasComplaints) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!.penalties &&
                                  !hasPenaltiesAndFines) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .biometricCheckIn &&
                                  !hasBiometricCheckins) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .attendance &&
                                  !hasAttendance) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .onBoarding &&
                                  !hasOnboarding) {
                                return false;
                              }
                              if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .manageShifts &&
                                  !hasManageShifts) {
                                return false;
                              }
                              if (item["label"] ==
                                  AppLocalizations.of(context)!
                                      .companyNotifications &&
                                  !hasCompanyNotifications) {
                                return false;
                              }
                              if (item["label"] ==
                                  AppLocalizations.of(context)!
                                      .stores &&
                                  !hasStores) {
                                return false;
                              }
                              return true;
                            }).map((item) {
                              return GestureDetector(
                                onTap: () {
                                  if (item["label"] ==
                                      AppLocalizations.of(context)!.documents) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DocumentScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!.assets) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AssetsScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!.teams) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TeamScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .complaints) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Complaints()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!.penalties) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PenaltyAndFineScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .onBoarding) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OnboardingScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .attendance) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeamAttendanceScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .biometricCheckIn) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TeamClocking()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .manageShifts) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ManageTimeScreen()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .companyNotifications) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CompanyNotifications()),
                                    );
                                  } else if (item["label"] ==
                                      AppLocalizations.of(context)!
                                          .stores) {
                                    _removeOverlay();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StoresScreen()),
                                    );
                                  }
                                },
                                child: Column(
                                  key: ValueKey(item["label"]),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          item["icon"]!,
                                          width: 35,
                                          height: 35,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item["label"]!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayEntry2?.remove();
    _overlayEntry2 = null;
  }

  void toggleSheet() {
    setState(() {
      if (isExpanded) {
        _draggableScrollableController.animateTo(
          0.2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _draggableScrollableController.animateTo(
          0.65,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      isExpanded = !isExpanded;
    });
  }

  bool showDropdown = false;

  @override
  Widget build(BuildContext context) {
    final dashBoardData = singletonClass.employeeDataList.first.data;
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
                .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
            [])
        : [];

    /// Check for Documents module
    final hasDocuments = uiSettings.any((e) =>
        (e.title == "Document" || e.title == "Documents") && e.hidden == false);

    /// Check for stores
    final hasStores = uiSettings.any((e) =>
    (e.title == "Stores" || e.title == "stores") && e.hidden == false);
    /// Check for Teams module
    final hasTeams = uiSettings.any(
        (e) => (e.title == "teams" || e.title == "Teams") && e.hidden == false);

    /// Check for Assets module
    final hasAssets = uiSettings.any((e) =>
        (e.title == "assets" || e.title == "Asset" || e.title == "Assets") &&
        e.hidden == false);

    /// Check for Complaints - in Approval submenu
    final hasComplaints = uiSettings.any((e) {
      if (e.title == "Approval" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Complaints" || sub.title == "complaints") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });
    final hasCompanyNotifications = uiSettings.any((e) {
      if (e.title == "Document" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
        (sub.title == "Document Notification" || sub.title == "Document Notification") &&
            sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Penalties and Fines - in Approval submenu
    final hasPenaltiesAndFines = uiSettings.any((e) {
      if (e.title == "Approval" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "PenaltiesandFines" || sub.title == "request") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Manage Shifts - in ManageTime submenu
    final hasManageShifts = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Manage Shifts" || sub.title == "shifts") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Team Clocking (Attendance History) - in ManageTime submenu
    final hasAttendance = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Attendance History" ||
                    sub.title == "attendancehistory") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    /// Check for Biometric Checkins - in ManageTime submenu
    final hasBiometricCheckins = uiSettings.any((e) {
      if ((e.title == "ManageTime" || e.title == "manageTime") &&
          e.hidden == false) {
        return e.subMenu?.any((sub) =>
                (sub.title == "Biometric Checkin`s" ||
                    sub.title == "admin-bio") &&
                sub.hidden == false) ??
            false;
      }
      return false;
    });

    ///Chats
    final hasChats = uiSettings.any((e) {
      final title = (e.title ?? e.name ?? '').toLowerCase();
      return title == 'chat' && e.hidden == false;
    });

    /// ✅ Socket Notifications
    final hasSocketNotification = uiSettings.any((e) {
      final title = (e.title ?? '').toLowerCase();
      if (title == 'dashboard' && e.hidden == false) {
        return e.subMenu?.any((sub) => sub.showSocketNotifications == true) ??
            false;
      }
      return false;
    });

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

    ///Dashboard module checks
    final dashboardModule = singletonClass
        .roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere(
      (e) => e.title == "Dashboard" || e.title == "dashboard",
    );
    final access = dashboardModule.accessLevel;
    final companies = access!.companies ?? [];
    final hasCompanies = companies.isNotEmpty;
    final hasBranches =
        hasCompanies && companies.any((c) => (c.branches ?? []).isNotEmpty);
    final teamEnabled = access.team == true;

    if (hasCompanies && hasBranches && teamEnabled) {
      // ✅ Case 1: Companies + Branches + Team → Dropdown + Team + Only Me
      showDropdown = true;
    } else if (hasCompanies && hasBranches && !teamEnabled) {
      // ✅ Case 2: Companies + Branches + No Team → Dropdown + Only Me
      showDropdown = true;
    } else if (!hasCompanies && !hasBranches && teamEnabled) {
      // ✅ Case 3: No companies + No branches + Team → Team + Only Me
      showDropdown = false;
    } else if (!hasCompanies && !hasBranches && !teamEnabled) {
      // ✅ Case 4: No companies + No branches + No Team → Only Me
      showDropdown = false;
    }

    final bool shouldShowDropdown =
        showDropdown &&
            companies.isNotEmpty &&
            companies.any(
                  (company) =>
                  (company.branches ?? []).any(
                        (branch) =>
                    (branch.branchId != null &&
                        branch.branchId!.trim().isNotEmpty) ||
                        (branch.branchName != null &&
                            branch.branchName!.trim().isNotEmpty),
                  ),
            );
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: const BoxDecoration(),
            child: Stack(
              fit: StackFit.expand,
              children: [
            (dashBoardData?.profilePic != null &&
            dashBoardData!.profilePic!.isNotEmpty &&
            dashBoardData.profilePic != "https://www.profilePic.com")
                ? Image.network(
              dashBoardData.profilePic!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'images/DP.png',
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              'images/DP.png',
              fit: BoxFit.cover,
            ),
      BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: Container(
                      color: Colors.black
                          .withValues(alpha: (opacityAmount * 0.1 * 2))),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 12, top: 50, left: 10),
                    child: AnimatedOpacity(
                      opacity: showHeaderContent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: toggleSheet,
                        child: (singletonClass.employeeDataList.first.data!.profilePic == "https://www.profilePic.com" ||
                            singletonClass.employeeDataList.first.data!.profilePic == null ||
                            singletonClass.employeeDataList.first.data!.profilePic.isEmpty
                        ) ? ClipOval(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: ClipOval(
                                child: Image.asset(
                                  'images/DP.png',
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                            ),
                          ),
                        ) : ClipOval(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: ClipOval(
                              child: Image.network(
                                dashBoardData?.profilePic!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'images/DP.png',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 55),
                    child: AnimatedOpacity(
                      opacity: showHeaderContent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 170,
                            child: Text(
                              '${dashBoardData?.firstName} ${dashBoardData?.middleName} ${dashBoardData?.lastName}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 170,
                            child: Text(
                              '${dashBoardData?.profession}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 170,
                            child: Text(
                              '${AppLocalizations.of(context)!.contractId} #${(dashBoardData?.contractInfo?.isNotEmpty ?? false) ? dashBoardData!.contractInfo!.first.contractId : 'N/A'}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, top: 35),
                  child: AnimatedOpacity(
                    opacity: showHeaderContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NotificationsScreen()));
                          },
                          icon: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9.0),
                              // optional padding
                              child: Image.asset(
                                'images/notification.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyClockingScreen()));
                          },
                          icon: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Image.asset(
                                'images/clocking.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        hasSocketNotification
                            ? IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SocketNotificationScreen()));
                                },
                                icon: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Image.asset(
                                      'images/fingerprint.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingScreen()));
                                },
                                icon: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                        if (hasChats)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SlackScreen()),
                                  );
                                  // Recalculate when returning back from Slack screen
                                  _calculateUnreadCount();
                                },
                                icon: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.white.withValues(alpha: 0.6),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Image.asset(
                                      'images/Comments.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                              // 🔴 Badge for unread count
                              if (singletonClass.unreadCount > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      singletonClass.unreadCount > 99
                                          ? '99+'
                                          : singletonClass.unreadCount
                                              .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (!isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            spreadRadius: 5,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: IconButton(
                          onPressed: toggleSheet,
                          icon: const Icon(Icons.close))),
                ],
              ),
            ),
          Listener(
            onPointerMove: (PointerMoveEvent event) {},
            child: DraggableScrollableSheet(
              controller: _draggableScrollableController,
              initialChildSize: isExpanded ? 0.62 : 0.2,
              minChildSize: 0.2,
              maxChildSize: 0.7,
              expand: true,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: NasColors.backGround,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.0,
                          -10.0,
                        ),
                      )
                    ],
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(3),
                    controller: scrollController,
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 10,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: NasColors.darkBlue,
                                ),
                              )
                            ],
                          ),
                          if (showDropdown && shouldShowDropdown)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  /// Company Dropdown
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          dropdownColor: Colors.white,
                                          isExpanded: true,
                                          value: selectedCompanyId,
                                          hint: Row(
                                            children: [
                                              Image.asset('images/site.png',
                                                  width: 15, height: 15),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  singletonClass.companyName
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? singletonClass
                                                          .companyName!
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .select,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: (() {
                                            final uiModules = singletonClass
                                                .roleAndAccessModelDataList
                                                .first
                                                .data!
                                                .uiSettings!
                                                .uiModules!;
                                            final dashboardModule =
                                                uiModules.firstWhere(
                                              (e) =>
                                                  (e.title == "Dashboard" ||
                                                      e.name == "Dashboard") &&
                                                  e.hidden == false,
                                            );
                                            final companies = dashboardModule
                                                    .accessLevel?.companies ??
                                                [];
                                            return companies
                                                .map<DropdownMenuItem<String>>(
                                                    (company) {
                                              return DropdownMenuItem<String>(
                                                value: company.companyId,
                                                child: Text(
                                                    company.companyName ??
                                                        "---"),
                                              );
                                            }).toList();
                                          })(),
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() {
                                              // select company
                                              selectedCompanyId = value;
                                              singletonClass.selectedCompanyId =
                                                  value;

                                              // find selected company and update company name
                                              final uiModules = singletonClass
                                                  .roleAndAccessModelDataList
                                                  .first
                                                  .data!
                                                  .uiSettings!
                                                  .uiModules!;
                                              final dashboardModule =
                                                  uiModules.firstWhere(
                                                (e) =>
                                                    (e.title == "Dashboard" ||
                                                        e.name ==
                                                            "Dashboard") &&
                                                    e.hidden == false,
                                              );
                                              final companies = dashboardModule
                                                      .accessLevel?.companies ??
                                                  [];
                                              final selectedCompany =
                                                  companies.firstWhere(
                                                (c) => c.companyId == value,
                                              );

                                              singletonClass.companyName =
                                                  selectedCompany.companyName ??
                                                      '';

                                              // populate branches for this company and clear selected branch
                                              singletonClass.availableBranches =
                                                  selectedCompany.branches ??
                                                      [];
                                              selectedBranchId = null;
                                              singletonClass.branchID = null;
                                              singletonClass.branchName = null;
                                              singletonClass.getBranchesData();
                                              singletonClass.getCompanyData();
                                              singletonClass.getTeamBranchData();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  /// Branch Dropdown
                                  Expanded(
                                      child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: Colors.white,
                                        isExpanded: true,
                                        value: selectedBranchId,
                                        hint: Text(
                                          isLoadingBranches
                                              ? AppLocalizations.of(context)!
                                                  .loading
                                              : (singletonClass.branchName ==
                                                          null ||
                                                      singletonClass
                                                          .branchName!.isEmpty)
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .selectBranch
                                                  : singletonClass.branchName!,
                                        ),
                                        items: singletonClass
                                                .availableBranches.isNotEmpty
                                            ? singletonClass.availableBranches
                                                .map<DropdownMenuItem<String>>(
                                                    (branch) {
                                                return DropdownMenuItem<String>(
                                                  value: branch.branchId,
                                                  child: Text(
                                                      branch.branchName ??
                                                          "---"),
                                                );
                                              }).toList()
                                            : [],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBranchId = value;
                                            singletonClass.branchID =
                                                selectedBranchId;
                                            singletonClass.getTeamBranchData();
                                            print(singletonClass.branchID);
                                            final selectedBranch =
                                                singletonClass.availableBranches
                                                    .firstWhere((branch) =>
                                                        branch.branchId
                                                            .toString() ==
                                                        value);
                                            singletonClass.branchName =
                                                selectedBranch.branchName ?? '';
                                          });
                                        },
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        if (singletonClass
                                                .clockingDataList.isNotEmpty &&
                                            singletonClass
                                                    .clockingDataList.first.data !=
                                                null &&
                                            singletonClass.clockingDataList
                                                .first.data!.isNotEmpty &&
                                            singletonClass
                                                    .clockingDataList
                                                    .first
                                                    .data!
                                                    .first
                                                    .checkInTime !=
                                                null &&
                                            singletonClass
                                                .clockingDataList
                                                .first
                                                .data!
                                                .first
                                                .checkInTime!
                                                .isNotEmpty) ...[
                                          Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                color: getTodayStatusColor(),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (singletonClass
                                                          .attendanceDataList
                                                          .isNotEmpty &&
                                                      singletonClass
                                                              .attendanceDataList
                                                              .first
                                                              .data!
                                                              .data !=
                                                          null &&
                                                      singletonClass
                                                          .attendanceDataList
                                                          .first
                                                          .data!
                                                          .data!
                                                          .isNotEmpty)
                                                    Builder(builder: (context) {
                                                      final today =
                                                          DateTime.now();
                                                      final dataList =
                                                          singletonClass
                                                              .attendanceDataList
                                                              .first
                                                              .data!
                                                              .data!;
                                                      Data1? entry;
                                                      final filteredList =
                                                          dataList.where((e) {
                                                        final createdAt =
                                                            DateTime.tryParse(
                                                                e.createdAt ??
                                                                    '');
                                                        return createdAt !=
                                                                null &&
                                                            createdAt.year ==
                                                                today.year &&
                                                            createdAt.month ==
                                                                today.month &&
                                                            createdAt.day ==
                                                                today.day;
                                                      }).toList();
                                                      if (filteredList
                                                          .isNotEmpty) {
                                                        entry =
                                                            filteredList.first;
                                                      }
                                                      if (entry == null) {
                                                        return SizedBox();
                                                      }
                                                      if (entry
                                                              .secondaryStatus ==
                                                          "Late") {
                                                        return Text(
                                                          "${AppLocalizations.of(context)!.late} ${entry.lateMinutes! ~/ 60}${AppLocalizations.of(context)!.h} ${entry.lateMinutes! % 60}${AppLocalizations.of(context)!.m}",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      } else if (entry
                                                              .secondaryStatus ==
                                                          "Early-Out") {
                                                        return Text(
                                                          "${AppLocalizations.of(context)!.earlyCheckOut} ${entry.earlyCheckOut! ~/ 60}${AppLocalizations.of(context)!.h} ${entry.earlyCheckOut! % 60}${AppLocalizations.of(context)!.m}",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      } else {
                                                        return Text(
                                                          _translateSecondaryStatus(
                                                              entry
                                                                  .secondaryStatus,
                                                              context),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      }
                                                    })
                                                  else
                                                    Text(
                                                      "--:--",
                                                      style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.white),
                                                    ),
                                                ],
                                              )),
                                        ] else ...[
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              color: getTodayStatusColor(),
                                            ),
                                          ),
                                        ],

                                        /// 🔹 Check-In Row
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              left: 15,
                                              right: 8,
                                              bottom: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                    "images/checkIn.png"),
                                              ),
                                              const SizedBox(width: 40),
                                              Expanded(
                                                child: Text(
                                                  () {
                                                    try {
                                                      final today =
                                                          DateTime.now();
                                                      final dataList =
                                                          singletonClass
                                                              .attendanceDataList
                                                              .first
                                                              .data!.data;
                                                      if (dataList == null ||
                                                          dataList.isEmpty) {
                                                        return '--:--';
                                                      }

                                                      final todayEntries =
                                                          dataList
                                                              .where((entry) {
                                                        final createdAt =
                                                            DateTime.tryParse(
                                                                entry.createdAt ??
                                                                    '');
                                                        return createdAt !=
                                                                null &&
                                                            createdAt.year ==
                                                                today.year &&
                                                            createdAt.month ==
                                                                today.month &&
                                                            createdAt.day ==
                                                                today.day;
                                                      }).toList();

                                                      if (todayEntries
                                                          .isEmpty) {
                                                        return '--:--';
                                                      }

                                                      final lastEntry =
                                                          todayEntries.last;
                                                      return (lastEntry
                                                                  .clockInTime
                                                                  ?.isNotEmpty ??
                                                              false)
                                                          ? singletonClass
                                                              .formatCheckInTime(
                                                                  lastEntry
                                                                      .clockInTime!,
                                                                  context)
                                                          : '--:--';
                                                    } catch (_) {
                                                      return '--:--';
                                                    }
                                                  }(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        /// 🔹 Check-Out Row
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, left: 15, right: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                    "images/checkOut.png"),
                                              ),
                                              const SizedBox(width: 40),
                                              Expanded(
                                                child: Text(
                                                      () {
                                                    try {
                                                      final today =
                                                      DateTime.now();
                                                      final dataList =
                                                          singletonClass
                                                              .attendanceDataList
                                                              .first
                                                              .data!.data;
                                                      if (dataList == null ||
                                                          dataList.isEmpty) {
                                                        return '--:--';
                                                      }

                                                      final todayEntries =
                                                      dataList
                                                          .where((entry) {
                                                        final createdAt =
                                                        DateTime.tryParse(
                                                            entry.createdAt ??
                                                                '');
                                                        return createdAt !=
                                                            null &&
                                                            createdAt.year ==
                                                                today.year &&
                                                            createdAt.month ==
                                                                today.month &&
                                                            createdAt.day ==
                                                                today.day;
                                                      }).toList();

                                                      if (todayEntries
                                                          .isEmpty) {
                                                        return '--:--';
                                                      }

                                                      final lastEntry =
                                                          todayEntries.last;
                                                      return (lastEntry
                                                          .clockOutTime
                                                          ?.isNotEmpty ??
                                                          false)
                                                          ? singletonClass
                                                          .formatCheckInTime(
                                                          lastEntry
                                                              .clockOutTime!,
                                                          context)
                                                          : '--:--';
                                                    } catch (_) {
                                                      return '--:--';
                                                    }
                                                  }(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              left: 15,
                                              right: 8,
                                              bottom: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                  "images/break.png",
                                                ),
                                              ),
                                              const SizedBox(width: 40),
                                              Text(
                                                singletonClass
                                                            .attendanceDataList
                                                            .isNotEmpty &&
                                                        singletonClass
                                                            .attendanceDataList
                                                            .first
                                                            .data!
                                                            .data!
                                                            .isNotEmpty
                                                    ? "${formatMinutes(singletonClass.attendanceDataList.first.data!.data!.first.breakTime)} ${AppLocalizations.of(context)!.minutes}"
                                                    : '--:--',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.grey.withValues(alpha: 0.5),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          color: NasColors.darkBlue,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .totalHours,
                                              style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 120,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                _displayWorkedHours,
                                                style: GoogleFonts.inter(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          _timer != null && _timer!.isActive
                                              ? SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Lottie.asset('images/working.json'),
                                          )
                                              : SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Lottie.asset('images/totalWork.json'),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    _dragPosition += details.primaryDelta!;
                                    if (_dragPosition.abs() > MediaQuery.of(context).size.width * 0.7) {
                                      _isSliderCompleted = true;
                                    }
                                  });
                                },
                                onHorizontalDragEnd: (details) {
                                  setState(() {
                                    if (_isSliderCompleted) {
                                      _overlayEntry = _createOverlayEntry();
                                      Overlay.of(context).insert(_overlayEntry!);
                                    }
                                    _dragPosition = 0;
                                    _isSliderCompleted = false;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF444658),
                                        Color(0xFF677587),
                                        Color(0xFF78889D),
                                        Color(0xFF9DB2CE),
                                        Color(0xFF8799B1),
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                  ),
                                  height: 60,
                                  child: (() {
                                    final dataList = singletonClass.attendanceDataList.first.data!.data ?? [];
                                    final today = DateTime.now();
                                    final todayEntries = dataList.where((entry) {
                                      final createdAt = DateTime.tryParse(entry.createdAt ?? '');
                                      return createdAt != null &&
                                          createdAt.year == today.year &&
                                          createdAt.month == today.month &&
                                          createdAt.day == today.day;
                                    }).toList();
                                    final todayData = todayEntries.isNotEmpty ? todayEntries.last : null;
                                    String? checkInTime = todayData?.clockInTime;
                                    String? checkOutTime = todayData?.clockOutTime;
                                    String displayText = AppLocalizations.of(context)!.swipeToCheckIn;

                                    if ((checkInTime == null || checkInTime.isEmpty || checkInTime == 'null') &&
                                        (checkOutTime == null || checkOutTime.isEmpty  || checkOutTime == 'null')) {
                                      displayText = AppLocalizations.of(context)!.swipeToCheckIn;
                                    } else if ((checkInTime != null && checkInTime.isNotEmpty && checkInTime != "null")) {
                                      displayText = AppLocalizations.of(context)!.swipeToCheckOut;
                                    } else if ((checkInTime != null && checkInTime.isNotEmpty && checkInTime != 'null') &&
                                        (checkOutTime != null && checkOutTime.isNotEmpty && checkOutTime != "null")) {
                                      displayText = AppLocalizations.of(context)!.swipeToCheckIn;
                                    }

                                    // Always show swipe UI
                                    return Transform.translate(
                                      offset: Offset(_dragPosition, -1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            _timer != null && _timer!.isActive ?
                                            Container(
                                              width: 60,
                                              height: 50,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Colors.white,
                                              ),
                                              child: Lottie.asset('images/working.json'),
                                            ) : Container(
                                              width: 60,
                                              height: 50,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Colors.white,
                                              ),
                                              child: Lottie.asset('images/swiper.json'),
                                            ),
                                            const SizedBox(width: 50),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                displayText,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })(),
                                ),
                              ),
                            )
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    _overlayEntry2 = _createViewAllOverlay();
                                    Overlay.of(context).insert(_overlayEntry2!);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.viewAll,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  if (hasAttendance)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TeamAttendanceScreen()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/attendance.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .attendance,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasDocuments)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const DocumentScreen()));
                                          },
                                          child: Stack(children: [
                                            Container(
                                              height: 65,
                                              width: 65,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 0.5,
                                                    offset: const Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'images/files.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ),
                                            if (singletonClass.employeeDataList
                                                    .isNotEmpty &&
                                                singletonClass
                                                        .employeeDataList
                                                        .first
                                                        .data
                                                        ?.documentsInfo !=
                                                    null &&
                                                singletonClass
                                                    .employeeDataList
                                                    .first
                                                    .data!
                                                    .documentsInfo!
                                                    .isNotEmpty)
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 18,
                                                    minHeight: 18,
                                                  ),
                                                  child: Text(
                                                    '${singletonClass.employeeDataList.first.data!.documentsInfo!.length}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              )
                                          ]),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .documents,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasAssets)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AssetsScreen()));
                                          },
                                          child: Stack(
                                            children:[ Container(
                                              height: 65,
                                              width: 65,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 0.5,
                                                    offset: const Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'images/assets.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ),
                                              if (singletonClass.employeeDataList.isNotEmpty &&
                                                  singletonClass.employeeDataList.first.data?.assetsInfo != null &&
                                                  singletonClass.employeeDataList.first.data!.assetsInfo!.isNotEmpty)
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                    ),
                                                    constraints:
                                                    const BoxConstraints(
                                                      minWidth: 18,
                                                      minHeight: 18,
                                                    ),
                                                    child: Text(
                                                      '${singletonClass.employeeDataList.first.data!.assetsInfo!.length}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                )
                      ]
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!.assets,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasTeams)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TeamScreen()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/Team.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!.teams,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasComplaints)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const Complaints()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/Complain.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .complaints,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasPenaltiesAndFines)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PenaltyAndFineScreen()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/Penalties.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .penalties,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasManageShifts)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ManageTimeScreen()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/clock.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .manageShifts,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasBiometricCheckins)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const TeamClocking()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/fingerprint.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .biometrics,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasOnboarding)...[
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const OnboardingScreen()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'images/schedule.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .onBoarding,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasCompanyNotifications)...[
                                    Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const CompanyNotifications()));
                                        },
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 0.5,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              'images/pc.png',
                                              fit: BoxFit.contain,
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        AppLocalizations.of(context)!.documentNotification,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                    const SizedBox(width: 20),
                                  ],
                                  if (hasStores)...[
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const StoresScreen()));
                                        },
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 0.5,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              'images/thisMonth.png',
                                              fit: BoxFit.contain,
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .stores,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                    const SizedBox(width: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .empLeaveBalance,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                        height: 105,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 90,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 4.0,
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .annualLeave,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        13),
                                                              )),
                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: Image.asset(
                                                                "images/thisMonthIcon.png"),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${singletonClass.employeeDataList.first.data!.leaveBalance!.annualLeave!.used}/${singletonClass.employeeDataList.first.data!.leaveBalance!.annualLeave!.entitlement.toStringAsFixed(0)}",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 90,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 2.0,
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .remoteDaysThisMonth,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        13),
                                                              )),
                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: Image.asset(
                                                                "images/remoteIcon.png"),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "0/0",
                                                            style: GoogleFonts.inter(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 90,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width:
                                                          2.0, // Set the border width
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width:
                                                          2.0, // Set the border width
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .casualLeave,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        13),
                                                              )),
                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: Image.asset(
                                                                "images/thisMonth.png"),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${singletonClass.employeeDataList.first.data!.leaveBalance!.casualLeave!.used}/${singletonClass.employeeDataList.first.data!.leaveBalance!.casualLeave!.entitlement}",
                                                            style: GoogleFonts.inter(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 95,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 2.0,
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .shortLeaves,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12),
                                                              )),
                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: Image.asset(
                                                                "images/image.png"),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            formatMinutesToHoursAndMinutes(
                                                                context,
                                                                singletonClass
                                                                    .employeeDataList
                                                                    .first
                                                                    .data!
                                                                    .leaveBalance!
                                                                    .shortLeavesMonthlyBal!
                                                                    .shortLeavesMinutes!
                                                                    .toInt()),
                                                            style: GoogleFonts.inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 90,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width:
                                                          2.0, // Set the border width
                                                    ),
                                                    right: BorderSide(
                                                      color:
                                                          NasColors.lightBlue,
                                                      width:
                                                          4.0, // Set the border width
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .sickLeave,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        13),
                                                              )),
                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: Image.asset(
                                                                "images/thisMonth.png"),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${singletonClass.employeeDataList.first.data!.leaveBalance!.sickLeave!.used}/${singletonClass.employeeDataList.first.data!.leaveBalance!.sickLeave!.entitlement}",
                                                            style: GoogleFonts.inter(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (isLoading) Loader()
        ],
      ),
    );
  }

  String _translateSecondaryStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (status == null || status.isEmpty) {
      return localizations.noData;
    }
    final statuses = status.toLowerCase();
    switch (statuses) {
      case 'Absent':
        return localizations.absent;
      case 'Present':
        return localizations.present;
      case 'late':
        return localizations.late;
      case 'leave':
        return localizations.leave;
      case 'holiday':
        return localizations.holiday;
      case 'dayOFF':
        return localizations.dayOff;
      case 'training':
        return localizations.training;
      case 'absent with approval':
        return localizations.absentWithApproval;
      case 'Missing CheckIn/Out':
        return localizations.missingCheckInOut;
      case 'Late':
        return localizations.late;
      case 'Pending':
        return localizations.pending;
      case 'No-CheckIn':
        return localizations.noCheckIn;
      case 'Late-Penality':
        return localizations.latePenality;
      case 'Short-Hours':
        return localizations.shortHours;
      case 'Missing-CheckIn':
        return localizations.missingCheckIn;
      case 'Missing-CheckOut':
        return localizations.missingCheckOut;
      case 'Check-In':
        return localizations.checkIn;
      case 'Check-Out':
        return localizations.checkOut;
      case 'OOS-In':
        return localizations.oosIn;
      case 'OOS-Out':
        return localizations.oosOut;
      case 'Early-In':
        return localizations.earlyIn;
      case 'Early-Left':
        return localizations.earlyLeft;
      case 'OnTime-In':
        return localizations.onTimeIn;
      case 'OnTime-Out':
        return localizations.onTimeOut;
      case 'Late-In':
        return localizations.lateIn;
      case 'Late-Out':
        return localizations.lateOut;
      case 'SM-In':
        return localizations.smIn;
      case 'SM-Out':
        return localizations.smOut;
      case 'Break-In':
        return localizations.breakIn;
      case 'Break-Out':
        return localizations.breakOut;
      case 'slot':
        return localizations.slot;
      case 'Out-Off-Shift':
        return localizations.outOffShift;
      case 'Full-Day':
        return localizations.fullDay;
      default:
        return status;
    }
  }

  Color getTodayStatusColor() {
    try {
      final today = DateTime.now();
      final dataList = singletonClass.attendanceDataList.first.data?.data ?? [];

      if (dataList.isEmpty) return NasColors.darkBlue;

      final entry = dataList.firstWhere(
        (e) {
          final createdAt = DateTime.tryParse(e.createdAt ?? '');
          return createdAt != null &&
              createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day;
        },
      );

      if (entry.secondaryStatus == null) {
        return NasColors.darkBlue;
      }

      final status = entry.secondaryStatus!.toLowerCase();

      switch (status) {
        case 'present':
        case 'ontime-in':
        case 'ontime-out':
          return NasColors.green;

        case 'absent':
          return NasColors.reds;

        case 'absent with approval':
        case 'pending':
          return NasColors.yellow;

        case 'early checkout':
        case 'early-out':
        case 'early-in':
          return NasColors.purple;

        case 'late':
        case 'late-in':
        case 'late-out':
          return NasColors.amber;

        case 'check-in':
          return NasColors.violet;

        case 'check-out':
          return NasColors.fuchsia;

        case 'oos-in':
        case 'oos-out':
          return NasColors.amber;

        case 'sm-in':
        case 'sm-out':
          return NasColors.indigo;

        case 'break-in':
        case 'break-out':
          return NasColors.zinc;

        case 'slot':
          return NasColors.warmGray;

        case 'no-checkin':
          return NasColors.darkGray;

        case 'on-leave':
        case 'casual leave':
          return NasColors.blue;

        default:
          return NasColors.orange;
      }
    } catch (_) {
      return NasColors.darkBlue;
    }
  }

  String formatMinutes(dynamic minutes) {
    if (minutes == null) return '---';
    try {
      double roundedMinutes = (minutes is int)
          ? minutes.toDouble()
          : double.parse(minutes.toString());
      return roundedMinutes.ceil().toString();
    } catch (e) {
      return '---';
    }
  }

  /// Minutes hours method
  String formatMinutesToHoursAndMinutes(
      BuildContext context, int totalMinutes) {
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final String hoursLabel = AppLocalizations.of(context)!.h;
    final String minutesLabel = AppLocalizations.of(context)!.m;

    return "$hours $hoursLabel $minutes $minutesLabel";
  }

  Future<void> checkIn(String type) async {
    final timeZoneIdentifier = await LocalePlus().getTimeZoneIdentifier();
    String? empId = singletonClass.getJWTModel()?.empId;
    String sn = empId?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String deviceIp = await _getLocalIpAddress();
    String? timeZoneName = timeZoneIdentifier;
    print(currentTime);

    Map<String, dynamic> data = {
      "deviceUserId": "$empId",
      "sn": sn,
      "timestamp": currentTime,
      "status": 1,
      "verify_type": 0,
      "deviceIp": deviceIp,
      "deviceName": "Remote",
      "captureTime": currentTime,
      "timeZone": timeZoneName
    };
    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/zk-teco/zktecoClient');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 201) {
        setState(() {
          _dragPosition = 0;
          _isSliderCompleted = true;
          singletonClass.getClockingData();
        });
        await singletonClass.getClockingData();
        await singletonClass.getEmployeeAttendanceData();
        print("<><><>${response.body}");
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: AppLocalizations.of(context)!.success,
          text: AppLocalizations.of(context)!.success,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        setState(() {
          calculateTodayWorkedTime();
          singletonClass.getEmployeeAttendanceData();
        });
      } else if (response.statusCode == 400) {
        // Show error alert for status code 400
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Validation failed. Please check your inputs.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else {
        // Handle other error statuses
        print('Error: ${response.statusCode}');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'An unexpected error occurred. Please try again.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');

      // Show error alert for exceptions
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred. Please check your network connection.',
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
    }
  }
  ///get time zone
  Future<String> _getLocalIpAddress() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.isLoopback &&
            addr.address.startsWith('192.168')) {
          return addr.address;
        }
      }
    }
    return 'Unknown';
  }

  ///Update CALL
  void updateRemoteLocation() async {
    String? employeeID = singletonClass.getJWTModel()?.employeeId;
    String url = '${singletonClass.baseURL}/employee/updateEMPLocation/$employeeID';
    String finalLocation = _openLocation ?? "0.0,0.0";
    Map<String, dynamic> data = {"lastLocation": finalLocation};
    String jsonData = jsonEncode(data);
    log("remote Location Json$jsonData");
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      if (kDebugMode) {
        print("send remote loc:${response.body}");
      }
      final decodedResponse = json.decode(response.body);
      if (response.statusCode == 200 && decodedResponse['statusCode'] == 200) {
      } else {}
    } catch (error) {
      if (kDebugMode) {
        print('Failed to send data. Error: $error');
      }
    }
  }

  /// Current Location
  Future<String> getCurrentLatLong() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return '0.0,0.0';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return '0.0,0.0';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return '0.0,0.0';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final distance = Geolocator.distanceBetween(
      _companyLatitude!,
      _companyLongitude!,
      position.latitude,
      position.longitude,
    );
    final dataList = singletonClass.attendanceDataList.first.data!.data ?? [];
    final today = DateTime.now();
    final todayEntries = dataList.where((entry) {
      final createdAt = DateTime.tryParse(entry.createdAt ?? '');
      return createdAt != null && createdAt.year == today.year && createdAt.month == today.month && createdAt.day == today.day;
    }).toList();
    final todayData = todayEntries.isNotEmpty ? todayEntries.last : null;
    String? checkInTime = todayData?.clockInTime;
    String? checkOutTime = todayData?.clockOutTime;
    if(singletonClass.remoteAttendanceModelList.first.data!.first.isRemoteAttendance == true && (checkInTime != null || checkInTime!.isNotEmpty) &&
        (checkOutTime == null || checkOutTime.isEmpty)){
      if (distance > allowedRadius) {
        checkIn("biometric");
      }
    }
    return '${position.latitude}|${position.longitude}';
  }

  ///test case
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    const accessToken =
        "pk.eyJ1IjoibmFzdGVjc29sIiwiYSI6ImNtMm9qc3lzMTBnamMya3F6cmJsbWZ5MmsifQ.ExjMBEpuTJDstkVQTPeJTA";
    final url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$accessToken";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log("address response :${response.body}");
      if (data["features"] != null && data["features"].isNotEmpty) {
        return data["features"][0]["place_name"];
      }
    }
    return null;
  }
}
