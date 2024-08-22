import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/assets_screen.dart';
import 'package:nashr/screens/document_screen.dart';
import 'package:nashr/screens/loan_screen.dart';
import 'package:nashr/screens/my_clocking_screen.dart';
import 'package:nashr/screens/payroll_screen.dart';
import 'package:nashr/screens/team_screen.dart';
import '../UTILS/auth_services.dart';
import '../widgets/colors.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
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
  double _dragPosition = 0.0;
  bool _isSliderCompleted = false;
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
          onTap: (){
            _removeOverlay();
          },
          child: Material(
            color: Colors.grey.withOpacity(0.8), // Set the opacity
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Clock-In Type',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 90,
                      width: 90,
                      decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset("images/site.png",

                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Office Check-In',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset("images/pc.png",

                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Remote Check-In',
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
                        // Show a message asking the user to set up biometric credentials
                        _removeOverlay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please set up biometrics in your device settings')),
                        );
                        return; // Skip further actions if biometrics aren't set up
                      }

                      // If biometrics are available, proceed with authentication
                      bool isAuthenticated = await _authService.authenticateWithBiometrics(context);
                      if (isAuthenticated) {
                        // Proceed to the next screen or perform the desired action
                        _removeOverlay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Authenticated')),
                        );
                      } else {
                        // Show an error message if authentication failed
                        _removeOverlay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Authentication failed')),
                        );
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
                        child: Image.asset("images/fingerprint.png",

                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Biometric Check-In',
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

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    _draggableScrollableController.addListener(() {
      setState(() {
        isExpanded = _draggableScrollableController.size > 0.3;
        showHeaderContent = isExpanded;
        blurAmount = isExpanded ? 10.0 : 0.0;
      });
    });
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/DP.jpg'),
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
                            child: Image.asset(
                              'images/DP.jpg',
                              fit: BoxFit.fill,
                              height: 150,
                              width: 150,
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
                              'Ali Rana #06',
                              textAlign: TextAlign.left,
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
                              'UI/UX Designer',
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
                              'Contract ID #2039232',
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
                          onPressed: () {},
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
                          onPressed: () {},
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
                                    height: 120,
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
                                          left: 5.0, right: 5, top: 10),
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
                                                  'Check-in',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  '9:30:40 AM',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.normal,
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
                                                  'Check-Out',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2.5),
                                              Expanded(
                                                child: Text(
                                                  '4:30:52 AM',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: NasColors.onTime,
                                                  borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    "Early Check-out",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Worked 6h 1m',
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
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                          "Break",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Space between text items
                                        Text(
                                          "12:00 PM",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          "to",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          "1:00 PM",
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
                            child:GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  _dragPosition += details.primaryDelta!;
                                  if (_dragPosition > MediaQuery.of(context).size.width * 0.7) {
                                    _isSliderCompleted = true;
                                  }
                                });
                              },
                              onHorizontalDragEnd: (details) {
                                if (_isSliderCompleted && details.velocity.pixelsPerSecond.dx > 0) {
                                  // Swiped from left to right
                                  _overlayEntry = _createOverlayEntry();
                                  Overlay.of(context).insert(_overlayEntry!);
                                  setState(() {
                                    _dragPosition = 8; // Move back to the start point
                                    _isSliderCompleted = false;
                                  });
                                } else {
                                  setState(() {
                                    _dragPosition = 8; // Reset to the start point
                                    _isSliderCompleted = false;
                                  });
                                }
                              },
                              child: Container(
                                alignment: Alignment.topLeft,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  color: Colors.white,
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
                                child: Transform.translate(
                                  offset: Offset(_dragPosition, -1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Container(
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
                                          child: Text (
                                            "Swipe to Check-In",
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
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/files.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                        "Documents",
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
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/assets.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                        "Assets",
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoanScreen()));
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
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/loan.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                        "Loans",
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
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/Team.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                        "Teams",
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
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const PayrollScreen()));
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
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'images/creditCard.png',
                                                fit: BoxFit.contain,
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Add spacing between image and text
                                      Text(
                                        "Salary",
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
                                          "Activity",
                                          style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 137,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(5),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: activity.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final activities = activity[index];
                                          return SizedBox(
                                            width: 200,
                                            // Explicit width for horizontal items
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              // Add spacing between items
                                              height: 100,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15)),
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 8,
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ]),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '${activities.activityName}',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                      '${activities.date}',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                      '${activities.time}',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Container(
                                                    width: 200,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _getColorForActivity(
                                                              activities
                                                                  .status!),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              bottomLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                    ),
                                                    child: Text(
                                                      "${activities.status}",
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
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
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.yellow;
      default:
        return Colors.grey; // or any other default color
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
