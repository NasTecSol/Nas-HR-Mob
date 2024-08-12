import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/assets_screen.dart';
import 'package:nashr/screens/document_screen.dart';
import 'package:nashr/screens/payroll_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/screens/team_screen.dart';
import '../widgets/colors.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ActivityModel> activity = [
    ActivityModel("Late Comings", "08-07-2024", "9:00 PM", "late"),
    ActivityModel("Leave Request", "08-07-2024", "Going on Vocations", "Approved"),
    ActivityModel("Salary Increment", "08-07-2024", "Salary Wadhao", "Pending"),
  ];
  double blurAmount = 10.0;
  double opacityAmount = 1.0;
  bool showHeaderContent = true;

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
                color: Colors.black.withOpacity(opacityAmount * 0.1), // Slight dark overlay
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12 ,top: 50 , left: 20),
                  child: AnimatedOpacity(
                    opacity: showHeaderContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProfileScreen()));
                      },
                      child: ClipOval(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          child: Image.asset(
                            'images/DP.jpg', fit: BoxFit.fill,
                            height: 200,
                            width: 200,
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
                            width: 200,
                            child: Text(
                              'Ali Rana #06',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              'UI/UX Designer',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              'Contract ID #2039232',
                              style: GoogleFonts.inter(
                                fontSize: 20,
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
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 35.0 , top: 35),
                  child: AnimatedOpacity(
                    opacity: showHeaderContent ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                          },
                          icon: Container(
                            height: 45,
                            width: 45,
                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6), // Adjust opacity for the glow effect
                                  spreadRadius: 5, // Spread the shadow to create a glow effect
                                  blurRadius: 10,  // Blur radius to make the glow smooth
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
                          },
                          icon: Container(
                            height: 45,
                            width: 45,
                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6), // Adjust opacity for the glow effect
                                  spreadRadius: 5, // Spread the shadow to create a glow effect
                                  blurRadius: 10,  // Blur radius to make the glow smooth
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
                          },
                          icon: Container(
                            height: 45,
                            width: 45,
                            decoration:  BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6), // Adjust opacity for the glow effect
                                  spreadRadius: 5, // Spread the shadow to create a glow effect
                                  blurRadius: 10,  // Blur radius to make the glow smooth
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
              ),
            ],
          ),
          Listener(
            onPointerMove: (PointerMoveEvent event) {
              setState(() {
                if (event.delta.dy > 0) {
                  // Dragging down
                  blurAmount = 0.0;
                  showHeaderContent = false;
                } else if (event.delta.dy < 0) {
                  // Dragging up
                  blurAmount = 10.0;
                  showHeaderContent = true;
                }
              });
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              // The initial height of the bottom sheet
              minChildSize: 0.2,
              // The minimum height of the bottom sheet
              maxChildSize: 0.7,
              expand: true,
              builder: (BuildContext context, ScrollController scrollController) {
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
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(15)),
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
                                          offset: const Offset(
                                              0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15, top: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Check-in',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              Transform(
                                                transform: Matrix4.rotationY(
                                                    math.pi), // Flip horizontally
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.exit_to_app_outlined,
                                                  size: 25,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '9:30:40 AM',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
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
                                                  color: NasColors.red,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    "-30 min Late",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red,
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
                                          offset: const Offset(
                                              0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15, top: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Check-Out',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.exit_to_app_outlined,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '4:30:52 AM',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.normal,
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
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const DocumentScreen()));
                                      },
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
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
                                        child: Center(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'images/files.png',
                                              fit: BoxFit.contain,
                                              width: 50,
                                              height: 50,
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
                                        fontSize: 15,
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
                                      onTap:( ) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const AssetsScreen()));
                      },
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
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
                                        child: Center(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'images/assets.png',
                                              fit: BoxFit.contain,
                                              width: 50,
                                              height: 50,
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
                                        fontSize: 15,
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
                                      onTap:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const PayrollScreen()));
                                      },
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
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
                                        child: Center(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'images/creditCard.png',
                                              fit: BoxFit.contain,
                                              width: 50,
                                              height: 50,
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
                                        fontSize: 15,
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
                                      onTap:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const TeamScreen()));
                                      },
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
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
                                        child: Center(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'images/Team.png',
                                              fit: BoxFit.contain,
                                              width: 50,
                                              height: 50,
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                    const SizedBox(height: 30),
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
                                                borderRadius: const BorderRadius.all(
                                                    Radius.circular(15)),
                                                color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3), // changes position of shadow
                                                    ),
                                                  ]
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(8.0),
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
                                                      padding: const EdgeInsets.all(
                                                              4.0),
                                                      decoration: BoxDecoration(
                                                        color: _getColorForActivity(activities.status!),
                                                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                                                      ),
                                                      child: Text(
                                                        "${activities.status}",
                                                        style:
                                                            GoogleFonts.inter(
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
