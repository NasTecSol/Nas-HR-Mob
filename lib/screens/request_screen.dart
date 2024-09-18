import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/company_model.dart';
import '../widgets/colors.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int _selectedOptionIndex = 0;
  final TextEditingController _notes = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  int? _expandedIndex;
  String? _selectedRequestType;
  SubTypes? _selectedSubType;
  List<String> requestType = [];
  List<String> subTypeList = [];
  int? totalDays;

  @override
  void initState() {
    super.initState();
    if (singletonClass.companyDataList.isNotEmpty &&
        singletonClass.companyDataList.first.data != null &&
        singletonClass.companyDataList.first.data!.request != null) {
      // Assuming `requestType` is a String property of the `Request` object
      requestType = singletonClass.companyDataList.first.data!.request!
          .map((request) => request.requestType) // Map to String type
          .where((type) => type != null) // Filter out nulls if necessary
          .cast<String>() // Ensure it is of type List<String>
          .toList();
    }
    singletonClass.getRequestData();
    singletonClass.getApproverData();
    setState(() {
      singletonClass.getRequestData();
      singletonClass.getApproverData();
    });
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null; // Collapse if the same item is clicked again
      } else {
        _expandedIndex = index; // Expand the clicked item
      }
    });
  }

//Overlay

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
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Request Type",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Add spacing between widgets
                    Expanded(
                      // Use Expanded to constrain ListView height
                      child: ListView.builder(
                        shrinkWrap: true,
                        // Ensures it takes only as much space as needed
                        itemCount: singletonClass
                            .companyDataList.first.data!.request!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final request = singletonClass
                              .companyDataList.first.data!.request![index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRequestType = request
                                        .requestType; // Set selected request type
                                  });
                                  _removeOverlay();
                                  _showRequestBottomSheet(context, request);
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
                                    child: Image.asset(
                                      _getImageForEventType(
                                          request.requestType!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${request.requestType}",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                  child: Text(
                    AppLocalizations.of(context)!.requests,
                    style: GoogleFonts.inter(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: NasColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      _overlayEntry = _createOverlayEntry();
                      Overlay.of(context).insert(_overlayEntry!);
                    },
                    child: SizedBox(
                      height: 30,
                      width: 130,
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
                            AppLocalizations.of(context)!.requests,
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
            const SizedBox(height: 10),
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1') ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildOptionsCard(0, AppLocalizations.of(context)!.requests),
                    buildOptionsCard(
                        1, AppLocalizations.of(context)!.approvals),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText:
                                '${AppLocalizations.of(context)!.search}...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        color: NasColors.darkBlue,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.filter_list_alt,
                    size: 35,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (singletonClass.getJWTModel()?.grade == 'L2' ||
                singletonClass.getJWTModel()?.grade == 'L3') ...[
              Expanded(
                // Wrap ListView with Expanded
                child: FutureBuilder(
                    future: singletonClass.getRequestData(),
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
                        return singletonClass
                                .requestDataList.first.data!.isEmpty
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
                                    .requestDataList.first.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final request = singletonClass
                                      .requestDataList.first.data![index];
                                  return GestureDetector(
                                    onTap: () => _toggleExpand(index),
                                    child: AnimatedContainer(
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
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        image:
                                                            const DecorationImage(
                                                          image: AssetImage(
                                                              'images/DP.png'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    SizedBox(
                                                      width: 150,
                                                      child: Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              "${request.employeeName}",
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
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              "${request.subType}",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      height: 30,
                                                      width: 75,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        color:
                                                            _getColorForVerificationStatus(
                                                                request
                                                                    .status!),
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
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    request.requestData !=
                                                                null &&
                                                            request.requestData!
                                                                .isNotEmpty
                                                        ? "${request.requestData!.first.startDate} - ${request.requestData!.first.endDate}"
                                                        : "No data available",
                                                    style: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                if (_expandedIndex ==
                                                    index) ...[
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "${request.reason}",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      '${request.requestType}',
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "Balance to Date",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "25 Days",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "Balance to end of Year",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "15",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30.0),
                                                    child: GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 220,
                                                        height: 50,
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFF4D4D4D),
                                                              Color(0xFFE64545),
                                                              Color(0xFFCF3E3E),
                                                              Color(0xFFC13A3A),
                                                              Color(0xFF992E2E),
                                                            ],
                                                            begin: Alignment
                                                                .topRight,
                                                            end: Alignment
                                                                .bottomLeft,
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            "Cancel Request",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 19,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
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
              )
            ],
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1') ...[
              if (_selectedOptionIndex == 0) ...[
                Expanded(
                  // Wrap ListView with Expanded
                  child: FutureBuilder(
                      future: singletonClass.getRequestData(),
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
                                  .requestDataList.first.data!.isEmpty
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
                                      .requestDataList.first.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final request = singletonClass
                                        .requestDataList.first.data![index];
                                    return GestureDetector(
                                      onTap: () => _toggleExpand(index),
                                      child: AnimatedContainer(
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
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          image:
                                                              const DecorationImage(
                                                            image: AssetImage(
                                                                'images/DP.png'),
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      SizedBox(
                                                        width: 150,
                                                        child: Column(
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                "${request.employeeName}",
                                                                style:
                                                                    GoogleFonts
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
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                "${request.subType}",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Container(
                                                        height: 30,
                                                        width: 75,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          color:
                                                              _getColorForVerificationStatus(
                                                                  request
                                                                      .status!),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${request.status}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      request.requestData !=
                                                                  null &&
                                                              request
                                                                  .requestData!
                                                                  .isNotEmpty
                                                          ? "${request.requestData!.first.startDate} - ${request.requestData!.first.endDate}"
                                                          : "No data available",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                  if (_expandedIndex ==
                                                      index) ...[
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "${request.reason}",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        '${request.requestType}',
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "Balance to Date",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "25 Days",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "Balance to end of Year",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        "15",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              30.0),
                                                      child: GestureDetector(
                                                        onTap: () {},
                                                        child: Container(
                                                          width: 220,
                                                          height: 50,
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15)),
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
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              "Cancel Request",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 19,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
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
                )
              ],
              if (_selectedOptionIndex == 1) ...[
                Expanded(
                  // Wrap ListView with Expanded
                  child: FutureBuilder(
                      future: singletonClass.getApproverData(),
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
                              .approverDataList.first.data!.isEmpty
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
                                .approverDataList.first.data!.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              final request = singletonClass
                                  .approverDataList.first.data![index];
                              return GestureDetector(
                                onTap: () => _toggleExpand(index),
                                child: AnimatedContainer(
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
                                        color:
                                        Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration:
                                                  BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(15),
                                                    image:
                                                    const DecorationImage(
                                                      image: AssetImage(
                                                          'images/DP.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                SizedBox(
                                                  width: 150,
                                                  child: Column(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                        Alignment
                                                            .topLeft,
                                                        child: Text(
                                                          "${request.employeeName}",
                                                          style:
                                                          GoogleFonts
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
                                                      Align(
                                                        alignment:
                                                        Alignment
                                                            .topLeft,
                                                        child: Text(
                                                          "${request.subType}",
                                                          style:
                                                          GoogleFonts
                                                              .inter(
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: Colors
                                                                .grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Container(
                                                  height: 30,
                                                  width: 75,
                                                  decoration:
                                                  BoxDecoration(
                                                    shape: BoxShape
                                                        .rectangle,
                                                    color:
                                                    _getColorForVerificationStatus(
                                                        request
                                                            .status!),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${request.status}",
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color:
                                                        Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment:
                                              Alignment.topLeft,
                                              child: Text(
                                                request.requestData !=
                                                    null &&
                                                    request
                                                        .requestData!
                                                        .isNotEmpty
                                                    ? "${request.requestData!.first.startDate} - ${request.requestData!.first.endDate}"
                                                    : "No data available",
                                                style: GoogleFonts.inter(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (_expandedIndex ==
                                                index) ...[
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  "${request.reason}",
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  '${request.requestType}',
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  "Balance to Date",
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  "25 Days",
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  "Balance to end of Year",
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    color: Colors.grey,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: Text(
                                                  "15",
                                                  style:
                                                  GoogleFonts.inter(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    10.0),
                                                child: Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        patchRequestData(
                                                            request.id,
                                                            'Rejected',
                                                            request.toJson() // Ensure you have a method to convert the request to JSON
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 140,
                                                        height: 40,
                                                        decoration:
                                                        const BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .all(Radius
                                                              .circular(
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
                                                          alignment: Alignment
                                                              .center,
                                                          child: Text(
                                                            "Cancel Request",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () {
                                                        patchRequestData(
                                                            request.id,
                                                            'accepted',
                                                            request.toJson() // Ensure you have a method to convert the request to JSON
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 140,
                                                        height: 40,
                                                        decoration:
                                                        const BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                                          gradient:
                                                          LinearGradient(
                                                            colors: [
                                                              Color(0xFF47734D),
                                                              Color(0xFF5B9362),
                                                              Color(0xFF66A56E),
                                                              Color(0xFF76BE7F),
                                                              Color(0xFF86D991),
                                                            ],
                                                            begin: Alignment
                                                                .topRight,
                                                            end: Alignment
                                                                .bottomLeft,
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .center,
                                                          child: Text(
                                                            "Accept Request",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
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
                )
              ],
            ],
          ],
        ),
      ),
    );
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
        width: 140,
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
                  fontSize: 17,
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
      case 'accepted':
        return NasColors.completed;
      case 'pending':
        return Colors.yellow;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey; // or any other default color
    }
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'leaveRequest':
        return 'images/time.png';
      case 'assetsRequest':
        return 'images/pc.png';
      default:
        return 'images/OverTime.png'; // Default image for company or other types
    }
  }

  void _showRequestBottomSheet(BuildContext context, Request selectedRequest) {
    List<SubTypes> subTypeList = selectedRequest.subTypes ?? [];

    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: double.infinity,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        IconButton(
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
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Apply Requests",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "SubType",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<SubTypes>(
                        value: _selectedSubType,
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        hint: Text(
                          'Select SubType',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.black,
                        ),
                        iconSize: 24,
                        isExpanded: true,
                        items: subTypeList.map((SubTypes subType) {
                          return DropdownMenuItem<SubTypes>(
                            value: subType,
                            child: Text(
                              subType.requestName ?? '', // Show requestName
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (SubTypes? newValue) {
                          setState(() {
                            _selectedSubType = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Notes",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextField(
                      controller: _notes,
                      cursorColor: Colors.black,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when focused
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when not focused
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Colors.grey, // Default color of the underline
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Select Date",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    fromDate = date;
                                  });
                                }
                              },
                              child: Text(
                                fromDate == null
                                    ? "From Date"
                                    : DateFormat('yyyy-MM-dd')
                                        .format(fromDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    toDate = date;
                                    if (fromDate != null) {
                                      totalDays = toDate!
                                          .difference(fromDate!)
                                          .inDays; // Calculate totalDays
                                    } else {
                                      totalDays =
                                          null; // Handle case where fromDate is null
                                    }
                                  });
                                }
                              },
                              child: Text(
                                toDate == null
                                    ? "To Date"
                                    : DateFormat('yyyy-MM-dd').format(toDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Days",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      totalDays == null ? "0" : "$totalDays",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Attached Documents",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.only(left: 50.0, right: 50),
                        child: GestureDetector(
                          onTap: () {
                            postRequest();
                          },
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
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
                                "Submit",
                                style: GoogleFonts.inter(
                                  fontSize: 19,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //POST API CALL
  Future<void> postRequest() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String? companyId = singletonClass.getJWTModel()?.companyId;
    String? branchId = singletonClass.getJWTModel()?.branchId;
    String? firstName = singletonClass.employeeDataList.first.data!.firstName;
    String? middleName = singletonClass.employeeDataList.first.data!.middleName;
    String? lastName = singletonClass.employeeDataList.first.data!.lastName;
    String? employeeName = [firstName, middleName, lastName]
        .where((name) => name != null && name.isNotEmpty)
        .join(' ');

    // Ensure these variables are updated based on user selection
    String? selectedRequestType =
        _selectedRequestType; // Request type selected by the user
    String? selectedSubType =
        _selectedSubType?.requestType; // Subtype selected by the user

    String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    int totalDays = toDate!.difference(fromDate!).inDays;
    String totalDaysString = totalDays.toString();
    // Check if requestType and subType are selected
    if (selectedRequestType == null || selectedSubType == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Please select both request type and subtype.',
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
      return; // Exit the function
    }

    Map<String, dynamic> data = {
      "employeeId": employeeId,
      "companyId": companyId,
      "employeeName": employeeName,
      "branchId": branchId,
      "policyId": "123",
      "requestType": selectedRequestType,
      "subType": selectedSubType,
      "requestData": [
        {
          "start_date": formattedFromDate,
          "end_date": formattedToDate,
          "duration": totalDaysString,
          "leave_type": selectedSubType,
        }
      ],
      "approvers": [],
      "reason": _notes.text,
      "attachments": [],
    };

    String body = json.encode(data);
    print(body);
    var uri = Uri.parse('${singletonClass.baseURL}/request/create');

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

      final decodedResponse = json.decode(response.body);
      print(decodedResponse);

      // Check statusCode in the response body
      int responseCode = decodedResponse['statusCode'] ?? response.statusCode;

      if (responseCode == 200) {
        // Show success message based on decoded status
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: decodedResponse['statusMessage'] ??
              'Request completed successfully.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        await singletonClass.getRequestData();
        Navigator.pop(context);
      } else if (responseCode == 400) {
        // Show validation error for status code 400
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Validation Error',
          text: decodedResponse['errorMessage'] ??
              'Validation failed. Please check your inputs.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else if (responseCode == 500) {
        // Show server error for status code 500
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Server Error',
          text: decodedResponse['errorMessage'] ??
              'An unexpected server error occurred.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else {
        // Handle any other response codes
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: decodedResponse['errorMessage'] ??
              'An unexpected error occurred. Please try again.',
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

      // Show error alert for exceptions (network issues, etc.)
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

  //PATCH API CALL
  void patchRequestData(String? requestID, String status, Map<String, dynamic> requestData) async {

    // Define the URL where you want to send the data
    String url = '${singletonClass.baseURL}/request/$requestID';

    // Define the JSON data to send
    Map<String, dynamic> data = {
      "employeeId": requestData['employeeId'],
      "employeeName": requestData['employeeName'],
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
        }
      ],
      "reason": requestData['reason'],
      "attachments": requestData['attachments'],
      "status": status
    };

    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    log("///$jsonData");

    // Make the PATCH request
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
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
            title:AppLocalizations.of(context)!.success,
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
      print('Failed to send data. Error: $error');
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
