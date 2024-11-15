import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/check_in_model.dart';
import 'package:nashr/screens/assets_screen.dart';
import 'package:nashr/screens/complaints.dart';
import 'package:nashr/screens/document_screen.dart';
import 'package:nashr/screens/my_clocking_screen.dart';
import 'package:nashr/screens/notifications_screen.dart';
import 'package:nashr/screens/penalty_and_fine_screen.dart';
import 'package:nashr/screens/setting_screen.dart';
import 'package:nashr/screens/team_clocking.dart';
import 'package:nashr/screens/team_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UTILS/auth_services.dart';
import '../widgets/colors.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'onsite_checkin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  SingletonClass singletonClass = SingletonClass();
  final List<ActivityModel> activity = [
    ActivityModel("Late Comings", "08-07-2024", "9:00 PM", "late"),
    ActivityModel(
        "Leave Request", "08-07-2024", "Going on Vocations", "Approved"),
    ActivityModel("Salary Increment", "08-07-2024", "Salary Wadhao", "Pending"),
  ];
  double blurAmount = 10.0;
  double opacityAmount = 1.0;
  bool showHeaderContent = true;
  bool isExpanded = true;
  bool isLoading = false;
  double _dragPosition = 0.0;
  bool _isSliderCompleted = false;
  bool _isCheckInCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCheckInState();
    singletonClass.getEmployeeAttendanceData();
    _draggableScrollableController.addListener(() {
      setState(() {
        isExpanded = _draggableScrollableController.size > 0.3;
        showHeaderContent = isExpanded;
        blurAmount = isExpanded ? 10.0 : 0.0;
      });
    });
  }

  // Load state from SharedPreferences
  Future<void> _loadCheckInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCheckInCompleted = prefs.getBool('isCheckInCompleted') ?? false;
    });
  }

  // Save state to SharedPreferences
  Future<void> _saveCheckInState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckInCompleted', _isCheckInCompleted);
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
            color: Colors.grey.withOpacity(0.8), // Set the opacity
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
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const OnsiteCheckin()));
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
                        return; // Skip further actions if biometrics aren't set up
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

  OverlayEntry _createViewAllOverlay(){
    return OverlayEntry (
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
                color: Colors.grey.withOpacity(0.8),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _removeOverlay();
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const TeamClocking()));
                                      },
                                      child: Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child:  Image.asset(
                                            'images/teamClocking.png',
                                            fit: BoxFit.contain,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Add spacing between image and text
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
                              const SizedBox(height: 20),
                              if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                Column(
                                  children: [
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
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0, 0), // changes position of shadow
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
                                    // Add spacing between image and text
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
                              const SizedBox(height: 20),
                              if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                Column(
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
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child:  Image.asset(
                                            'images/assets.png',
                                            fit: BoxFit.contain,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Add spacing between image and text
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
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
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
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child:  Image.asset(
                                            'images/Team.png',
                                            fit: BoxFit.contain,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Add spacing between image and text
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
                              const SizedBox(height: 20),
                              if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _removeOverlay();
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const Complaints()));
                                      },
                                      child: Container(
                                        height: 65,
                                        width: 65,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 0.5,
                                              offset: const Offset(0, 0), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child:  Image.asset(
                                            'images/Complain.png',
                                            fit: BoxFit.contain,
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // Add spacing between image and text
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
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _removeOverlay();
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> const PenaltyAndFineScreen()));
                                    },
                                    child: Container(
                                      height: 65,
                                      width: 65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 0.5,
                                            offset: const Offset(0, 0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child:  Image.asset(
                                          'images/Penalties.png',
                                          fit: BoxFit.contain,
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Add spacing between image and text
                                  Text(
                                    'Penalties',
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

                      ],
                    ),
                  ),
                ),
              ),
            ))
    );
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration:  BoxDecoration(
            image:   DecorationImage(
                image: dashBoardData?.profilePic != null
                    ? NetworkImage(dashBoardData!.profilePic!) // Network image
                    : const AssetImage('images/DP.png') as ImageProvider,
              fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAmount,
                sigmaY: blurAmount,
              ), // Blur effect
              child: Container(
                color: Colors.black
                    .withOpacity(opacityAmount * 0.1), // Slight dark overlay
              ),
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
                                dashBoardData?.profilePic ?? '', // URL for the network image, empty string if null
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
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
                              'Contract ID #${dashBoardData?.contractInfo?.first.contractId}',
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>
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
                                  // Adjust opacity for the glow effect
                                  spreadRadius: 5,
                                  // Spread the shadow to create a glow effect
                                  blurRadius:
                                      10, // Blur radius to make the glow smooth
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_none_outlined,
                              color: Colors.black,
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
                                  color: Colors.white.withOpacity(0.6),
                                  // Adjust opacity for the glow effect
                                  spreadRadius: 5,
                                  // Spread the shadow to create a glow effect
                                  blurRadius:
                                      10, // Blur radius to make the glow smooth
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Colors.black,
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
                                  color: Colors.white.withOpacity(0.6),
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
                            color: Colors.white.withOpacity(0.6),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.0, // Move to right 10 horizontally
                          -10.0, // Move to bottom 10 vertically
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
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5, top: 10 , bottom: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Transform(
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                // Flip horizontally
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.exit_to_app_outlined,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .checkIn,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  singletonClass.attendanceDataList.first.data!.last.clockInTime?.isNotEmpty ?? false
                                                      ? '${singletonClass.attendanceDataList.first.data!.last.clockInTime}'
                                                      : 'NA',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.exit_to_app_outlined,
                                                size: 25,
                                                color: Colors.black,
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .checkOut,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  singletonClass.attendanceDataList.first.data!.last.clockOutTime?.isNotEmpty ?? false
                                                      ? '${singletonClass.attendanceDataList.first.data!.last.clockOutTime}'
                                                      : 'NA',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Check if there are late minutes
                                              if ((singletonClass.attendanceDataList.first.data!.last.lateMinutes ?? 0) > 0)
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(context)!.lateComings,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${singletonClass.attendanceDataList.first.data!.last.lateMinutes}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              // If early check-out exists and no late minutes, show early check-out
                                              else if ((singletonClass.attendanceDataList.first.data!.last.earlyCheckOut ?? 0) > 0)
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(context)!.earlyCheckOut,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${singletonClass.attendanceDataList.first.data!.last.earlyCheckOut}',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              // If both lateMinutes and earlyCheckOut are unavailable, show "Late Comings" with "NA"
                                              else
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(context)!.lateComings,
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          'NA',
                                                          style: GoogleFonts.inter(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 5),
                                              // Display total hours worked
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${AppLocalizations.of(context)!.worked} ${singletonClass.attendanceDataList.first.data!.last.totalHoursWorked?.toString() ?? 'NA'}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.normal,
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
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 130, // Adjust the width if necessary
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // Center the content vertically
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      // Center the content horizontally
                                      children: [
                                        const Icon(
                                          Icons.coffee,
                                          size: 25,
                                          // Adjust the size of the icon if needed
                                          color: Colors
                                              .brown, // Change the color of the icon if needed
                                        ),
                                        const SizedBox(height: 8),
                                        // Space between icon and text
                                        Text(
                                          AppLocalizations.of(context)!.breaks,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Space between text items
                                        Text(
                                          '${singletonClass.attendanceDataList.first.data!.last.breakTime}',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                      if (!_isCheckInCompleted) {
                                        _dragPosition += details.primaryDelta!;
                                        // Check if the swipe has crossed 70% of screen width
                                        if (_dragPosition >
                                            MediaQuery.of(context).size.width *
                                                0.7) {
                                          _isSliderCompleted = true;
                                        }
                                      } else if (_isCheckInCompleted) {
                                        _dragPosition += details.primaryDelta!;
                                        // Check if the swipe has crossed -70% of screen width for check-out
                                        if (_dragPosition <
                                            -MediaQuery.of(context).size.width *
                                                0.7) {
                                          _isSliderCompleted = true;
                                        }
                                      }
                                    });
                                  },
                                  onHorizontalDragEnd: (details) {
                                    if (!_isCheckInCompleted) {
                                      if (_isSliderCompleted &&
                                          details.velocity.pixelsPerSecond.dx >
                                              0) {
                                        // Swiped from left to right and check-in is not completed
                                        _overlayEntry = _createOverlayEntry();
                                        Overlay.of(context)
                                            .insert(_overlayEntry!);
                                        setState(() {
                                          _dragPosition =
                                              0; // Reset to start position
                                          _isSliderCompleted = false;
                                        });
                                      } else {
                                        // Reset if swipe didn't meet the criteria for check-in
                                        setState(() {
                                          _dragPosition = 0;
                                          _isSliderCompleted = false;
                                        });
                                      }
                                    } else if (_isCheckInCompleted) {
                                      if (_isSliderCompleted &&
                                          details.velocity.pixelsPerSecond.dx <
                                              0) {
                                      } else {
                                        // Reset if swipe didn't meet the criteria for check-out
                                        setState(() {
                                          _dragPosition = 0;
                                          _isSliderCompleted = false;
                                        });
                                      }
                                    }
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
                                    child: _isCheckInCompleted
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, left: 30),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    if (_isCheckInCompleted) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) => AlertDialog(
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              const Icon(Icons.warning, color: Colors.yellow),
                                                              Text(AppLocalizations.of(context)!.areYouSure,
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () => Navigator.of(context).pop(),
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      const Icon(Icons.cancel, color: Colors.red), // Icon
                                                                      const SizedBox(width: 5),
                                                                      Text(
                                                                        AppLocalizations.of(context)!.cancel,
                                                                        style: GoogleFonts.inter(
                                                                          fontSize: 15,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.red,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    Navigator.pop(context);
                                                                    await checkOut();
                                                                  },
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      const Icon(Icons.logout, color: Colors.black),
                                                                      const SizedBox(width: 5),
                                                                      Text(
                                                                        AppLocalizations.of(context)!.yes,
                                                                        style: GoogleFonts.inter(
                                                                          fontSize: 15,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.black,
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
                                                    }
                                                  },
                                                  icon: SizedBox(
                                                    width: 35,
                                                    // Set width of the icon
                                                    height: 35,
                                                    // Set height of the icon
                                                    child: Image.asset(
                                                        'images/exit.png'),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    AppLocalizations.of(context)!.pressButtonToCheckOut,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Transform.translate(
                                            offset: Offset(_dragPosition, -1),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 50,
                                                    decoration:
                                                        const BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Lottie.asset(
                                                        'images/swiper.json'),
                                                  ),
                                                  const SizedBox(width: 50),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .swipeToCheckIn,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                            ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(onPressed: (){
                                _overlayEntry2 = _createViewAllOverlay();
                                Overlay.of(context)
                                    .insert(_overlayEntry2!);
                              }, child: Text(AppLocalizations.of(context)!.viewAll,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w600,
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
                                  if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const TeamClocking()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child:  Image.asset(
                                                  'images/teamClocking.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Add spacing between image and text
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
                                  if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
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
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0), // changes position of shadow
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
                                        // Add spacing between image and text
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
                                  if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
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
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child:  Image.asset(
                                                  'images/assets.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Add spacing between image and text
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
                                  if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
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
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child:  Image.asset(
                                                  'images/Team.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Add spacing between image and text
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
                                  if (singletonClass.getJWTModel()?.grade == 'L2' ||singletonClass.getJWTModel()?.grade == 'L3' || singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Complaints()));
                                          },
                                          child: Container(
                                            height: 65,
                                            width: 65,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 0.5,
                                                  offset: const Offset(0, 0), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child:  Image.asset(
                                                  'images/Complain.png',
                                                  fit: BoxFit.contain,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        // Add spacing between image and text
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
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> const PenaltyAndFineScreen()));
                                        },
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 0.5,
                                                offset: const Offset(0, 0), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child:  Image.asset(
                                              'images/Penalties.png',
                                              fit: BoxFit.contain,
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                       'Penalties',
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
                                    color: Colors.grey.withOpacity(0.5),
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
                                              .activity,
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      height: 105,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(5),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: singletonClass.notificationModelList.first.data!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final activities = singletonClass.notificationModelList.first.data![index];

                                          return SizedBox(
                                              width: 180,
                                              // Explicit width for horizontal items
                                              child: Container(
                                                margin: const EdgeInsets.only(right: 10),
                                                height: 100,
                                                // Adjust this as needed
                                                decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 0),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(
                                                        '${activities.notificationType}',
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                          color: Colors.grey
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Text(
                                                        singletonClass.formatTime("${activities.createdAt}"),
                                                        style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    // Add this to push the status Container to the bottom
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.only(left: 10.0 , right: 4 , top: 4 , bottom: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getColorForActivity(activities.status!),
                                                        borderRadius: const BorderRadius.only(
                                                          bottomLeft: Radius.circular(15),
                                                          bottomRight: Radius.circular(15),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "${activities.status}",
                                                            style:
                                                                GoogleFonts.inter(
                                                              color: Colors.white,
                                                                  fontSize: 13,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            singletonClass.formatDate2("${activities.createdAt}"),
                                                            style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 13,
                                                              color: Colors.white
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForActivity(String status) {
    switch (status) {
      case 'late':
        return Colors.red;
      case 'approved':
        return Colors.green;
      case 'pending':
        return NasColors.pending;
      default:
        return Colors.grey; // or any other default color
    }
  }


  Future<void> checkIn(String type) async {
    String checkInTime = DateTime.now().toIso8601String();
    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkInTime": checkInTime,
      "type": type,
      "totalTime" : "$checkInTime",
      // Adjust this if needed for total time calculation
    };
    print(data);

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/c-emp-check-in-out/create');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      setState(() {
        isLoading = false;
      });
      print(response.body);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        var checkInData = CheckInData.fromJson(decodedResponse);
        singletonClass.setCheckInData([checkInData]);
        print(singletonClass.checkInDataList.first.data?.id);
        setState(() {
          _isCheckInCompleted = true; // Reset the check-in state
          _dragPosition = 0; // Reset drag position
          _isSliderCompleted = true; // Reset slider completion flag
        });
        await _saveCheckInState();
        // Show success alert
         await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title:  AppLocalizations.of(context)!.success,
          text: AppLocalizations.of(context)!.checkInComplete,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
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
    String checkOutTime = DateTime.now().toIso8601String();
    String? checkInTime = singletonClass.checkInDataList.first.data?.checkInTime;
    DateTime checkInDateTime = DateTime.parse(checkInTime!);
    DateTime checkOutDateTime = DateTime.parse(checkOutTime);
    Duration difference = checkOutDateTime.difference(checkInDateTime);
    String totalHours = "${difference.inHours}h ${difference.inMinutes.remainder(60)}m";
    print(totalHours);
    String? id = singletonClass.checkInDataList.first.data?.id;
    Map<String, dynamic> data = {
      "employeeId": singletonClass.getJWTModel()?.employeeId,
      "employeeName": singletonClass.getJWTModel()?.userName,
      "checkOutTime": checkOutTime,
      "type": singletonClass.checkInDataList.first.data?.type,
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
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      setState(() {
        isLoading = false;
      });
      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isCheckInCompleted = false; // Reset the check-in state
          _dragPosition = 0; // Reset drag position
          _isSliderCompleted = false; // Reset slider completion flag
        });
        await _saveCheckInState();
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
}

class ActivityModel {
  String? activityName;
  String? date;
  String? time;
  String? status;

  ActivityModel(this.activityName, this.date, this.time, this.status);
}
