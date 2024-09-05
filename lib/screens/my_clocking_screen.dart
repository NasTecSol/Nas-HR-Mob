import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyClockingScreen extends StatefulWidget {
  const MyClockingScreen({super.key});

  @override
  State<MyClockingScreen> createState() => _MyClockingScreenState();
}

class _MyClockingScreenState extends State<MyClockingScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = true; // Track loading state
  List<Data> filteredClockingData = []; // Corrected type to List<Data>

  @override
  void initState() {
    super.initState();
    _fetchClockingData(); // Fetch data once during initialization
  }

  Future<void> _fetchClockingData() async {
    try {
      await singletonClass.getClockingData();

      String? currentEmployeeId = singletonClass.getJWTModel()?.employeeId;

      if (currentEmployeeId != null) {
        // Filter clocking data by the current employee ID
        filteredClockingData = filterClockingDataByEmployeeId(
          singletonClass.clockingDataList,
          currentEmployeeId,
        );
      }
    } catch (e) {
      // Handle errors if needed
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading once data is fetched
      });
    }
  }

  List<Data> filterClockingDataByEmployeeId(List<ClockingData> clockingDataList, String employeeId) {
    // Create a list to store the filtered data
    List<Data> filteredData = [];

    for (var clockingData in clockingDataList) {
      if (clockingData.data != null) {
        // Filter out the employee-specific data from each ClockingData object
        var employeeData = clockingData.data!
            .where((employee) => employee.employeeId == employeeId)
            .toList();

        // Add the filtered data to the overall list
        filteredData.addAll(employeeData);
      }
    }

    return filteredData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? Center(
                child: Center(
                  child:  SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                      'images/loader.json'
                  ),
                ),)
              )
            : ListView(
                children: [
                  Column(
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
                                  ],
                                ),
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
                              AppLocalizations.of(context)!.myClocking,
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
                                      AppLocalizations.of(context)!.filter,
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
                        itemCount: filteredClockingData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final clock = filteredClockingData[index]; // Corrected index

                          // Format date
                          String formattedDate = DateFormat('MMMM dd, yyyy').format(
                              DateTime.parse(clock.createdAt ?? DateTime.now().toString()));
                          String formattedCheckInTime = DateFormat('hh:mm a').format(
                              DateTime.parse(clock.checkInTime ?? DateTime.now().toString()));

                          // Check if checkOutTime is null
                          String formattedCheckOutTime = clock.checkOutTime != null
                              ? DateFormat('hh:mm a').format(DateTime.parse(clock.checkOutTime!))
                              : 'N/A'; // Provide a fallback for null check-out time


                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 120,
                                  width:
                                      20, // Adjusted the width for visibility
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Row(
                                          children: [
                                            Text(
                                              formattedCheckInTime,
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
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                color: NasColors.darkBlue,
                                              ),
                                              child: Transform(
                                                transform:
                                                    Matrix4.rotationY(math.pi),
                                                // Flip horizontally
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
                                              formattedCheckOutTime,
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
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
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
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
