import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // Initialize _tabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose _tabController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0 , left: 20.0, right: 20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "My Profile",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Add your settings action
                        },
                        icon: Container(
                          height: 50,
                          width: 50,
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
                            Icons.settings,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    padding: const EdgeInsets.only(left: 0),
                    dragStartBehavior: DragStartBehavior.start,
                    controller: _tabController,
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 8,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Bank Accounts'),
                      Tab(text: 'Family Info'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Content for Tab 1
              Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [ Column(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            height: 200,
                            width: 400,
                            margin: const EdgeInsets.only(top: 30), // Adjust margin to create space for the overlapping image
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: NasColors.darkBlue,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Suleiman Azeem Khan',
                                      style: GoogleFonts.inter(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'App Developer',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '#1234',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white, // Adjust color as needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Positioned image overlapping the top border of the container
                        Positioned(
                          top: -0, // Adjust position as needed to overlap with container top border
                          left: (MediaQuery.of(context).size.width - 400) / 0.07, // Adjust position as needed horizontally
                          child: Stack(
                            children: [ Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2, // Adjust border width as needed
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'images/DP.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                              Positioned(
                                bottom: -5,
                                right: -5,
                                child: IconButton(
                                  icon: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1
                                      )
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Add functionality for edit action
                                  },
                                  color: Colors.green, // Adjust icon color as needed
                                ),
                              ),
                          ]),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4), // Shadow color with opacity
                              spreadRadius: 5, // Spread radius
                              blurRadius: 10, // Blur radius
                              offset: const Offset(0, 3), // Offset in the x and y directions
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text("Personal Information",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Gender",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Male",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Nationality",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Pakistani",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("BirthDate",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight:FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Aug,20,2002",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Age",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("22",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Martial Status",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Divorce",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Phone no",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("+923057768600",
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Address",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Gulberg Greens Islamabad",
                                  maxLines: 2,
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("Passport No",
                                  style: GoogleFonts.inter(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text("38301-4185203-9",
                                  maxLines: 2,
                                  style: GoogleFonts.inter(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
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
              ]),
            ),
            Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Tab 2 Content'),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Tab 3 Content'),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text('Tab 4 Content'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
