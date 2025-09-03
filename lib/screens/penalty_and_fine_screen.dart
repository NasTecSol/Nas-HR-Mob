import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/penalities_fines_model.dart';
import '../request_controller/penalties_approver_model.dart';

class PenaltyAndFineScreen extends StatefulWidget {
  const PenaltyAndFineScreen({super.key});

  @override
  State<PenaltyAndFineScreen> createState() => _PenaltyAndFineScreenState();
}

class _PenaltyAndFineScreenState extends State<PenaltyAndFineScreen> {
  int _selectedOptionIndex = 0;
  int? _expandedIndex;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  final TextEditingController _comment = TextEditingController();
  final List<String> imagePaths = [
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
  ];
  int _currentPage = 0;
  int _penalityCurrentPage = 0;
  int _totalPages = 1;
  int _penalityTotalPages = 1;
  List<DataPenalitiesApprover>? _approver;
  List<Data1>? _request;

  @override
  void initState() {
    super.initState();
    _fetchRequestData(0);
    _fetchApproverData(0);
    getPenalties();
    getPenaltiesApprover();
    setState(() {
      getPenalties();
      getPenaltiesApprover();
    });
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


  Future<void> _fetchApproverData(int page) async {
    final data = await getPenaltiesApprover(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _approver = data.data!.data;
        _totalPages = data.data!.totalPages ?? 1;
        _currentPage = page;
      });
    } else {
      setState(() {
        _approver = [];
      });
    }
  }

  Future<void> _fetchRequestData(int page) async {
    final data = await getPenalties(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _request = data.data!.data;
        _penalityTotalPages = data.data!.totalPages ?? 1;
        _penalityCurrentPage = page;
      });
    } else {
      setState(() {
        _request = [];
      });
    }
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
                ],
              ),
              if (singletonClass.getJWTModel()?.grade == 'L0' ||
                  singletonClass.getJWTModel()?.grade == 'L1'||
                  singletonClass.getJWTModel()?.grade == 'L2'||
                  singletonClass.getJWTModel()?.grade == 'L3') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildOptionsCard(
                        0, AppLocalizations.of(context)!.againstMe),
                    buildOptionsCard(1, AppLocalizations.of(context)!.teams),
                  ],
                ),
              ],
              if (singletonClass.getJWTModel()?.grade == 'L4') ...[
                Expanded(
                  child: FutureBuilder(
                      future: getPenalties(),
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
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/error.json'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return _request!.isEmpty
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Lottie.asset('images/empty.json'),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  itemCount: _request!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final request = _request!.reversed.toList()[index];
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
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Lottie.asset('images/empty.json'),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_penalityTotalPages, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_penalityCurrentPage != index) {
                            _fetchRequestData(index); // Send 0, 1, 2...
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _penalityCurrentPage == index
                                ? NasColors.darkBlue
                                : NasColors.onTime.withOpacity(0.31),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              color: _penalityCurrentPage == index ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
              ],
              if (singletonClass.getJWTModel()?.grade == 'L0' ||
                  singletonClass.getJWTModel()?.grade == 'L1'||
                  singletonClass.getJWTModel()?.grade == 'L2'||
                  singletonClass.getJWTModel()?.grade == 'L3') ...[
                if (_selectedOptionIndex == 0) ...[
                  Expanded(
                    child: FutureBuilder(
                      future: getPenalties(),
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
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/error.json'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          if (_request!.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Lottie.asset('images/empty.json'),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.noData,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: _request!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final request = _request!.reversed.toList()[index];
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
                                                    request.requestData?.first.date ?? '---',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "SAR ${request.requestData?.first.amount ?? '---'}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              request.requestData?.first.remark ?? '---',
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
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Lottie.asset('images/empty.json'),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noData,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_penalityTotalPages, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            if (_penalityCurrentPage != index) {
                              _fetchRequestData(index); // Send 0, 1, 2...
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _penalityCurrentPage == index
                                  ? NasColors.darkBlue
                                  : NasColors.onTime.withOpacity(0.31),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                color: _penalityCurrentPage == index ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
                ],
                if (_selectedOptionIndex == 1) ...[
                  Expanded(
                    child: FutureBuilder(
                        future: getPenaltiesApprover(),
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
                              child: Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Lottie.asset('images/error.json'),
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return  _approver!.isEmpty
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Lottie.asset('images/empty.json'),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.noData,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(5),
                                    itemCount: _approver!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final request = _approver!.reversed.toList()[index];
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      height: 20,
                                                      width: 75,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.rectangle,
                                                        color: _getColorForVerificationStatus("${request.status}"),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "${request.status}",
                                                          textAlign: TextAlign.center,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                     Text(
                                                        "${request.subType}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    Spacer(),
                                                    Text(
                                                      "SAR ${request.requestData!.first.amount}",
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
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                   Text(
                                                        "Selected Employees",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    Spacer(),
                                                    Text(
                                                      DateFormat('dd-MM-yyyy, hh:mm a').format(DateTime.parse(request.requestData!.first.dateTime)),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                if(_expandedIndex != index)...[
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 220,
                                                        height: 50,
                                                        child: Stack(
                                                          children: [
                                                            ...List.generate(
                                                              request.requestData!.first.employees!.length > 3
                                                                  ? 3
                                                                  : request.requestData!.first.employees!.length,
                                                                  (avatarIndex) => Positioned(
                                                                left: avatarIndex * 30.0,
                                                                child: Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    border: Border.all(
                                                                      color: Colors.white,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child: ClipOval(
                                                                    child: Image.asset(
                                                                      imagePaths[avatarIndex],
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (request.requestData!.first.employees!.length > 3)
                                                              Positioned(
                                                                left: 3 * 30.0,
                                                                child: Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.grey[300],
                                                                    border: Border.all(
                                                                      color: Colors.white,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      '+${request.requestData!.first.employees!.length - 3}',
                                                                      style: const TextStyle(
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (_expandedIndex == index) ...[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ...List.generate(
                                                        request.requestData!.first.employees!.length > 3
                                                            ? 3
                                                            : request.requestData!.first.employees!.length,
                                                            (i) => Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(
                                                                    color: Colors.white,
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child: ClipOval(
                                                                  child: Image.asset(
                                                                    imagePaths[i],
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              ClipOval(
                                                                child: CircleAvatar(
                                                                  backgroundColor: Colors.white,
                                                                  radius: 25,
                                                                  child: Image.asset(
                                                                    _getImageForEventType(
                                                                        "${request.requestData!.first.employees![i].severity}"),
                                                                    fit: BoxFit.fill,
                                                                    height: 40,
                                                                    width: 40,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // "+n" more indicator
                                                      if (request.requestData!.first.employees!.length > 3)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 10),
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.grey[300],
                                                              border: Border.all(
                                                                color: Colors.white,
                                                                width: 2,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                '+${request.requestData!.first.employees!.length - 3}',
                                                                style: const TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                                SizedBox(height: 5),
                                                if(_expandedIndex == index)...[
                                                  Row(
                                                    children: [
                                                      Text(
                                                        AppLocalizations.of(context)!.remarks,
                                                        style:
                                                        GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
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
                                                ],
                                                SizedBox(height: 5),
                                                if (_expandedIndex == index)...[
                                                  if (request.status ==
                                                      'pending') ...[
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .all(10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                  context,
                                                                  builder:
                                                                      (BuildContext
                                                                  context) {
                                                                    return AlertDialog(
                                                                      backgroundColor:
                                                                      Colors.white,
                                                                      title:
                                                                      Text(
                                                                        AppLocalizations.of(context)!
                                                                            .comment,
                                                                        style:
                                                                        GoogleFonts.poppins(
                                                                          fontWeight:
                                                                          FontWeight.w500,
                                                                          color:
                                                                          NasColors.darkBlue,
                                                                          fontSize:
                                                                          23,
                                                                        ),
                                                                      ),
                                                                      content:
                                                                      SingleChildScrollView(
                                                                        child:
                                                                        Container(
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            color: Colors.white,
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                            border: Border.all(
                                                                              color: NasColors.darkBlue,
                                                                              width: 1.0,
                                                                            ),
                                                                            boxShadow: const [
                                                                              BoxShadow(
                                                                                color: Colors.white,
                                                                                blurRadius: 15,
                                                                                offset: Offset(0.10, 10.0),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                          TextField(
                                                                            textAlign: TextAlign.center,
                                                                            controller: _comment,
                                                                            minLines: 1,
                                                                            maxLines: null,
                                                                            decoration: InputDecoration(
                                                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(color: NasColors.darkBlue),
                                                                              ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(color: NasColors.darkBlue),
                                                                              ),
                                                                            ),
                                                                            style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 12,
                                                                            ),
                                                                            autofocus: false,
                                                                            textInputAction: TextInputAction.done,
                                                                            cursorColor: Colors.black,
                                                                            onTapOutside: (event) {
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      actions: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.red,
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              child: TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  patchRequestData(request.id, 'rejected', request.toJson());
                                                                                  _comment.clear();
                                                                                },
                                                                                child: Text(
                                                                                  AppLocalizations.of(context)!.rejected,
                                                                                  style: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              width: 120,
                                                              height: 40,
                                                              decoration:
                                                              const BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10)),
                                                                gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                        0xFF4D4D4D),
                                                                    Color(
                                                                        0xFFE64545),
                                                                    Color(
                                                                        0xFFCF3E3E),
                                                                    Color(
                                                                        0xFFC13A3A),
                                                                    Color(
                                                                        0xFF992E2E),
                                                                  ],
                                                                  begin: Alignment
                                                                      .topRight,
                                                                  end: Alignment
                                                                      .bottomLeft,
                                                                ),
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                      context)!
                                                                      .cancel,
                                                                  style: GoogleFonts
                                                                      .inter(
                                                                    fontSize:
                                                                    15,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    backgroundColor: Colors.white,
                                                                    title: Text(
                                                                      AppLocalizations.of(context)!.comment,
                                                                      style: GoogleFonts.poppins(
                                                                        fontWeight: FontWeight.w500,
                                                                        color: NasColors.darkBlue,
                                                                        fontSize: 23,
                                                                      ),
                                                                    ),
                                                                    content: SingleChildScrollView(
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.circular(10.0),
                                                                          border: Border.all(
                                                                            color: NasColors.darkBlue,
                                                                            width: 1.0,
                                                                          ),
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              color: Colors.white,
                                                                              blurRadius: 15,
                                                                              offset: Offset(0.10, 10.0),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: TextField(
                                                                          textAlign: TextAlign.center,
                                                                          controller: _comment,
                                                                          minLines: 1,
                                                                          maxLines: null,
                                                                          decoration: InputDecoration(
                                                                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                                            focusedBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(color: NasColors.darkBlue),
                                                                            ),
                                                                            enabledBorder: OutlineInputBorder(
                                                                              borderSide: BorderSide(color: NasColors.darkBlue),
                                                                            ),
                                                                          ),
                                                                          style: const TextStyle(
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.w500,
                                                                            fontSize: 12,
                                                                          ),
                                                                          autofocus: false,
                                                                          textInputAction: TextInputAction.done,
                                                                          cursorColor: Colors.black,
                                                                          onTapOutside: (event) {
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                              color: NasColors.completed,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            child: TextButton(
                                                                              onPressed: () {
                                                                                Navigator.pop(context);
                                                                                patchRequestData(request.id, 'approved', request.toJson());
                                                                                _comment.clear();
                                                                              },
                                                                              child: Text(
                                                                                AppLocalizations.of(context)!.accept,
                                                                                style: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  color: Colors.white,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 120,
                                                              height: 40,
                                                              decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Color(0xFF47734D),
                                                                    Color(0xFF5B9362),
                                                                    Color(0xFF66A56E),
                                                                    Color(0xFF76BE7F),
                                                                    Color(0xFF86D991),
                                                                  ],
                                                                  begin: Alignment.topRight,
                                                                  end: Alignment.bottomLeft,
                                                                ),
                                                              ),
                                                              child: Align(
                                                                alignment: Alignment.center,
                                                                child: Text(
                                                                  AppLocalizations.of(context)!.acceptRequest,
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 15,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                                ]
                                              ],
                                            ),
                                          )
                                        ),
                                      );
                                    },
                                  );
                          } else {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child: Lottie.asset('images/empty.json'),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.noData,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage != index) {
                              _fetchApproverData(index); // Send 0, 1, 2...
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? NasColors.darkBlue
                                  : NasColors.onTime.withOpacity(0.31),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.inter(
                                color: _currentPage == index ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20),
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


  Color _getColorForVerificationStatus(String verificationStatus) {
    switch (verificationStatus) {
      case 'approved':
        return NasColors.completed;
      case 'pending':
        return NasColors.pending;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey; // or any other default color
    }
  }

  //API CALLS
  Future<PenaltiesAndFineModel?> getPenalties({int page = 0, int limit = 10}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;

    // Request body with the required parameter
    Map<String, dynamic> requestBody = {
      "requestTypes": ["penalties_fines"],
    };

    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/employee/$employeeId?limit=$limit&page=$page',
    );

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: singletonClass.getHeaders(),
      );

      log("Penalties Log: ${response.body}");

      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        var requestData = PenaltiesAndFineModel.fromJson(responseBody);
        if (page == 0) {
          singletonClass.penaltiesDataList.addAll([requestData]);
        } else {
          final existing = singletonClass.penaltiesDataList;
          singletonClass.penaltiesDataList.addAll([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error Penalties Data: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error Penalties Data: $e');
      return null;
    }
  }
  //Approver for penalties
  Future<PenaltiesApproverModel?> getPenaltiesApprover({int page = 0, int limit = 10}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    Map<String, dynamic> requestBody = {
      "requestTypes": ["penalties_fines"],
    };
    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/approver/$employeeId?limit=$limit&page=$page',
    );
    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: singletonClass.getHeaders(),
      );

      log("penalties Log approver: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = PenaltiesApproverModel.fromJson(responseBody);
        if (page == 0) {
          singletonClass.penaltiesApproverDataList.addAll([requestData]);
        } else {
          final existing = singletonClass.penaltiesApproverDataList;
          singletonClass.penaltiesApproverDataList.addAll([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error penalties Log approver: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error penalties Log approver: $e');
      return null;
    }
  }


  void patchRequestData(String? requestID, String status,
      Map<String, dynamic> requestData) async {
    String url = '${singletonClass.baseURL}/request/$requestID';

    Map<String, dynamic> data = {
      "employeeId": requestData['employeeId'],
      "employeeName": requestData['employeeName'],
      "empId": requestData['empId'],
      "companyId": requestData['companyId'],
      "branchId": requestData['branchId'],
      "policyId": requestData['policyId'],
      "requestType": requestData['requestType'],
      "subType": requestData['subType'],
      "requestData": requestData['requestData'],
      "approvers": [
        {
          "approverId": requestData['approvers'][0]['approverId'],
          "approverName": requestData['approvers'][0]['approverName'],
          "status": status,
          "timeStamps": DateTime.now().toIso8601String(),
          "comments": _comment.text,
        }
      ],
      "reason": requestData['reason'],
      "attachments": requestData['attachments'],
      "status": status
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonEncode(data),
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200 && decodedResponse['statusCode'] == 200) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.success,
          type: QuickAlertType.success,
        );
      } else if (decodedResponse['statusCode'] == 400) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          type: QuickAlertType.error,
        );
      } else {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: 'Error: ${response.statusCode}',
          type: QuickAlertType.error,
        );
      }
    } catch (error) {
      if (!mounted) return;
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: 'Failed to send data. Error: $error',
        type: QuickAlertType.error,
      );
    }
  }
}
