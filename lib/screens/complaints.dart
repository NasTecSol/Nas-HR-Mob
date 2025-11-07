import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/file_complaints_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/complaints_approver_model.dart';
import '../request_controller/complaints_model.dart';
import '../widgets/loader.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  final TextEditingController _comment = TextEditingController();
  int _currentPage = 0;
  int _complaintCurrentPage = 0;
  int _totalPages = 1;
  int _complaintTotalPages = 1;
  List<DataComplaintApprover>? _approver;
  List<Data1>? _request;
  @override
  void initState() {
    super.initState();
    _fetchRequestData(0);
    _fetchApproverData(0);
    getComplaintsData();
  }

  Future<void> _fetchApproverData(int page) async {
    final data = await getComplaintsApproverData(page: page);
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
    final data = await getComplaintsData(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _request = data.data!.data;
        _complaintTotalPages = data.data!.totalPages ?? 1;
        _complaintCurrentPage = page;
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
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Text(
                    AppLocalizations.of(context)!.complaints,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FileComplaintsScreen()));
                    },
                    child: SizedBox(
                      height: 30,
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.fileComplain,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
            ),
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1'  ||
                singletonClass.getJWTModel()?.grade == 'L2' ||
                singletonClass.getJWTModel()?.grade == 'L3') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildOptionsCard(
                      0, AppLocalizations.of(context)!.myComplaints),
                  buildOptionsCard(
                      1, AppLocalizations.of(context)!.teamComplaints)
                ],
              ),
            ],
            if (singletonClass.getJWTModel()?.grade == 'L4') ...[
              Expanded(
                  child: FutureBuilder(
                      future: getComplaintsData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Loader();
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
                          return _request!.isEmpty ? Center(
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
                          ) : ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: _request!.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              final request = _request!.reversed.toList()[index];
                              final locale = Localizations.localeOf(context).languageCode;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: NasColors.containerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                        height: 160,
                                        width:
                                        20,
                                        decoration: locale == "ar" ? BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                          color: Colors.red,
                                        ) : BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                          ),
                                          color: Colors.red
                                        )
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  singletonClass.formatDate2(request.createdAt! , context),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Spacer(),
                                                if (DateTime.parse(request.createdAt!).toLocal().year == DateTime.now().year &&
                                                    DateTime.parse(request.createdAt!).toLocal().month == DateTime.now().month &&
                                                    DateTime.parse(request.createdAt!).toLocal().day == DateTime.now().day)...[
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(
                                                        color: Colors.blue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                ],
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  "${request.employeeName}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 20,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    shape:
                                                    BoxShape.rectangle,
                                                    color:
                                                    _getColorForVerificationStatus("${request.status}"),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${request.status}",
                                                      textAlign:
                                                      TextAlign.center,
                                                      style:
                                                      GoogleFonts.inter(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Text(
                                                  "${request.reason}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
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
                      })),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_complaintTotalPages, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_complaintCurrentPage != index) {
                          _fetchRequestData(index); // Send 0, 1, 2...
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _complaintCurrentPage == index
                              ? NasColors.darkBlue
                              : NasColors.onTime.withOpacity(0.31),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            color: _complaintCurrentPage == index ? Colors.white : Colors.black,
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
                singletonClass.getJWTModel()?.grade == 'L1'  ||
                singletonClass.getJWTModel()?.grade == 'L2'  ||
                singletonClass.getJWTModel()?.grade == 'L3') ...[
              if (_selectedOptionIndex == 0)...[
                Expanded(
                    child: FutureBuilder(
                        future: getComplaintsData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Loader();
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
                            return  _request!.isEmpty ? Center(
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
                            ) : ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: _request!.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final request = _request!.reversed.toList()[index];
                                final locale = Localizations.localeOf(context).languageCode;
                                return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(15)),
                                        color: NasColors.containerColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey
                                                .withValues(alpha: 0.3),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                              height: 160,
                                              width: 20,
                                              decoration: locale == "ar" ? BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight: Radius.circular(15),
                                                ),
                                                color: Colors.red,
                                              ) : BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(15),
                                                ),
                                                color: Colors.red,
                                              )
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        singletonClass.formatDate2(request.createdAt!, context),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      if (DateTime.parse(request.createdAt!).toLocal().year == DateTime.now().year &&
                                                          DateTime.parse(request.createdAt!).toLocal().month == DateTime.now().month &&
                                                          DateTime.parse(request.createdAt!).toLocal().day == DateTime.now().day)...[
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.blue,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                      ],
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${request.employeeName}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Container(
                                                        height: 20,
                                                        width: 75,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                          BoxShape.rectangle,
                                                          color:
                                                          _getColorForVerificationStatus("${request.status}"),
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${request.status}",
                                                            textAlign:
                                                            TextAlign.center,
                                                            style:
                                                            GoogleFonts.inter(
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${request.subType}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${request.reason}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
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
                        })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_complaintTotalPages, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_complaintCurrentPage != index) {
                            _fetchRequestData(index); // Send 0, 1, 2...
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _complaintCurrentPage == index
                                ? NasColors.darkBlue
                                : NasColors.onTime.withOpacity(0.31),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              color: _complaintCurrentPage == index ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
              ],
              if (_selectedOptionIndex == 1)...[
                Expanded(
                    child: FutureBuilder(
                        future: getComplaintsApproverData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Loader();
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
                          } else {
                            return _approver!.isEmpty ? Center(
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
                            ) : ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: _approver!.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final request = _approver!.reversed.toList()[index];
                                final locale = Localizations.localeOf(context).languageCode;
                                return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(15)),
                                        color: NasColors.containerColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(alpha: 0.3),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(
                                                0, 0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                              height: 225,
                                              width:
                                              20, // Adjusted the width for visibility
                                              decoration: locale == "ar" ? BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight: Radius.circular(15),
                                                ),
                                                color: Colors.red,
                                              ) : BoxDecoration(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(15),
                                                ),
                                                color: Colors.red,
                                              )
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        singletonClass.formatDate2(request.createdAt!, context),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      if (DateTime.parse(request.createdAt!).toLocal().year == DateTime.now().year &&
                                                          DateTime.parse(request.createdAt!).toLocal().month == DateTime.now().month &&
                                                          DateTime.parse(request.createdAt!).toLocal().day == DateTime.now().day)...[
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.blue,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                      ],
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${request.employeeName}",
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const Spacer(),
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
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 200,
                                                        child: Text(
                                                          "${request.requestData!.first.title}",
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        width: 200,
                                                        child: Text(
                                                          "${request.reason}",
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        singletonClass.formatDate2(request.createdAt! , context),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                                                                        // 🔧 Fixes overflow
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
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            );
                          }
                        })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_currentPage != index) {
                            _fetchRequestData(index); // Send 0, 1, 2...
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
              SizedBox(height: 20),]
            ],
          ],
        ),
      ),
    );
  }

  //CARDS
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 170,
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

  // GET CALL

  Future<ComplaintsModel?> getComplaintsData({int page = 0, int limit = 20}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;

    // Request body with the required parameter
    Map<String, dynamic> requestBody = {
      "requestTypes": ["complaintRequest"],
    };

    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/employee/$employeeId?limit=$limit&page=$page',
    );

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
          headers: singletonClass.getHeaders()
      );

      log("Complaints Log: ${response.body}");

      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        var requestData = ComplaintsModel.fromJson(responseBody);
        if (page == 0) {
          singletonClass.complaintsDataList.addAll([requestData]);
        } else {
          final existing = singletonClass.complaintsDataList;
          singletonClass.complaintsDataList.addAll([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error Complaints Data: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error Complaints Data: $e');
      return null;
    }
  }


//POST CALL
  Future<ComplaintsApproverModel?> getComplaintsApproverData({int page = 0, int limit = 10}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    if (kDebugMode) {
      print("vghjk$employeeId");
    }
    Map<String, dynamic> requestBody = {
      "requestTypes": ["complaintRequest"],
    };
    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/approver/$employeeId?limit=$limit&page=$page',
    );

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
          headers: singletonClass.getHeaders()
      );

      log("complaints Log approver %%: ${response.body}");

      if (response.statusCode == 201) {
        var responseBody = json.decode(response.body);
        var requestData = ComplaintsApproverModel.fromJson(responseBody);

        if (page == 0) {
          singletonClass.complaintsApproverDataList.addAll([requestData]);
        } else {
          final existing = singletonClass.complaintsApproverDataList;
          singletonClass.complaintsApproverDataList.addAll([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error complaints Log approver: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error complaints Log approver: $e');
      return null;
    }
  }

  void patchRequestData(String? requestID, String status,
      Map<String, dynamic> requestData) async {
    String url = '${singletonClass.baseURL}/request/$requestID';

    // Define the JSON data to send
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

    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    log("complaint json $jsonData");

    // Make the PATCH request
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
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse['statusCode'] == 200) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.success,
            type: QuickAlertType.success,
          );
          await getComplaintsApproverData();
        } else if (decodedResponse['statusCode'] == 400) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.internalServerError,
            type: QuickAlertType.error,
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.errorFetchData,
          type: QuickAlertType.error,
        );
      } else {
        print('Error: ${response.statusCode}');
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
      if (kDebugMode) {
        print('Failed to send data. Error: $error');
      }
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
