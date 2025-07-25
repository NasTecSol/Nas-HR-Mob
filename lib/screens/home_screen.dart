import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/check_in_model.dart';
import 'package:nashr/screens/assets_screen.dart';
import 'package:nashr/screens/chat_screen.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/document_screen.dart';
import 'package:nashr/screens/manage_time_screen.dart';
import 'package:nashr/screens/my_clocking_screen.dart';
import 'package:nashr/screens/notifications_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/setting_screen.dart';
import 'package:nashr/screens/team_attendance_screen.dart';
import 'package:nashr/screens/team_clocking.dart';
import 'package:nashr/screens/team_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../UTILS/auth_services.dart';
import '../request_controller/attendance_model.dart';
import '../widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'onsite_checkin.dart';

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
  String? selectedBranchName;
  String? selectedBranchId;
  bool isLoadingBranches = false;
  String? _backgroundLocation;

  @override
  void initState() {
    super.initState();
    _draggableScrollableController.addListener(() {
      setState(() {
        isExpanded = _draggableScrollableController.size > 0.3;
        showHeaderContent = isExpanded;
        blurAmount = isExpanded ? 10.0 : 0.0;
      });
      WidgetsBinding.instance.addObserver(this);
      trackOpenLocation();
    });
    setState(() {});
  }




  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    _backgroundLocation = await getCurrentLatLong();
    updateRemoteLocation();
  }

  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  //Slider
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
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      if (!(await _authService.checkBiometricAvailability())) {
                        _removeOverlay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please set up biometrics in your device settings')),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //2ND OverLay
  OverlayEntry? _overlayEntry2;

  OverlayEntry _createViewAllOverlay() {
    final uiSettings =
        singletonClass.uiSettingsModelDataList.first.data?.mobileModules ?? [];
    final titles = uiSettings.map((e) => e.title?.toString() ?? '').toList();
    final hasDocuments =
        titles.any((title) => title == "Document" || title == "Documents");
    final hasTeams =
        titles.any((title) => title == "teams" || title == "Teams");
    final hasTeamClocking = titles
        .any((title) => title == "teamClockings" || title == "teamClockings");
    final hasAssets =
        titles.any((title) => title == "assets" || title == "Assets");
    final hasTeamAttendance = titles
        .any((title) => title == "teamAttendance" || title == "teamAttendance");
    final hasAttendance =
        titles.any((title) => title == "attendance" || title == "attendance");
    final hasComplaints =
        titles.any((title) => title == "complaints" || title == "complaints");
    final hasPenaltiesAndFines = titles.any((title) =>
        title == "penaltiesAndFines" || title == "penaltiesAndFines");
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
                color: NasColors.darkBlue.withValues(alpha: 0.8),
                child: Container(
                  decoration: BoxDecoration(
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
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.quickActions,
                            style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: NasColors.darkBlue),
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                if (hasDocuments) ...[
                                  GestureDetector(
                                    onTap: () {
                                      _removeOverlay();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DocumentScreen()));
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
                                                .withValues(alpha: 0.5),
                                            spreadRadius: 1,
                                            blurRadius: 0.5,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
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
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    AppLocalizations.of(context)!.documents,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            SizedBox(width: 40),
                            if (hasAssets) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 50.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _removeOverlay();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AssetsScreen()));
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
                                                  .withValues(alpha: 0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0,
                                                  0), // changes position of shadow
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
                              ),
                            ],
                            SizedBox(width: 40),
                            if (hasTeams) ...[
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _removeOverlay();
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
                                                .withValues(alpha: 0.5),
                                            spreadRadius: 1,
                                            blurRadius: 0.5,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
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
                            ],
                          ]),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              if (hasComplaints) ...[
                                GestureDetector(
                                  onTap: () {
                                    _removeOverlay();
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
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 1,
                                          blurRadius: 0.5,
                                          offset: const Offset(0,
                                              0), // changes position of shadow
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
                                  AppLocalizations.of(context)!.complaints,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ]
                            ],
                          ),
                          SizedBox(width: 40),
                          if (hasPenaltiesAndFines) ...[
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _removeOverlay();
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
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 1,
                                          blurRadius: 0.5,
                                          offset: const Offset(0,
                                              0), // changes position of shadow
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
                                  AppLocalizations.of(context)!.penalties,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(width: 40),
                          if (hasAttendance) ...[
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _removeOverlay();
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
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 1,
                                          blurRadius: 0.5,
                                          offset: const Offset(0,
                                              0), // changes position of shadow
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
                                  AppLocalizations.of(context)!.attendance,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 40),
                      if (hasTeamAttendance && hasTeamClocking) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _removeOverlay();
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
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 1,
                                          blurRadius: 0.5,
                                          offset: const Offset(0,
                                              0), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'images/teamClocking.png',
                                        fit: BoxFit.contain,
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  AppLocalizations.of(context)!.teamClocking,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 30),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _removeOverlay();
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
                                              .withValues(alpha: 0.5),
                                          spreadRadius: 1,
                                          blurRadius: 0.5,
                                          offset: const Offset(0,
                                              0), // changes position of shadow
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
                                  AppLocalizations.of(context)!.manageTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ]
                    ],
                  )),
                ),
              ),
            )));
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

  @override
  Widget build(BuildContext context) {
    final dashBoardData = singletonClass.employeeDataList.first.data;
    final uiSettings =
        singletonClass.uiSettingsModelDataList.first.data?.mobileModules ?? [];

    final hasDocuments =
        uiSettings.any((e) => e.title == "Document" || e.title == "Documents");
    final hasTeams =
        uiSettings.any((e) => e.title == "teams" || e.title == "Teams");
    final hasTeamClocking = uiSettings.any((e) => e.title == "teamClockings");
    final hasAssets =
        uiSettings.any((e) => e.title == "assets" || e.title == "Assets");
    final hasComplaints = uiSettings.any((e) => e.title == "complaints");
    final hasPenaltiesAndFines =
        uiSettings.any((e) => e.title == "penaltiesAndFines");
    final hasChatBot =
        uiSettings.any((e) => e.title == "chatBot" && e.hidden == false);
    final hasNotChatBot =
        uiSettings.any((e) => e.title == "chatBot" && e.hidden == true);
    final chatBotNotAvailable = !uiSettings.any((e) => e.title == "chatBot");
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: const BoxDecoration(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                dashBoardData?.profilePic != null &&
                        dashBoardData!.profilePic!.isNotEmpty
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
                        child: ClipOval(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: ClipOval(
                              child: Image.network(
                                dashBoardData?.profilePic ?? '',
                                // URL for the network image, empty string if null
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  // Display the default asset image if the network image fails to load
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
                        ),
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
                              'Contract ID #${(dashBoardData?.contractInfo?.isNotEmpty ?? false) ? dashBoardData!.contractInfo!.first.contractId : 'N/A'}',
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
                                        const NotificationsScreen()));
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
                                  // Adjust opacity for the glow effect
                                  spreadRadius: 5,
                                  // Spread the shadow to create a glow effect
                                  blurRadius:
                                      10, // Blur radius to make the glow smooth
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(9.0),
                              // optional padding
                              child: Image.asset(
                                'images/clocking.png',
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
                                  color: Colors.white.withValues(alpha: 0.6),
                                  // Adjust opacity for the glow effect
                                  spreadRadius: 5,
                                  // Spread the shadow to create a glow effect
                                  blurRadius:
                                      10, // Blur radius to make the glow smooth
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                          ),
                        ),
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
                            // Adjust opacity for the glow effect
                            spreadRadius: 5,
                            // Spread the shadow to create a glow effect
                            blurRadius:
                                10, // Blur radius to make the glow smooth
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
              initialChildSize: isExpanded ? 0.65 : 0.2,
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
                          if(singletonClass.getJWTModel()?.grade == "L0" || singletonClass.getJWTModel()?.grade == "L1" || singletonClass.getJWTModel()?.grade == "L2")
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  /// Company Dropdown
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                              Image.asset('images/site.png', width: 15, height: 15),
                                              const SizedBox(width: 8),
                                              Text(
                                                singletonClass.companyDataList.isNotEmpty &&
                                                    singletonClass.companyDataList.first.data?.name != null
                                                    ? "${singletonClass.companyDataList.first.data!.name}"
                                                    : AppLocalizations.of(context)!.select,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          items: singletonClass.companiesDataList.isNotEmpty
                                              ? singletonClass.companiesDataList.first.data?.companies
                                              ?.map<DropdownMenuItem<String>>((company) {
                                            return DropdownMenuItem<String>(
                                              value: company.companyId.toString(),
                                              child: Text(company.companyName ?? "No Name"),
                                            );
                                          }).toList()
                                              : [],
                                          onChanged: (value) async {
                                            setState(() {
                                              selectedCompanyId = value;
                                              singletonClass.selectedCompanyId = selectedCompanyId;
                                              selectedBranchId = null;
                                              isLoadingBranches = true;
                                              singletonClass.branchID = null;
                                              singletonClass.branchesDataList.clear();
                                            });

                                            await singletonClass.getBranchesData();

                                            setState(() {
                                              isLoadingBranches = false;
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                                ? AppLocalizations.of(context)!.loading
                                                : AppLocalizations.of(context)!.selectBranch,
                                          ),
                                          items: !isLoadingBranches &&
                                              singletonClass.branchesDataList.isNotEmpty
                                              ? singletonClass.branchesDataList.first.data
                                              ?.map<DropdownMenuItem<String>>((branch) {
                                            return DropdownMenuItem<String>(
                                              value: branch.id.toString(),
                                              child: Text(branch.branchName ?? "No Name"),
                                            );
                                          }).toList()
                                              : [],
                                          onChanged: isLoadingBranches
                                              ? null
                                              : (value) {
                                            setState(() {
                                              selectedBranchId = value;
                                              singletonClass.branchID = selectedBranchId;
                                              final selectedBranch = singletonClass.branchesDataList.first.data!
                                                  .firstWhere((branch) => branch.id.toString() == selectedBranchId);
                                              singletonClass.branchName = selectedBranch.branchName ?? '';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
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
                                        if (singletonClass.attendanceDataList.isNotEmpty &&
                                            singletonClass.attendanceDataList.first.data != null &&
                                            singletonClass.attendanceDataList.first.data!.data != null &&
                                            singletonClass.attendanceDataList.first.data!.data!.isNotEmpty &&
                                            singletonClass.attendanceDataList.first.data!.data!.first.clockInTime != null &&
                                            singletonClass.attendanceDataList.first.data!.data!.first.clockInTime!.isNotEmpty)
                                          Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                color: _getContainerColor(),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (singletonClass.attendanceDataList.isNotEmpty &&
                                                      singletonClass.attendanceDataList.first.data!.data != null &&
                                                      singletonClass.attendanceDataList.first.data!.data!.isNotEmpty)
                                                    Builder(builder: (context) {
                                                      final today = DateTime.now();
                                                      final dataList =
                                                          singletonClass.attendanceDataList.first.data!.data!;
                                                      Data1? entry;
                                                      final filteredList = dataList.where((e) {
                                                        final createdAt = DateTime.tryParse(e.createdAt ?? '');
                                                        return createdAt != null && createdAt.year == today.year && createdAt.month ==
                                                                today.month && createdAt.day == today.day;
                                                      }).toList();
                                                      if (filteredList.isNotEmpty) {
                                                        entry = filteredList.first;
                                                      }
                                                      if (entry == null) {
                                                        return SizedBox();
                                                      }
                                                      if ((entry.lateMinutes ?? 0) > 0) {
                                                        return Text("${AppLocalizations.of(context)!.late} ${entry.lateMinutes}",
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: NasColors.lateComingText,
                                                          ),
                                                        );
                                                      } else if ((entry.earlyCheckOut ?? 0) > 0) {
                                                        return Text(
                                                          "${AppLocalizations.of(context)!.earlyLeft} ${entry.earlyCheckOut}",
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: NasColors.onTime,
                                                          ),
                                                        );
                                                      } else if (entry.clockInTime?.isNotEmpty == true) {
                                                        return Text( AppLocalizations.of(context)!.onTime,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: NasColors.onTime,
                                                          ),
                                                        );
                                                      } else {
                                                        return SizedBox();
                                                      }
                                                    })
                                                  else
                                                    Text(
                                                      AppLocalizations.of(context)!.noData,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                        FontWeight.normal,
                                                      ),
                                                    ),
                                                ],
                                              )),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, left: 15, right: 8, bottom: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                  "images/checkIn.png",
                                                ),
                                              ),
                                              const SizedBox(width: 40),
                                              Expanded(
                                                child: Text(
                                                  () {
                                                    try {
                                                      final today = DateTime.now();
                                                      final dataList = singletonClass.attendanceDataList.first.data!.data;
                                                      if (dataList == null || dataList.isEmpty) {
                                                        return 'NA';
                                                      }

                                                      final entry = dataList.firstWhere((entry) {
                                                        final createdAt = DateTime.tryParse(entry.createdAt ?? '');
                                                        return createdAt !=
                                                                null &&
                                                            createdAt.year ==
                                                                today.year &&
                                                            createdAt.month ==
                                                                today.month &&
                                                            createdAt.day ==
                                                                today.day;
                                                      });

                                                      return entry.clockInTime
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? singletonClass
                                                              .formatCheckInTime(
                                                                  entry
                                                                      .clockInTime!)
                                                          : 'NA';
                                                    } catch (_) {
                                                      return 'NA';
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
                                              top: 5.0, left: 15, right: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                  "images/checkOut.png",
                                                ),
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
                                                              .data!
                                                              .data;
                                                      if (dataList == null ||
                                                          dataList.isEmpty) {
                                                        return 'NA';
                                                      }

                                                      final entry = dataList
                                                          .firstWhere((entry) {
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
                                                      });

                                                      return entry.clockOutTime
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? singletonClass
                                                              .formatCheckInTime(
                                                                  entry
                                                                      .clockOutTime!)
                                                          : 'NA';
                                                    } catch (_) {
                                                      return 'NA';
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
                                                    : 'NA',
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
                                if (hasChatBot)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen()));
                                      },
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
                                            Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
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
                                                    AppLocalizations.of(
                                                            context)!
                                                        .nassMudeer,
                                                    style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                    width: 80,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          "${AppLocalizations.of(context)!.hey} ${singletonClass.employeeDataList.first.data!.firstName} !"),
                                                    )),
                                                SizedBox(
                                                  height: 95,
                                                  width: 95,
                                                  child: Lottie.asset(
                                                      'images/AIMudder.json'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (hasNotChatBot || chatBotNotAvailable)
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
                                        Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
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
                                                width: 100,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    singletonClass
                                                                .attendanceDataList
                                                                .isNotEmpty &&
                                                            singletonClass
                                                                .attendanceDataList
                                                                .first
                                                                .data!
                                                                .data!
                                                                .isNotEmpty
                                                        ? '${AppLocalizations.of(context)!.worked} '
                                                            '${singletonClass.formatMinutes(double.tryParse(singletonClass.attendanceDataList.first.data!.data!.first.totalHoursWorked?.toString() ?? '0')?.round() ?? 0)}'
                                                        : '${AppLocalizations.of(context)!.worked} NA',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                )),
                                            SizedBox(
                                              height: 55,
                                              width: 55,
                                              child: Lottie.asset(
                                                  'images/totalWork.json'),
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
                                    final today = DateTime.now();
                                    final dataList = singletonClass
                                            .attendanceDataList
                                            .first
                                            .data
                                            ?.data ??
                                        [];

                                    Data1? todayData;
                                    for (var entry in dataList) {
                                      final createdAt = DateTime.tryParse(
                                          entry.createdAt ?? '');
                                      if (createdAt != null &&
                                          createdAt.year == today.year &&
                                          createdAt.month == today.month &&
                                          createdAt.day == today.day) {
                                        todayData = entry;
                                        break;
                                      }
                                    }

                                    final checkInTime = todayData?.clockInTime;
                                    final checkOutTime =
                                        todayData?.clockOutTime;

                                    if ((checkInTime == null ||
                                            checkInTime.isEmpty) ||
                                        (checkOutTime != null &&
                                            checkOutTime.isNotEmpty)) {
                                      _dragPosition += details.primaryDelta!;
                                      if (_dragPosition >
                                          MediaQuery.of(context).size.width *
                                              0.7) {
                                        _isSliderCompleted = true;
                                      }
                                    } else if (checkInTime != null &&
                                        checkInTime.isNotEmpty &&
                                        (checkOutTime == null ||
                                            checkOutTime.isEmpty)) {
                                      _dragPosition += details.primaryDelta!;
                                      if (_dragPosition <
                                          -MediaQuery.of(context).size.width *
                                              0.7) {
                                        _isSliderCompleted = true;
                                      }
                                    }
                                  });
                                },
                                onHorizontalDragEnd: (details) {
                                  setState(() {
                                    final today = DateTime.now();
                                    final dataList = singletonClass
                                            .attendanceDataList
                                            .first
                                            .data
                                            ?.data ??
                                        [];

                                    Data1? todayData;
                                    for (var entry in dataList) {
                                      final createdAt = DateTime.tryParse(
                                          entry.createdAt ?? '');
                                      if (createdAt != null &&
                                          createdAt.year == today.year &&
                                          createdAt.month == today.month &&
                                          createdAt.day == today.day) {
                                        todayData = entry;
                                        break;
                                      }
                                    }

                                    final checkInTime = todayData?.clockInTime;
                                    final checkOutTime =
                                        todayData?.clockOutTime;

                                    if ((checkInTime == null ||
                                            checkInTime.isEmpty) ||
                                        (checkOutTime != null &&
                                            checkOutTime.isNotEmpty)) {
                                      if (_isSliderCompleted &&
                                          details.velocity.pixelsPerSecond.dx >
                                              0) {
                                        _overlayEntry = _createOverlayEntry();
                                        Overlay.of(context)
                                            .insert(_overlayEntry!);
                                      }
                                    } else if (checkInTime != null &&
                                        checkInTime.isNotEmpty &&
                                        (checkOutTime == null ||
                                            checkOutTime.isEmpty)) {
                                      if (_isSliderCompleted &&
                                          details.velocity.pixelsPerSecond.dx <
                                              0) {
                                        _overlayEntry = _createOverlayEntry();
                                        Overlay.of(context)
                                            .insert(_overlayEntry!);
                                      }
                                    }

                                    _dragPosition = 0;
                                    _isSliderCompleted = false;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
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
                                    final today = DateTime.now();
                                    final dataList = singletonClass
                                            .attendanceDataList
                                            .first
                                            .data
                                            ?.data ??
                                        [];

                                    Data1? todayData;
                                    for (var entry in dataList) {
                                      final createdAt = DateTime.tryParse(
                                          entry.createdAt ?? '');
                                      if (createdAt != null &&
                                          createdAt.year == today.year &&
                                          createdAt.month == today.month &&
                                          createdAt.day == today.day) {
                                        todayData = entry;
                                        break;
                                      }
                                    }

                                    final checkInTime = todayData?.clockInTime;
                                    final checkOutTime =
                                        todayData?.clockOutTime;

                                    if ((checkInTime != null &&
                                            checkInTime.isNotEmpty) &&
                                        (checkOutTime == null ||
                                            checkOutTime.isEmpty)) {
                                      // Show Check-Out Button
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, left: 30),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          AlertDialog(
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        const Icon(
                                                            Icons.warning,
                                                            color:
                                                                Colors.yellow),
                                                        Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .areYouSure,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          InkWell(
                                                            onTap: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                    Icons
                                                                        .cancel,
                                                                    color: Colors
                                                                        .red),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .cancel,
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          InkWell(
                                                            onTap: () async {
                                                              Navigator.pop(
                                                                  context);
                                                              await checkOut();
                                                            },
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                    Icons
                                                                        .logout,
                                                                    color: Colors
                                                                        .black),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .yes,
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: SizedBox(
                                                width: 35,
                                                height: 35,
                                                child: Image.asset(
                                                    'images/exit.png'),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .pressButtonToCheckOut,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Show Swipe to Check-In UI
                                      return Transform.translate(
                                        offset: Offset(_dragPosition, -1),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 50,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                  color: Colors.white,
                                                ),
                                                child: Lottie.asset(
                                                    'images/swiper.json'),
                                              ),
                                              const SizedBox(width: 50),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .swipeToCheckIn,
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
                                    }
                                  })(),
                                ),
                              ),
                            ),
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
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (hasTeamClocking)
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
                                                'images/teamClocking.png',
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
                                              .teamClocking,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(width: 20),
                                  if (hasDocuments)
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
                                                'images/files.png',
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
                                  if (hasAssets)
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
                                                'images/assets.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
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
                                  if (hasTeams)
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
                                  if (hasComplaints)
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
                                  if (hasPenaltiesAndFines)
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
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
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
                                                      color: NasColors.lightBlue,
                                                      width: 4.0, // Set the border width
                                                    ),
                                                    right: BorderSide(
                                                      color: NasColors.lightBlue,
                                                      width: 2.0, // Set the border width
                                                    ),
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                              width: 110,
                                                              child: Text(
                                                                AppLocalizations.of(context)!.annualLeave,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 13),
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
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "${singletonClass.employeeDataList.first.data!.leaveBalance!.annualLeave!.used}/${singletonClass.employeeDataList.first.data!.leaveBalance!.annualLeave!.entitlement.toStringAsFixed(2)}",
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
                                                            "2/6",
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
                                                                fontWeight: FontWeight.bold),
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
                                                              child: Text( AppLocalizations.of(context)!.shortLeaves,
                                                                style: GoogleFonts.inter(
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 12),
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
                                                                "${singletonClass.employeeDataList.first.data!.leaveBalance!.shortLeavesMonthlyBal!.shortLeavesMinutes} ${AppLocalizations.of(context)!.minutes}",
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
                                                                    .sickDaysThisMonth,
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
          if (isLoading)
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('images/loader.json'),
              ),
            )
        ],
      ),
    );
  }

  Color _getContainerColor() {
    try {
      final today = DateTime.now();
      final dataList = singletonClass.attendanceDataList.first.data!.data;
      if (dataList == null || dataList.isEmpty) {
        return NasColors.darkBlue;
      }
      final entry = dataList.firstWhere(
        (entry) {
          final createdAt = DateTime.tryParse(entry.createdAt ?? '');
          return createdAt != null &&
              createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day;
        },
      );

      if ((entry.lateMinutes ?? 0) > 0) {
        return NasColors.pending.withOpacity(0.25);
      } else if ((entry.earlyCheckOut ?? 0) > 0) {
        return NasColors.onTime;
      } else if (entry.clockInTime?.isNotEmpty == true) {
        return NasColors.onTime.withOpacity(0.25);
      }
    } catch (_) {
      return NasColors.darkBlue;
    }
    return NasColors.darkBlue;
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

  Future<void> checkIn(String type) async {
    String currentTime = DateTime.now().toUtc().toIso8601String();
    String checkInTime = '${currentTime.split('.')[0]}.000Z';
    print(checkInTime);

    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkInTime": checkInTime,
      "type": type,
    };
    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/create');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      print(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        var checkInData = CheckInData.fromJson(decodedResponse);
        singletonClass.setCheckInData([checkInData]);
        print(singletonClass.checkInDataList.first.data?.id);
        setState(() {
          _dragPosition = 0; // Reset drag position
          _isSliderCompleted = true; // Reset slider completion flag
          singletonClass.getClockingData();
        });
        await singletonClass.getClockingData();
        // Show success alert
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: AppLocalizations.of(context)!.success,
          text: AppLocalizations.of(context)!.checkInComplete,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        setState(() {});
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

//CHECK OUT API CALL
  Future<void> checkOut() async {
    String currentTime = DateTime.now().toUtc().toIso8601String();
    String checkOutTime = '${currentTime.split('.')[0]}.000Z';
    String? checkInTime =
        singletonClass.clockingDataList.first.data?.last.checkInTime;
    DateTime checkInDateTime = DateTime.parse(checkInTime!);
    DateTime checkOutDateTime = DateTime.parse(checkOutTime);
    Duration difference = checkOutDateTime.difference(checkInDateTime);
    String totalHours =
        "${difference.inHours}h ${difference.inMinutes.remainder(60)}m";
    print(totalHours);
    String? id = singletonClass.clockingDataList.first.data?.last.id;
    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkOutTime": checkOutTime,
      "type": singletonClass.clockingDataList.first.data?.last.type,
      "totalTime": totalHours,
      // Adjust this if needed for total time calculation
    };
    print(data);

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/$id');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.patch(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );

      setState(() {
        isLoading = false;
      });
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _dragPosition = 0; // Reset drag position
          _isSliderCompleted = false; // Reset slider completion flag
          singletonClass.getClockingData();
        });
        await singletonClass.getClockingData();
        await singletonClass.getClockingData();
        // Show success alert
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: AppLocalizations.of(context)!.success,
          text: AppLocalizations.of(context)!.checkOutComplete,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        setState(() {});
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

  //Update CALL
  void updateRemoteLocation() async {
    String? employeeID = singletonClass.getJWTModel()?.employeeId;
    String url =
        '${singletonClass.baseURL}/employee/updateEMPLocation/$employeeID';

    // Fallbacks if any location is null
    String finalLocation = _openLocation ?? "0.0,0.0";

    Map<String, dynamic> data = {"lastLocation": finalLocation};

    String jsonData = jsonEncode(data);
    log("remote Location Json$jsonData");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );

      setState(() {
        isLoading = false;
      });

      print("send remote loc:${response.body}");
      final decodedResponse = json.decode(response.body);
      if (response.statusCode == 200 && decodedResponse['statusCode'] == 200) {
      } else {}
    } catch (error) {
      print('Failed to send data. Error: $error');
    }
  }

  // Current Location
  Future<String> getCurrentLatLong() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return '0.0,0.0'; // Or handle it differently
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

    return '${position.latitude}|${position.longitude}';
  }
}
