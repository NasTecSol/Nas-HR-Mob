import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';
import 'dart:math' as math;
class MyClockingScreen extends StatefulWidget {
  const MyClockingScreen({super.key});

  @override
  State<MyClockingScreen> createState() => _MyClockingScreenState();
}

class _MyClockingScreenState extends State<MyClockingScreen> {
  final List<MyClockingModel> clocks = [
    MyClockingModel("July 20 2024", "-30 min late", "9:35:40 AM", "5:10:20 PM"),
    MyClockingModel(
        "July 21 2024", "Early Check Out", "9:01:26 AM", "5:00:10 PM"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                    child: Text(
                      "My Clocking",
                      style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: NasColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // Add your onPressed functionality here
                      },
                      child: SizedBox(
                        height: 30,
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.filter_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Filter",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                  padding: const EdgeInsets.all(5),
                  shrinkWrap: true,
                  itemCount: clocks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final clock = clocks[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 120,
                            width: 20, // Adjusted the width for visibility
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              color: NasColors.darkBlue,
                            ),
                          ),
                          Expanded(child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${clock.date}",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${clock.checkIn}",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        color: NasColors.darkBlue,
                                      ),
                                      child: Transform(
                                        transform: Matrix4.rotationY(
                                            math.pi), // Flip horizontally
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.exit_to_app_outlined,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${clock.checkOut}",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        color: NasColors.darkBlue,
                                      ),
                                      child: const Icon(
                                        Icons.exit_to_app_outlined,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ]),
    );
  }
}

class MyClockingModel {
  String? date;
  String? status;
  String? checkIn;
  String? checkOut;

  MyClockingModel(this.date, this.status, this.checkIn, this.checkOut);
}
