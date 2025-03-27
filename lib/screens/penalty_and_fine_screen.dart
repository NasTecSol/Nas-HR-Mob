import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PenaltyAndFineScreen extends StatefulWidget {
  const PenaltyAndFineScreen({super.key});

  @override
  State<PenaltyAndFineScreen> createState() => _PenaltyAndFineScreenState();
}

class _PenaltyAndFineScreenState extends State<PenaltyAndFineScreen> {
  int _selectedOptionIndex = 0;
  int? _expandedIndex;
  SingletonClass singletonClass = SingletonClass();
  final List<String> imagePaths = [
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
    'images/DP.png', // Additional images for testing "+n" feature
  ];

  late Future _approverDataFuture; // Declare Future variable

  @override
  void initState() {
    super.initState();
    _approverDataFuture =
        singletonClass.getPenaltiesApprover(); // Initialize Future in initState
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: Padding(
          padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
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
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.4),
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
                  SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                      child: Text(
                        AppLocalizations.of(context)!.penaltiesAndFine,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
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
                       print(singletonClass.penaltiesDataList.first.data!.data!.length);
                      },
                      child: SizedBox(
                        height: 30,
                        width: 90,
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
              if (singletonClass.getJWTModel()?.grade == 'L0' ||
                  singletonClass.getJWTModel()?.grade == 'L1') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildOptionsCard(
                        0, AppLocalizations.of(context)!.againstMe),
                    buildOptionsCard(1, AppLocalizations.of(context)!.teams),
                  ],
                ),
              ],
              if (singletonClass.getJWTModel()?.grade == 'L2' ||
                  singletonClass.getJWTModel()?.grade == 'L3') ...[
                Expanded(
                  // Wrap ListView with Expanded
                  child: FutureBuilder(
                      future: singletonClass.getPenalties(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/loader.json'),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          return singletonClass
                                  .penaltiesDataList.first.data!.data!.isEmpty
                              ? Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.noData,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: singletonClass
                                      .penaltiesDataList.first.data!.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final request = singletonClass
                                        .penaltiesDataList.first.data!.data![index];
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 15,
                                            // Adjusted the width for visibility
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                              ),
                                              color: Colors.red,
                                            ),
                                          ),
                                          Expanded(
                                            // Use Expanded to fill the remaining space
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          "${request.requestData!
                                                              .first.date}",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "SAR ${request.requestData!.first.amount}",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "${request.requestData!.first
                                                        .remark}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                        } else {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }
                      }),
                ),
              ],
              if (singletonClass.getJWTModel()?.grade == 'L0' ||
                  singletonClass.getJWTModel()?.grade == 'L1') ...[
                if (_selectedOptionIndex == 0) ...[
                  Expanded(
                    child: FutureBuilder(
                      future: singletonClass.getPenalties(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/loader.json'),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          if (singletonClass.penaltiesDataList.isEmpty ||
                              singletonClass.penaltiesDataList.first.data == null ||
                              singletonClass.penaltiesDataList.first.data!.data == null ||
                              singletonClass.penaltiesDataList.first.data!.data!.isEmpty) {
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: singletonClass.penaltiesDataList.first.data!.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final request =
                              singletonClass.penaltiesDataList.first.data!.data![index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(15)),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 15,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        color: Colors.red,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    request.requestData?.first.date ?? 'No Date',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "SAR ${request.requestData?.first.amount ?? '0'}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              request.requestData?.first.remark ?? 'No Remark',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
                if (_selectedOptionIndex == 1) ...[
                  Expanded(
                    // Wrap ListView with Expanded
                    child: FutureBuilder(
                        future: _approverDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/loader.json'),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            return  singletonClass.penaltiesApproverDataList.isEmpty ||
                                singletonClass.penaltiesApproverDataList.first.data!.data!.isEmpty
                                ? Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.noData,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(5),
                                    itemCount: singletonClass
                                        .penaltiesApproverDataList.first.data!.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final request = singletonClass
                                          .penaltiesApproverDataList.first.data!.data![index];
                                      return GestureDetector(
                                        onTap: () => _toggleExpand(index),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
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
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_expandedIndex != index) ...[
                                                Container(
                                                  height: 160,
                                                  width: 15,
                                                  // Adjusted the width for visibility
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      bottomLeft:
                                                          Radius.circular(15),
                                                    ),
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                              Expanded(
                                                // Use Expanded to fill the remaining space
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "BAD",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${request.requestData!.first.amount}",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Selected Employees",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                                    'dd-MM-yyyy, hh:mm a')
                                                                .format(DateTime
                                                                    .parse(request
                                                                        .requestData!
                                                                        .first
                                                                        .dateTime)),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (_expandedIndex !=
                                                          index) ...[
                                                        Row(
                                                          children: [
                                                            ...List.generate(
                                                              request
                                                                          .requestData!
                                                                          .first
                                                                          .employees!
                                                                          .length >
                                                                      3
                                                                  ? 3
                                                                  : request
                                                                      .requestData!
                                                                      .first
                                                                      .employees!
                                                                      .length,
                                                              (index) =>
                                                                  Positioned(
                                                                left: index *
                                                                    30.0,
                                                                // Adjust the overlap distance
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      ClipOval(
                                                                    child: Image
                                                                        .asset(
                                                                      imagePaths[
                                                                          index],
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            // Add "+n" indicator if there are more than 3 images
                                                            if (request
                                                                    .requestData!
                                                                    .first
                                                                    .employees!
                                                                    .length >
                                                                3)
                                                              Positioned(
                                                                left: 2 * 30.0,
                                                                // Position for the "+n" indicator
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      '+${request.requestData!.first.employees!.length - 3}',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                      if (_expandedIndex ==
                                                          index) ...[
                                                        Column(
                                                          children: [
                                                            ...List.generate(
                                                              request
                                                                          .requestData!
                                                                          .first
                                                                          .employees!
                                                                          .length >
                                                                      3
                                                                  ? 3
                                                                  : request
                                                                      .requestData!
                                                                      .first
                                                                      .employees!
                                                                      .length,
                                                              (index) =>
                                                                  Positioned(
                                                                left: index *
                                                                    30.0,
                                                                // Adjust the overlap distance
                                                                child: Row(
                                                                  children: [
                                                                    // Main employee image container
                                                                    Container(
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.white,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ClipOval(
                                                                        child: Image
                                                                            .asset(
                                                                          imagePaths[
                                                                              index],
                                                                          // Load image based on index
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    ClipOval(
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        radius:
                                                                            25,
                                                                        child: Image
                                                                            .asset(
                                                                          _getImageForEventType(
                                                                              "${request.requestData!.first.employees![index].severity}"),
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              40,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                            // "+n" indicator if there are more than 3 employees
                                                            if (request
                                                                    .requestData!
                                                                    .first
                                                                    .employees!
                                                                    .length >
                                                                3)
                                                              Positioned(
                                                                left: 2 * 30.0,
                                                                // Position for the "+n" indicator
                                                                child:
                                                                    Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      '+${request.requestData!.first.employees!.length - 3}',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                      Text(
                                                        "Remarks",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        request.requestData!
                                                            .first.remark,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                          } else {
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }
                        }),
                  ),
                ],
              ],
            ],
          ),
        ));
  }

  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 122,
        child: Card(
          color:
              _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color:
                  _selectedOptionIndex == index ? Colors.white : Colors.white,
              width: 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : NasColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case '1':
        return 'images/1.png';
      case '2':
        return 'images/2.png';
      default:
        return 'images/3.png'; // Default image for company or other types
    }
  }
}
