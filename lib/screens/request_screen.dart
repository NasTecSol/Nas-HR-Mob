import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/search_employee_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/approver_request_data_model.dart';
import '../request_controller/attachment_response_model.dart';
import '../request_controller/company_model.dart';
import '../request_controller/request_data_model.dart';
import '../request_controller/ui_settings_model.dart';
import '../widgets/colors.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int _selectedOptionIndex = 0;
  int _selectedOptionIndexBottom = 0;
  PlatformFile? selectedFile;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final TextEditingController _totalLoanAmount = TextEditingController();
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResult = false;
  final List<SearchedResult> _employeeSearchResults = [];
  final List<SearchedResult?> _selectedEmployees = [];
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
  final bool _isTeamSelected = false;
  int? installmentAmount;
  String? totalMonths;
  int _currentPage = 0;
  int _totalPages = 1;
  int _requestCurrentPage = 0;
  int _requestTotalPages = 1;
  List<DataApprover>? _approver;
  List<Data1>? _request;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (singletonClass.companyDataList.isNotEmpty &&
        singletonClass.companyDataList.first.data != null &&
        singletonClass.companyDataList.first.data!.request != null) {
      requestType = singletonClass.companyDataList.first.data!.request!
          .map((request) => request.requestType)
          .where((type) => type != null)
          .cast<String>()
          .toList();
    }
    _fetchRequestData(0);
    _fetchApproverData(0);
    getRequestData();
    getApproverData();
    setState(() {
      getRequestData();
      getApproverData();
    });
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    setState(() {
      _isLoading = true;
    });

    final data = await getApproverData(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _approver = data.data!.data;
        _totalPages = data.data!.totalPages ?? 1;
        _currentPage = page;
        _isLoading = false;
      });
    } else {
      setState(() {
        _approver = [];
        _isLoading = false;
      });
    }
  }



  Future<void> _fetchRequestData(int page) async {
    setState(() {
      _isLoading = true;
    });
    final data = await getRequestData(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _request = data.data!.data;
        _requestTotalPages = data.data!.totalPages ?? 1;
        _requestCurrentPage = page;
        _isLoading = false;
      });
    } else {
      setState(() {
        _request = [];
        _isLoading = false;
      });
    }
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
            color: Colors.grey.withValues(alpha: 0.8),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectRequestType,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child:ListView.builder(
                        shrinkWrap: true,
                        itemCount: singletonClass.companyDataList.first.data!.request!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final request = singletonClass.companyDataList.first.data!.request![index];

                          // Collect all allowed titles from "Approval" submenu
                          final allowedRequestNames = <String>{};
                          final uiSettings = singletonClass.uiSettingsModelDataList.first.data?.mobileModules ?? [];

                          for (var module in uiSettings) {
                            if (module.title == 'Approval') {
                              for (var sub in module.subMenu ?? []) {
                                if (sub is Map && sub["title"] != null) {
                                  allowedRequestNames.add(sub["title"]);
                                } else if (sub is MobileModules && sub.title != null) {
                                  allowedRequestNames.add(sub.title!);
                                }
                              }
                            }
                          }

                          final requestName = request.requestName?.toLowerCase() ?? '';
                          final requestType = request.requestType?.toLowerCase() ?? '';

                          final isAllowed = allowedRequestNames.any((allowed) {
                            final allowedLower = allowed.toLowerCase();
                            return requestName.contains(allowedLower) ||
                                allowedLower.contains(requestName) ||
                                requestType.contains(allowedLower) ||
                                allowedLower.contains(requestType);
                          });

                          if (!isAllowed) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (request.requestType ==
                                          'allowance_Increment' &&
                                      (singletonClass.getJWTModel()?.grade ==
                                              'L0' ||
                                          singletonClass.getJWTModel()?.grade ==
                                              'L1')) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    _selectedRequestType =
                                                        request.requestType;
                                                    _showRequestBottomSheet(
                                                        context, request);
                                                  });
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        radius: 25,
                                                        child: Image.asset(
                                                          'images/person.png',
                                                          fit: BoxFit.fill,
                                                          height: 50,
                                                          width: 50,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .yourSelf,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    _selectedRequestType =
                                                        request.requestType;
                                                    _showRequestBottomSheet2(
                                                        context, request);
                                                  });
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.white,
                                                        radius: 25,
                                                        child: Image.asset(
                                                          'images/Group.png',
                                                          fit: BoxFit.fill,
                                                          height: 50,
                                                          width: 50,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .teams,
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                    _removeOverlay();
                                  } else {
                                    setState(() {
                                      _selectedRequestType = request
                                          .requestType; // Set selected request type
                                    });
                                    _removeOverlay();
                                    _showRequestBottomSheet(context, request);
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
                                    child: Image.asset(
                                      _getImageForEventType(
                                          request.requestType!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _translateRequest(request.requestName, context),
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
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
                if (singletonClass.getJWTModel()?.grade == 'L0' ||
                    singletonClass.getJWTModel()?.grade == 'L1'||
                    singletonClass.getJWTModel()?.grade == 'L2'||
                    singletonClass.getJWTModel()?.grade == 'L3') ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                    child: SizedBox(
                      width: 140,
                      child: Text(
                        AppLocalizations.of(context)!.requestAndApproval,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
                if (singletonClass.getJWTModel()?.grade == 'L4') ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                    child: Text(
                      AppLocalizations.of(context)!.requests,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                ],
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
                singletonClass.getJWTModel()?.grade == 'L1'||
                singletonClass.getJWTModel()?.grade == 'L2'||
                singletonClass.getJWTModel()?.grade == 'L3' ) ...[
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
                        color: Colors.grey.withValues(alpha: 0.5),
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
                  onPressed: () {
                    print(
                        "Singleton Data : ${singletonClass.requestDataList.first.data!.data!.first.employeeName}");
                  },
                  icon: Icon(
                    Icons.filter_list_alt,
                    size: 35,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (singletonClass.getJWTModel()?.grade == 'L4') ...[
              Expanded(
                // Wrap ListView with Expanded
                child: FutureBuilder(
                    future: getRequestData(),
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
                        return _request!.isEmpty
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
                                itemCount: _request!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final request = _request![index];
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
                                            color: Colors.grey
                                                .withValues(alpha: 0.5),
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
                                                              request.subType !=
                                                                      null
                                                                  ? request
                                                                      .subType!
                                                                      .replaceAllMapped(
                                                                        RegExp(
                                                                            r'([a-z])([A-Z])'),
                                                                        (Match match) =>
                                                                            '${match.group(1)} ${match.group(2)}',
                                                                      )
                                                                      .replaceFirst(
                                                                          request.subType![
                                                                              0],
                                                                          request
                                                                              .subType![0]
                                                                              .toUpperCase())
                                                                  : '',
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
                                                    Column(
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          width: 75,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: _getColorForVerificationStatus(
                                                                request.status ??
                                                                    'default'),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              _translateStatus(
                                                                  request
                                                                      .status,
                                                                  context),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Icon(
                                                          request
                                                                      .requestData!
                                                                      .first
                                                                      .leaveType ==
                                                                  'sickLeave'
                                                              ? Icons
                                                                  .sick_outlined
                                                              : request
                                                                          .requestData!
                                                                          .first
                                                                          .leaveType ==
                                                                      'annualLeave'
                                                                  ? Icons
                                                                      .calendar_today_outlined
                                                                  : request.requestData!.first
                                                                              .leaveType ==
                                                                          'casualLeave'
                                                                      ? Icons
                                                                          .beach_access_outlined
                                                                      : request.requestType ==
                                                                              'loanRequest'
                                                                          ? Icons
                                                                              .payments_outlined
                                                                          : Icons
                                                                              .error_outline,
                                                          // Fallback icon if no match
                                                          size: 30,
                                                          color: Colors.black,
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: request.requestType ==
                                                          "loanRequest"
                                                      ? Text(
                                                          request.requestData !=
                                                                      null &&
                                                                  request
                                                                      .requestData!
                                                                      .isNotEmpty
                                                              ? "${AppLocalizations.of(context)!.duration}: ${request.requestData!.first.loanDuration}"
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .noData,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      : Text(
                                                          request.requestData !=
                                                                      null &&
                                                                  request
                                                                      .requestData!
                                                                      .isNotEmpty
                                                              ? "Duration: ${request.requestData!.first.duration}"
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .noData,
                                                          style:
                                                              GoogleFonts.inter(
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
                                                  if (request.requestType ==
                                                      'leaveRequest') ...[
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .balanceToDate,
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
                                                        AppLocalizations.of(
                                                                context)!
                                                            .balanceToEndOfYear,
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
                                                    const SizedBox(height: 10),
                                                  ],
                                                  if (request.requestType ==
                                                      'loanRequest') ...[
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .totalLoanAmount,
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
                                                          request.requestData !=
                                                                      null &&
                                                                  request
                                                                      .requestData!
                                                                      .isNotEmpty
                                                              ? "${request.requestData!.first.loanAmount}"
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .noData,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .loanInstallment,
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
                                                          request.requestData !=
                                                                      null &&
                                                                  request
                                                                      .requestData!
                                                                      .isNotEmpty
                                                              ? "${request.requestData!.first.loanInstallment}"
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .noData,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .loanCycle,
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
                                                          request.requestData !=
                                                                      null &&
                                                                  request
                                                                      .requestData!
                                                                      .isNotEmpty
                                                              ? "${request.requestData!.first.loanCycle}"
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .noData,
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                  ],
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // First static column ("Req")
                                                      Column(
                                                        children: [
                                                          Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Container(
                                                                height: 25,
                                                                width: 25,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: NasColors
                                                                      .onTime,
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            "Req",
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 20.0),
                                                        child: Container(
                                                          width: 20,
                                                          height: 2,
                                                          color: Colors.grey,
                                                          margin: const EdgeInsets.only(top: 0, bottom: 0),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Wrap(
                                                          alignment: WrapAlignment.start,
                                                          runSpacing: 0,
                                                          children: request.approvers != null && request.approvers!.isNotEmpty ? request.approvers!.map((approver) {
                                                                  return Column(
                                                                    children: [
                                                                      Stack(
                                                                        alignment: Alignment.center,
                                                                        children: [
                                                                          Container(
                                                                            height: 25,
                                                                            width: 25,
                                                                            decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: _getColorForApproverStatus(approver.status),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height: 10,
                                                                            width: 10,
                                                                            decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 5),
                                                                      Text(
                                                                        approver.approverName ?? 'N/A',
                                                                        style: GoogleFonts.inter(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }).toList()
                                                              : [
                                                                  Text(
                                                                    'N/A',
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 15,
                                                                      color: Colors.grey,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 20.0),
                                                        child: Container(
                                                          width: 20,
                                                          height: 2,
                                                          color: Colors.grey,
                                                          margin: const EdgeInsets.only(top: 0, bottom: 0),
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Container(
                                                                height: 25,
                                                                width: 25,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: NasColors.pending,
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration: const BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            "CEO",
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.black,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_requestTotalPages, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_requestCurrentPage != index) {
                          _fetchRequestData(index); // Send 0, 1, 2...
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _requestCurrentPage == index
                              ? NasColors.darkBlue
                              : NasColors.onTime.withOpacity(0.31),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            color: _requestCurrentPage == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

            ],
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1'||
                singletonClass.getJWTModel()?.grade == 'L2'||
                singletonClass.getJWTModel()?.grade == 'L3') ...[
              if (_selectedOptionIndex == 0) ...[
                Expanded(
                  // Wrap ListView with Expanded
                  child: FutureBuilder(
                      future: getRequestData(),
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
                          return _request!.isEmpty
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
                                  itemCount: _request!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final request = _request![index];
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
                                              color: Colors.grey
                                                  .withValues(alpha: 0.5),
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
                                                                request.subType !=
                                                                        null
                                                                    ? request
                                                                        .subType!
                                                                        .replaceAllMapped(
                                                                          RegExp(
                                                                              r'([a-z])([A-Z])'),
                                                                          (Match match) =>
                                                                              '${match.group(1)} ${match.group(2)}',
                                                                        )
                                                                        .replaceFirst(
                                                                            request.subType![0],
                                                                            request.subType![0].toUpperCase())
                                                                    : '',
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
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 30,
                                                            width: 75,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color: _getColorForVerificationStatus(
                                                                  request.status ??
                                                                      'default'),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                _translateStatus(
                                                                    request
                                                                        .status,
                                                                    context),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Icon(
                                                            request
                                                                        .requestData!
                                                                        .first
                                                                        .leaveType ==
                                                                    'sickLeave'
                                                                ? Icons
                                                                    .sick_outlined
                                                                : request
                                                                            .requestData!
                                                                            .first
                                                                            .leaveType ==
                                                                        'annualLeave'
                                                                    ? Icons
                                                                        .calendar_today_outlined
                                                                    : request.requestData!.first.leaveType ==
                                                                            'casualLeave'
                                                                        ? Icons
                                                                            .beach_access_outlined
                                                                        : request.requestType ==
                                                                                'loanRequest'
                                                                            ? Icons.savings_outlined
                                                                            : Icons.error_outline,
                                                            // Fallback icon if no match
                                                            size: 30,
                                                            color: Colors.black,
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: request
                                                                .requestType ==
                                                            "loanRequest"
                                                        ? Text(
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "Duration: ${request.requestData!.first.loanDuration}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        : Text(
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "Duration: ${request.requestData!.first.duration}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
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
                                                    if (request.requestType ==
                                                        'leaveRequest') ...[
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .balanceToDate,
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
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .balanceToEndOfYear,
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
                                                      const SizedBox(
                                                          height: 10),
                                                    ],
                                                    const SizedBox(height: 10),
                                                    if (request.requestType ==
                                                        'loanRequest') ...[
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .totalLoanAmount,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanAmount}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .loanAmount,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanInstallment}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .loanCycle,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanCycle}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                    ],
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // First static column ("Req")
                                                        Column(
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: 25,
                                                                  width: 25,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: NasColors
                                                                        .onTime,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 10,
                                                                  width: 10,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              "Req",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 20.0),
                                                          child: Container(
                                                            width: 50,
                                                            height: 2,
                                                            color: Colors.grey,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    bottom: 0),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Wrap(
                                                            alignment:
                                                                WrapAlignment
                                                                    .start,
                                                            runSpacing: 0,
                                                            // Space between rows of approver if it wraps
                                                            children: request
                                                                            .approvers !=
                                                                        null &&
                                                                    request
                                                                        .approvers!
                                                                        .isNotEmpty
                                                                ? request
                                                                    .approvers!
                                                                    .map(
                                                                        (approver) {
                                                                    return Column(
                                                                      children: [
                                                                        Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: [
                                                                            Container(
                                                                              height: 25,
                                                                              width: 25,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: _getColorForApproverStatus(approver.status),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: 10,
                                                                              width: 10,
                                                                              decoration: const BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                5),
                                                                        Text(
                                                                          approver.approverName ??
                                                                              'N/A',
                                                                          style:
                                                                              GoogleFonts.inter(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }).toList()
                                                                : [
                                                                    Text(
                                                                      'N/A',
                                                                      style: GoogleFonts
                                                                          .inter(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                          ),
                                                        ),
                                                        // Line between ListView and "CEO"
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 20.0),
                                                          child: Container(
                                                            width: 50,
                                                            height: 2,
                                                            color: Colors.grey,
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    bottom: 0),
                                                          ),
                                                        ),

                                                        // Last static column ("CEO")
                                                        Column(
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: 25,
                                                                  width: 25,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: NasColors
                                                                        .pending,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 10,
                                                                  width: 10,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              "CEO",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_requestTotalPages, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (_requestCurrentPage != index) {
                            _fetchRequestData(index); // Send 0, 1, 2...
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _requestCurrentPage == index
                                ? NasColors.darkBlue
                                : NasColors.onTime.withOpacity(0.31),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              color: _requestCurrentPage == index ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              if (_selectedOptionIndex == 1) ...[
                Expanded(
                  child: FutureBuilder(
                      future: getApproverData(),
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
                                  .approverDataList.first.data!.data!.isEmpty
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
                                  itemCount: _approver!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final request = _approver![index];
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
                                              color: Colors.grey
                                                  .withValues(alpha: 0.5),
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
                                                                request.subType !=
                                                                        null
                                                                    ? request
                                                                        .subType!
                                                                        .replaceAllMapped(
                                                                          RegExp(
                                                                              r'([a-z])([A-Z])'),
                                                                          (Match match) =>
                                                                              '${match.group(1)} ${match.group(2)}',
                                                                        )
                                                                        .replaceFirst(
                                                                            request.subType![0],
                                                                            request.subType![0].toUpperCase())
                                                                    : '',
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
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: 30,
                                                            width: 75,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              color: _getColorForVerificationStatus(
                                                                  request.status ??
                                                                      'default'),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                _translateStatus(
                                                                    request
                                                                        .status,
                                                                    context),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Icon(
                                                            request
                                                                        .requestData!
                                                                        .first
                                                                        .leaveType ==
                                                                    'sickLeave'
                                                                ? Icons
                                                                    .sick_outlined
                                                                : request
                                                                            .requestData!
                                                                            .first
                                                                            .leaveType ==
                                                                        'annualLeave'
                                                                    ? Icons
                                                                        .calendar_today_outlined
                                                                    : request.requestData!.first.leaveType ==
                                                                            'casualLeave'
                                                                        ? Icons
                                                                            .beach_access_outlined
                                                                        : request.requestType ==
                                                                                'loanRequest'
                                                                            ? Icons.savings_outlined
                                                                            : Icons.error_outline,
                                                            size: 30,
                                                            color: Colors.black,
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: request
                                                                .requestType ==
                                                            "loanRequest"
                                                        ? Text(
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${AppLocalizations.of(context)!.duration}: ${request.requestData!.first.loanDuration}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        : Text(
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${AppLocalizations.of(context)!.duration}: ${request.requestData!.first.duration}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
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
                                                    if (request.requestType ==
                                                        'leaveRequest') ...[
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .balanceToDate,
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
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .balanceToEndOfYear,
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
                                                      const SizedBox(
                                                          height: 10),
                                                    ],
                                                    const SizedBox(height: 10),
                                                    if (request.requestType ==
                                                        'loanRequest') ...[
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .totalLoanAmount,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanAmount}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .loanInstallment,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanInstallment}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                      const SizedBox(
                                                          height: 10),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .loanCycle,
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
                                                            request.requestData !=
                                                                        null &&
                                                                    request
                                                                        .requestData!
                                                                        .isNotEmpty
                                                                ? "${request.requestData!.first.loanCycle}"
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .noData,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                    ],
                                                    const SizedBox(height: 10),
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
        child: Stack(
          children: [
            Card(
              color: _selectedOptionIndex == index
                  ? NasColors.darkBlue
                  : Colors.white,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : Colors.white,
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
            // Add badge for index 0 (Request Data) and index 1 (Approver Data)
            if (index == 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${singletonClass.requestDataList.isNotEmpty && singletonClass.requestDataList.first.data != null ? singletonClass.requestDataList.first.data!.data!.where((request) => request.status == 'approved').length : 0}', // Request List Notification count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (index == 1)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${singletonClass.approverDataList.isNotEmpty && singletonClass.approverDataList.first.data != null ? singletonClass.approverDataList.first.data!.data!.where((request) => request.status == 'pending').length : 0}', // Approver List Notification count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Check for null values
    if (status == null) {
      return localizations.noData;
    }

    switch (status) {
      case 'pending':
        return localizations.pending;
      case 'approved':
        return localizations.approved;
      case 'rejected':
        return localizations.rejected;
      case 'cancelled':
        return localizations.cancelled;
      default:
        return status;
    }
  }

  String _translateRequest(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'leave Request':
        return localizations.leaveRequests;
      case 'Loan Request':
        return localizations.loanRequest;
      case 'Penalty and Fine Requests':
        return localizations.penaltiesAndFine;
      case 'OverTime':
        return localizations.overTime;
      case 'Training':
        return localizations.training;
      case "Complaint Request":
        return localizations.complaints;
      case "Allowance Increment":
        return localizations.allowanceIncrement;
      case 'Document Request':
        return localizations.documentRequest;
      case "Expense Request":
        return localizations.expenseRequest;
      default:
        return status!;
    }
  }

  String _translateBottomText(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'leave Request':
        return localizations.leaveRequestBottom;
      case 'Loan Request':
        return localizations.loanRequestBottom;
      case 'Penalty and Fine Requests':
        return localizations.penaltiesAndFineBottom;
      case 'OverTime':
        return localizations.overTime;
      case 'Training':
        return localizations.training;
      case "Complaint Request":
        return localizations.complaints;
      case "Allowance Increment":
        return localizations.allowanceIncrementBottom;
      case 'Document Request':
        return localizations.documentRequestBottom;
      case "Expense Request":
        return localizations.expenseRequestBottom;
      default:
        return status!;
    }
  }

  String _translateRequestSubtype(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Sick Leave':
        return localizations.sickLeave;
      case 'Annual Leave':
        return localizations.annualLeave;
      case 'Casual Leave':
        return localizations.casualLeave;
      case 'Advance Salary Request':
        return localizations.advanceSalaryRequest;
      case 'LongTerm Loan Request':
        return localizations.longTermLoanRequest;
      case "Housing Allowance":
        return localizations.housingAllowance;
      case "Traveling Allowance":
        return localizations.travellingAllowance;
      case 'Salary Incremental Allowance':
        return localizations.salaryIncrementalAllowance;
      case "Salary Slip":
        return localizations.salarySlip;
      case "Promotional Letter":
        return localizations.promotionalLetter;
      case "Contract":
        return localizations.contract;
      case "ID Card":
        return localizations.idCard;
      case "Advance Expense":
        return localizations.advanceExpense;
      case "Business Expense":
        return localizations.businessExpense;
      case "Reimbursement":
        return localizations.reimbursement;
      case "Disbursement":
        return localizations.disbursement;
      case "Star":
        return localizations.star;
      case "Moon":
        return localizations.moon;
      case "Bad Behaviour":
        return localizations.badBehaviour;
      default:
        return status!;
    }
  }

  //Approve Colors
  Color _getColorForApproverStatus(String? approverStatus) {
    if (approverStatus == null ||
        approverStatus.isEmpty ||
        approverStatus == 'pending') {
      return NasColors
          .pending; // Use pending color if status is empty or pending
    } else {
      return NasColors
          .completed; // Use completed color if status is other than pending
    }
  }

  void _showWarningDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.insufficientBalance,
            style: GoogleFonts.inter(color: Colors.black),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: GoogleFonts.inter(color: Colors.black),
              ),
            ),
          ],
        );
      },
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

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'leaveRequest':
        return 'images/time.png';
      case 'assetsRequest':
        return 'images/pc.png';
      case 'loanRequest':
        return 'images/loanRequest.png';
      case 'penalties_fines':
        return 'images/Penalties.png';
      case 'allowance_Increment':
        return 'images/creditCard.png';
      case 'documentRequest':
        return 'images/files.png';
        case 'expenseRequest':
        return 'images/loan.png';
        case 'complaintRequest':
        return 'images/Complain.png';
      default:
        return 'images/OverTime.png';
    }
  }

  double? _getRemainingLeaveBalance(String? requestName) {
    if (requestName == null) return null;
    var leaveBalance = singletonClass.employeeDataList.first.data!.leaveBalance;
    for (var entry in leaveBalance!.toJson().entries) {
      print('Checking entry: ${entry.key}');
      if (entry.key.toLowerCase() == requestName.toLowerCase()) {
        print('Found entry: ${entry.key}: ${entry.value}');
        var remaining = entry.value['remaining'];
        print('Remaining for ${entry.key}: $remaining');

        return remaining is num
            ? remaining.toDouble()
            : null;
      }
    }

    return null;
  }

  void _resetBottomSheetData() {
    setState(() {
      _searchController.clear();
      _notes.clear();
      _selectedSubType = null;
      _selectedRequestType = null;
      _employeeSearchResults.clear();
      _selectedEmployees.clear();
      _showSearchResult = false;
      selectedFile = null;
    });
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
        return WillPopScope(
          onWillPop: () async {
            _resetBottomSheetData(); // Reset all data on close
            return true;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Container(
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
                                      color: Colors.grey.withValues(alpha: 0.4),
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
                              AppLocalizations.of(context)!.applyRequests,
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
                          _translateBottomText(selectedRequest.requestName, context),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton<SubTypes>(
                            value: subTypeList.contains(_selectedSubType)
                                ? _selectedSubType
                                : null,
                            underline: Container(
                              height: 1,
                              color: Colors.grey,
                            ),
                            hint: Text(
                              _translateRequest(selectedRequest.requestName, context),
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
                                  _translateRequestSubtype(
                                      subType.requestName!, context),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (SubTypes? newValue) {
                              if (newValue != null) {
                                if (_selectedRequestType == 'leaveRequest') {
                                  double? remainingBalance =
                                      _getRemainingLeaveBalance(
                                          newValue.requestType);

                                  if (remainingBalance == null ||
                                      remainingBalance <= 0) {
                                    // Show warning if the selected leave balance is insufficient
                                    _showWarningDialog(context,
                                        '${AppLocalizations.of(context)!.insufficientBalance} ${_translateRequestSubtype(newValue.requestName, context)}');
                                  } else {
                                    setState(() {
                                      _selectedSubType = newValue;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _selectedSubType = newValue;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_selectedRequestType == 'penalties_fines') ...[
                          if (_selectedEmployees.isNotEmpty) ...[
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedEmployees.length,
                                itemBuilder: (context, index) {
                                  var employee = _selectedEmployees[index];
                                  return Stack(
                                    children: [
                                      // Main container for the employee tile
                                      Container(
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          color: NasColors.lightBlue,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey
                                                  .withValues(alpha: 0.3),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        width: 150,
                                        // Set a fixed width for each employee tile
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 40,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/DP.png"),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  employee!.employeeName ??
                                                      "Unknown",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Optional: Handle long text
                                                ),
                                                Text(
                                                  employee.empId ?? "Unknown",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Small remove button on top-right
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedEmployees
                                                  .remove(employee);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            // Adjust padding for icon size
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16, // Adjust icon size
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          Text(
                            AppLocalizations.of(context)!.searchEmployee,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width - 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextFormField(
                                  cursorColor: Colors.grey,
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText:
                                        '${AppLocalizations.of(context)!.search}...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    getSearchEmployeeData();
                                  });
                                },
                                icon: Icon(
                                  Icons.search,
                                  size: 25,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          if (_showSearchResult == true) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _employeeSearchResults.clear();
                                      });
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.clearAll,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 200, // Adjust as needed
                              child: ListView.builder(
                                itemCount: _employeeSearchResults.length,
                                itemBuilder: (context, index) {
                                  var employee = _employeeSearchResults[index];
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 60,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage("images/DP.png"),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              employee.employeeName ??
                                                  "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue),
                                            ),
                                            Text(
                                              employee.empId ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        // Show an alert dialog when the GestureDetector is tapped
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .selectSeverityOfEmployee,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              content: SizedBox(
                                                height: 120,
                                                // Adjust the height as needed to fit content
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Low Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              1; // Set severity level to 1 for Low
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/1.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .low,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Medium Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              2; // Set severity level to 2 for Medium
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/2.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .medium,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // High Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              3; // Set severity level to 3 for High
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/3.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .high,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        // Space around the icon
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                        if (_isTeamSelected == true) ...[
                          if ((singletonClass.getJWTModel()?.grade == "L0" ||
                                  singletonClass.getJWTModel()?.grade ==
                                      "L1") &&
                              _selectedRequestType ==
                                  "allowance_Increment") ...[
                            if (_selectedEmployees.isNotEmpty) ...[
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedEmployees.length,
                                  itemBuilder: (context, index) {
                                    var employee = _selectedEmployees[index];
                                    return Stack(
                                      children: [
                                        // Main container for the employee tile
                                        Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            color: NasColors.lightBlue,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.3),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          width: 150,
                                          // Set a fixed width for each employee tile
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        "images/DP.png"),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    employee!.employeeName ??
                                                        "Unknown",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    overflow: TextOverflow
                                                        .ellipsis, // Optional: Handle long text
                                                  ),
                                                  Text(
                                                    employee.empId ?? "Unknown",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Small remove button on top-right
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedEmployees
                                                    .remove(employee);
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              // Adjust padding for icon size
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16, // Adjust icon size
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                            Text(
                              AppLocalizations.of(context)!.searchEmployee,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextFormField(
                                    cursorColor: Colors.grey,
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText:
                                          '${AppLocalizations.of(context)!.search}...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      getSearchEmployeeData();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    size: 25,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                            if (_showSearchResult == true) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _employeeSearchResults.clear();
                                        });
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.clearAll,
                                        style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 200, // Adjust as needed
                                child: ListView.builder(
                                  itemCount: _employeeSearchResults.length,
                                  itemBuilder: (context, index) {
                                    var employee =
                                        _employeeSearchResults[index];
                                    return ListTile(
                                      title: Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 60,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image:
                                                    AssetImage("images/DP.png"),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                employee.employeeName ??
                                                    "Unknown",
                                                style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue),
                                              ),
                                              Text(
                                                employee.empId ?? "Unknown",
                                                style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          // Show an alert dialog when the GestureDetector is tapped
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(context)!
                                                      .selectSeverityOfEmployee,
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                content: SizedBox(
                                                  height: 120,
                                                  // Adjust the height as needed to fit content
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // Low Severity Option
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            employee.severity =
                                                                1; // Set severity level to 1 for Low
                                                            if (_selectedEmployees
                                                                .contains(
                                                                    employee)) {
                                                              _selectedEmployees
                                                                  .remove(
                                                                      employee);
                                                            } else {
                                                              _selectedEmployees
                                                                  .add(
                                                                      employee);
                                                            }
                                                          });
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ClipOval(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 20,
                                                                child:
                                                                    Image.asset(
                                                                  'images/1.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  height: 40,
                                                                  width: 40,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .low,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Medium Severity Option
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            employee.severity =
                                                                2; // Set severity level to 2 for Medium
                                                            if (_selectedEmployees
                                                                .contains(
                                                                    employee)) {
                                                              _selectedEmployees
                                                                  .remove(
                                                                      employee);
                                                            } else {
                                                              _selectedEmployees
                                                                  .add(
                                                                      employee);
                                                            }
                                                          });
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ClipOval(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 20,
                                                                child:
                                                                    Image.asset(
                                                                  'images/2.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  height: 40,
                                                                  width: 40,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .medium,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // High Severity Option
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            employee.severity =
                                                                3; // Set severity level to 3 for High
                                                            if (_selectedEmployees
                                                                .contains(
                                                                    employee)) {
                                                              _selectedEmployees
                                                                  .remove(
                                                                      employee);
                                                            } else {
                                                              _selectedEmployees
                                                                  .add(
                                                                      employee);
                                                            }
                                                          });
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ClipOval(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 20,
                                                                child:
                                                                    Image.asset(
                                                                  'images/3.png',
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  height: 40,
                                                                  width: 40,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .high,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                          padding: const EdgeInsets.all(8.0),
                                          // Space around the icon
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ],
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.notes,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .pleaseEnterNotes;
                            }
                            return null;
                          },
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
                                color: Colors
                                    .grey, // Default color of the underline
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.selectDate,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        if (_selectedRequestType != 'loanRequest') ...[
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: fromDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                surface: NasColors.lightBlue,
                                                primary: Colors.white,
                                                onPrimary: Colors.black,
                                                onSurface: Colors.white,
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
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

                                          // Recalculate totalDays and totalMonths if toDate is also selected
                                          if (toDate != null) {
                                            final daysDiff = toDate!
                                                    .difference(fromDate!)
                                                    .inDays +
                                                1;
                                            totalDays = daysDiff;
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
                                      fromDate == null
                                          ? AppLocalizations.of(context)!
                                              .fromDate
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
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                surface: NasColors.lightBlue,
                                                primary: Colors.white,
                                                onPrimary: Colors.black,
                                                onSurface: Colors.white,
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
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
                                            final daysDiff = toDate!
                                                    .difference(fromDate!)
                                                    .inDays +
                                                1;
                                            totalDays = daysDiff;
                                          } else {
                                            totalDays = null;
                                            totalMonths = null;
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
                                      toDate == null
                                          ? AppLocalizations.of(context)!.toDate
                                          : DateFormat('yyyy-MM-dd')
                                              .format(toDate!),
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
                        ],
                        const SizedBox(height: 10),
                        if (_selectedRequestType == 'loanRequest') ...[
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: fromDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                surface: NasColors.lightBlue,
                                                primary: Colors.white,
                                                onPrimary: Colors.black,
                                                onSurface: Colors.white,
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
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
                                          fromDate =
                                              DateTime(date.year, date.month);

                                          if (toDate != null) {
                                            int totalMonthCount =
                                                ((toDate!.year -
                                                            fromDate!.year) *
                                                        12 +
                                                    (toDate!.month -
                                                        fromDate!.month) +
                                                    1);
                                            totalMonths =
                                                totalMonthCount.toString();
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
                                      fromDate == null
                                          ? AppLocalizations.of(context)!
                                              .fromDate
                                          : DateFormat('yyyy-MM')
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
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                surface: NasColors.lightBlue,
                                                primary: Colors.white,
                                                onPrimary: Colors.black,
                                                onSurface: Colors.white,
                                              ),
                                              textButtonTheme:
                                                  TextButtonThemeData(
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
                                          toDate = DateTime(date.year,
                                              date.month); // ignore day

                                          if (fromDate != null) {
                                            int totalMonthCount =
                                                ((toDate!.year -
                                                            fromDate!.year) *
                                                        12 +
                                                    (toDate!.month -
                                                        fromDate!.month) +
                                                    1);
                                            totalMonths =
                                                totalMonthCount.toString();
                                          }
                                        });
                                      }
                                    },
                                    child: Text(
                                      toDate == null
                                          ? AppLocalizations.of(context)!.toDate
                                          : DateFormat('yyyy-MM')
                                              .format(toDate!),
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
                              if (totalMonths != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Total Months: $totalMonths',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                        const SizedBox(height: 10),
                        if (_selectedRequestType == "leaveRequest") ...[
                          Text(
                            AppLocalizations.of(context)!.days,
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
                        ],
                        const SizedBox(height: 10),
                        if (_selectedRequestType == 'loanRequest') ...[
                          Text(
                            AppLocalizations.of(context)!.totalLoanAmount,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a value";
                              }
                              return null;
                            },
                            controller: _totalLoanAmount,
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
                                  color: Colors
                                      .grey, // Default color of the underline
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                double parsedValue =
                                    double.tryParse(value) ?? 0.0;
                                double safeTotalMonths =
                                    double.tryParse(totalMonths ?? "0") ?? 0.0;

                                if (safeTotalMonths > 0) {
                                  installmentAmount = (parsedValue /
                                          safeTotalMonths)
                                      .round(); // or .toInt() if you want to truncate
                                } else {
                                  installmentAmount = 0;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.installmentAmount,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            (installmentAmount == null)
                                ? "N/A"
                                : "$installmentAmount",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          )
                        ],
                        const SizedBox(height: 10),
                        if (_selectedRequestType == 'penalties_fines') ...[
                          Text(
                            AppLocalizations.of(context)!.amount,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .pleaseEnterNotes;
                              }
                              return null;
                            },
                            controller: _amount,
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
                                  color: Colors
                                      .grey, // Default color of the underline
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!.details,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .pleaseEnterNotes;
                              }
                              return null;
                            },
                            controller: _details,
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
                                  color: Colors
                                      .grey, // Default color of the underline
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        if (selectedRequest.docRequired == true) ...[
                          TextButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.any,
                              );

                              if (result != null &&
                                  result.files.single.path != null) {
                                PlatformFile file = result.files.single;

                                // Show the image immediately
                                setState(() => selectedFile = file);

                                // Start upload in the background
                                final results = await uploadProfile(file);
                                final success = results["success"] as bool;
                                final message = results["message"] as String;

                                if (!success && context.mounted) {
                                  setState(() => selectedFile = null);

                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!
                                          .uploadFailed),
                                      content: Text(message),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            AppLocalizations.of(context)!.ok,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                print('File selection canceled.');
                              }
                            },
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),

                                /// Flexible Text to avoid overflow
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.attachDocuments,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                /// Wrap image preview in Flexible to prevent overflow
                                if (selectedFile != null)
                                  Flexible(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipOval(
                                          child: Image.file(
                                            File(selectedFile!.path!),
                                            width: 60, // reduced width to help fit
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedFile = null),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0, right: 50),
                          child: GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                // Check if fromDate and toDate are selected
                                if (fromDate == null || toDate == null) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: AppLocalizations.of(context)!
                                        .enterToAndFromDate,
                                    autoCloseDuration:
                                        const Duration(seconds: 5),
                                    showCancelBtn: false,
                                    showConfirmBtn: false,
                                  );
                                } else if (selectedRequest.docRequired ==
                                        true &&
                                    selectedFile == null) {
                                  // Validation for required document
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: AppLocalizations.of(context)!
                                        .pleaseAttachDocument,
                                    autoCloseDuration:
                                        const Duration(seconds: 5),
                                    showCancelBtn: false,
                                    showConfirmBtn: false,
                                  );
                                } else {
                                  // All validations passed, proceed to post the request
                                  postRequest();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .pleaseEnterNotes),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
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
                                  AppLocalizations.of(context)!.submit,
                                  style: GoogleFonts.inter(
                                    fontSize: 19,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      _resetBottomSheetData(); // Also reset data when sheet is closed
    });
  }

  void _showRequestBottomSheet2(BuildContext context, Request selectedRequest) {
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
        return WillPopScope(
          onWillPop: () async {
            _resetBottomSheetData(); // Reset all data on close
            return true;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Container(
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
                                      color: Colors.grey.withValues(alpha: 0.4),
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
                              AppLocalizations.of(context)!.applyRequests,
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
                          _translateBottomText(
                              selectedRequest.requestName, context),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButton<SubTypes>(
                            value: subTypeList.contains(_selectedSubType)
                                ? _selectedSubType
                                : null,
                            underline: Container(
                              height: 1,
                              color: Colors.grey,
                            ),
                            hint: Text(
                              "${AppLocalizations.of(context)!.select} ${_translateRequest(selectedRequest.requestName, context)} ${AppLocalizations.of(context)!.type}",
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
                                  _translateRequestSubtype(
                                      subType.requestName, context),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (SubTypes? newValue) {
                              if (newValue != null) {
                                if (_selectedRequestType == 'leaveRequest') {
                                  double? remainingBalance =
                                      _getRemainingLeaveBalance(
                                          newValue.requestType);
                                  if (remainingBalance == null ||
                                      remainingBalance <= 0) {
                                    _showWarningDialog(context,
                                        '${AppLocalizations.of(context)!.insufficientBalance} ${_translateRequestSubtype(newValue.requestName, context)}');
                                  } else {
                                    setState(() {
                                      _selectedSubType = newValue;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _selectedSubType = newValue;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        if ((singletonClass.getJWTModel()?.grade == "L0" ||
                                singletonClass.getJWTModel()?.grade == "L1") &&
                            _selectedRequestType == "allowance_Increment") ...[
                          if (_selectedEmployees.isNotEmpty) ...[
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedEmployees.length,
                                itemBuilder: (context, index) {
                                  var employee = _selectedEmployees[index];
                                  return Stack(
                                    children: [
                                      // Main container for the employee tile
                                      Container(
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          color: NasColors.lightBlue,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey
                                                  .withValues(alpha: 0.3),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        width: 150,
                                        // Set a fixed width for each employee tile
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 40,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/DP.png"),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  employee!.employeeName ??
                                                      "Unknown",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Optional: Handle long text
                                                ),
                                                Text(
                                                  employee.empId ?? "Unknown",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Small remove button on top-right
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedEmployees
                                                  .remove(employee);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            // Adjust padding for icon size
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16, // Adjust icon size
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                          Text(
                            AppLocalizations.of(context)!.searchEmployee,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width - 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextFormField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText:
                                        '${AppLocalizations.of(context)!.search}...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    getSearchEmployeeData();
                                  });
                                },
                                icon: Icon(
                                  Icons.search,
                                  size: 25,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          if (_showSearchResult == true) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _employeeSearchResults.clear();
                                      });
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.clearAll,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 200, // Adjust as needed
                              child: ListView.builder(
                                itemCount: _employeeSearchResults.length,
                                itemBuilder: (context, index) {
                                  var employee = _employeeSearchResults[index];
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 60,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage("images/DP.png"),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              employee.employeeName ??
                                                  "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue),
                                            ),
                                            Text(
                                              employee.empId ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        // Show an alert dialog when the GestureDetector is tapped
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                AppLocalizations.of(context)!
                                                    .selectSeverityOfEmployee,
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              content: SizedBox(
                                                height: 120,
                                                // Adjust the height as needed to fit content
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Low Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              1; // Set severity level to 1 for Low
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/1.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .low,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Medium Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              2; // Set severity level to 2 for Medium
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/2.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .medium,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // High Severity Option
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          employee.severity =
                                                              3; // Set severity level to 3 for High
                                                          if (_selectedEmployees
                                                              .contains(
                                                                  employee)) {
                                                            _selectedEmployees
                                                                .remove(
                                                                    employee);
                                                          } else {
                                                            _selectedEmployees
                                                                .add(employee);
                                                          }
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the dialog
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ClipOval(
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 20,
                                                              child:
                                                                  Image.asset(
                                                                'images/3.png',
                                                                fit:
                                                                    BoxFit.fill,
                                                                height: 40,
                                                                width: 40,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .high,
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        // Space around the icon
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.notes,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .pleaseEnterNotes;
                            }
                            return null;
                          },
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
                                color: Colors
                                    .grey, // Default color of the underline
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.selectDate,
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
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              surface: NasColors.lightBlue,
                                              primary: Colors.white,
                                              onPrimary: Colors.black,
                                              onSurface: Colors.white,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
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
                                        ? AppLocalizations.of(context)!.fromDate
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
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              surface: NasColors.lightBlue,
                                              primary: Colors.white,
                                              onPrimary: Colors.black,
                                              onSurface: Colors.white,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
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
                                                  .inDays +
                                              1; // Calculate totalDays
                                        } else {
                                          totalDays =
                                              null; // Handle case where fromDate is null
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    toDate == null
                                        ? AppLocalizations.of(context)!.toDate
                                        : DateFormat('yyyy-MM-dd')
                                            .format(toDate!),
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
                        if (selectedRequest.docRequired == true) ...[
                          TextButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.any,
                              );
                              if (result != null &&
                                  result.files.single.path != null) {
                                PlatformFile file = result.files.single;
                                // Show the image immediately
                                setState(() => selectedFile = file);
                                // Start upload in the background
                                final results = await uploadProfile(file);
                                final success = results["success"] as bool;
                                final message = results["message"] as String;
                                if (!success && context.mounted) {
                                  setState(() => selectedFile = null);
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Text("Upload Failed"),
                                      content: Text(message),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            "OK",
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                print('File selection canceled.');
                              }
                            },
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
                                  AppLocalizations.of(context)!.attachDocuments,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  children: [
                                    if (selectedFile != null)
                                      Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipOval(
                                            child: Image.file(
                                              File(selectedFile!.path!),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: -5,
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                  () => selectedFile = null),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(left: 50.0, right: 50),
                          child: GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                // Check if fromDate and toDate are selected
                                if (fromDate == null || toDate == null) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: AppLocalizations.of(context)!
                                        .enterToAndFromDate,
                                    autoCloseDuration:
                                        const Duration(seconds: 5),
                                    showCancelBtn: false,
                                    showConfirmBtn: false,
                                  );
                                } else if (selectedRequest.docRequired ==
                                        true &&
                                    selectedFile == null) {
                                  // Validation for required document
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: AppLocalizations.of(context)!
                                        .pleaseAttachDocument,
                                    autoCloseDuration:
                                        const Duration(seconds: 5),
                                    showCancelBtn: false,
                                    showConfirmBtn: false,
                                  );
                                } else {
                                  // All validations passed, proceed to post the request
                                  postRequest();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .pleaseEnterNotes),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
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
                                  AppLocalizations.of(context)!.submit,
                                  style: GoogleFonts.inter(
                                    fontSize: 19,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      _resetBottomSheetData(); // Also reset data when sheet is closed
    });
  }

  Widget buildOptionsCard2(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndexBottom = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 140,
        child: Card(
          color: _selectedOptionIndexBottom == index
              ? NasColors.darkBlue
              : Colors.white,
          elevation: 100.0,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: _selectedOptionIndexBottom == index
                  ? Colors.white
                  : Colors.white,
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
                  color: _selectedOptionIndexBottom == index
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

  //S3 CALL
  Future<Map<String, dynamic>> uploadProfile(PlatformFile file) async {
    try {
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }

      var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      var request = http.MultipartRequest('POST', uri);

      final mimeType =
          lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(fileBytes),
        fileBytes.length,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("API Response Body: $responseBody");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        AttachmentResponse attachmentResponse =
            AttachmentResponse.fromJson(decodedJson);
        singletonClass.attachmentResponseDataList = [attachmentResponse];
        return {"success": true, "message": ""};
      } else {
        return {
          "success": false,
          "message": "Upload failed: ${response.statusCode}\n\n$responseBody"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  //POST API CALL
  Future<void> postRequest() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String? companyId = singletonClass.getJWTModel()?.companyId;
    String? branchId = singletonClass.getJWTModel()?.branchId;
    String? firstName = singletonClass.employeeDataList.first.data!.firstName;
    String? middleName = singletonClass.employeeDataList.first.data!.middleName;
    String? lastName = singletonClass.employeeDataList.first.data!.lastName;
    String? policyId =
        singletonClass.companyDataList.first.data!.policies!.first.policyId;
    String? employeeName = [firstName, middleName, lastName]
        .where((name) => name != null && name.isNotEmpty)
        .join(' ');

    String? selectedRequestType = _selectedRequestType;
    String? selectedSubType = _selectedSubType?.requestType;
    String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    int totalDays = toDate!.difference(fromDate!).inDays + 1;
    String totalDaysString = totalDays.toString();

    if (selectedRequestType == null || selectedSubType == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: AppLocalizations.of(context)!.selectSubType,
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
      );
      return;
    }

    // Prepare attachments if a file is selected
    List<Map<String, dynamic>> attachments = [];
    if (selectedFile != null) {
      attachments.add({
        "fileName": singletonClass
            .attachmentResponseDataList.first.data!.attachmentName,
        "fileType": singletonClass
            .attachmentResponseDataList.first.data!.attachmentType,
        "fileContent":
            singletonClass.attachmentResponseDataList.first.data!.url,
      });
    }

    List<Map<String, dynamic>> requestData = [];

    if (selectedRequestType == 'loanRequest') {
      int? loanAmount = int.tryParse(_totalLoanAmount.text);
      int? totalMonth = int.tryParse(totalMonths!);
      requestData.add({
        "loanAmount": loanAmount,
        "loanCycle": "monthly",
        "loanInstallment": installmentAmount,
        "loanDuration": totalMonth,
        "loanType": selectedSubType,
      });
    } else if (selectedRequestType == 'penalties_fines') {
      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
          "severity": employee.severity, // Adjust as needed
        };
      }).toList();

      requestData.add({
        "employees": employees,
        "fine_penality": selectedSubType,
        "amount": _amount.text, // Example amount
        "details": _details.text,
        "date&time": formattedFromDate,
        "remark": _notes.text,
      });
    } else if (selectedRequestType == 'allowance_Insurance') {
      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
        };
      }).toList();

      requestData.add({
        "employees": employees,
        "startDate": formattedFromDate,
        "endDate": formattedToDate,
        "duration": totalDaysString,
        "allowanceType": selectedSubType,
      });
    } else {
      requestData.add({
        "startDate": formattedFromDate,
        "endDate": formattedToDate,
        "duration": totalDaysString,
        "leaveType": selectedSubType,
      });
    }

    // Construct the data map for the API call
    Map<String, dynamic> data = {
      "employeeId": employeeId,
      "companyId": companyId,
      "empId": singletonClass.getJWTModel()?.empId,
      "employeeName": employeeName,
      "branchId": branchId,
      "policyId": policyId,
      "requestType": selectedRequestType,
      "subType": selectedSubType,
      "requestData": requestData,
      "approvers": [],
      "reason": _notes.text,
      "attachments": attachments,
    };

    String body = json.encode(data);
    print("Request JSON POST ${body}");
    var uri = Uri.parse('${singletonClass.baseURL}/request/create');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );

      setState(() {
        isLoading = false;
      });

      final decodedResponse = json.decode(response.body);
      print("REQUEST RESPONSE ${decodedResponse}");

      int responseCode = decodedResponse['statusCode'] ?? response.statusCode;

      if (responseCode == 200) {
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
        await getRequestData();
        Navigator.pop(context);
      } else {
        String errorMessage = decodedResponse['errorMessage'] ??
            'An unexpected error occurred. Please try again.';
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: errorMessage,
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
  void patchRequestData(String? requestID, String status,
      Map<String, dynamic> requestData) async {
    String url = '${singletonClass.baseURL}/request/$requestID';

    String? currentApproverId = singletonClass.getJWTModel()?.employeeId;

    List<dynamic> updatedApprovers = requestData['approvers'].map((approver) {
      if (approver['approverId'] == currentApproverId) {
        return {
          "approverId": approver['approverId'],
          "approverName": approver['approverName'],
          "status": status,
          "timeStamps": DateTime.now().toIso8601String(),
          "comments": _comment.text,
        };
      } else {
        return approver;
      }
    }).toList();

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
      "approvers": updatedApprovers,
      "reason": requestData['reason'],
      "attachments": requestData['attachments'],
      "status": status
    };

    String jsonData = jsonEncode(data);
    log("PATCH DATA JSON $jsonData");

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
      } else {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          type: QuickAlertType.error,
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
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


  //Search CALL
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text.trim();
    if (employeeId.isEmpty) return;

    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri,headers: singletonClass.getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResult result = SearchedResult(
        empId: employeeData.data?.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.first.firstName,
      );

      print(">>>>$result");
      setState(() {
        // Remove existing entry with the same empId first
        _employeeSearchResults.removeWhere((e) => e.empId == result.empId);

        // Then add the new result
        _employeeSearchResults.add(result);

        _showSearchResult = true;
      });
      print("???$_employeeSearchResults");
    } else {
      setState(() {
        _showSearchResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.employeeNotFound)),
      );
    }
  }

  Future<ApproverRequestData?> getApproverData(
      {int page = 0, int limit = 10}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;

    // Request body (stays the same)
    Map<String, dynamic> requestBody = {
      "requestTypes": [
        "leaveRequest",
        "loanRequest",
        "expenseRequest",
        "allowance_Increment",
        "documentRequest",
      ],
    };

    // Updated URI with query parameters
    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/approver/$employeeId?limit=$limit&page=$page',
    );


    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: singletonClass.getHeaders(),
      );

      log("Request Log approver: ${response.body}");

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final requestData = ApproverRequestData.fromJson(responseBody);

        // Optionally: merge or update list if pagination is used for loading more
        if (page == 0) {
          singletonClass.setApproverDataList([requestData]);
        } else {
          final existing = singletonClass.approverDataList;
          singletonClass.setApproverDataList([...existing, requestData]);
        }

        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error Approver Data: $e');
      return null;
    }
  }

  //Request
  Future<RequestDataModel?> getRequestData(
      {int page = 0, int limit = 10}) async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;

    // Request body with the required parameter
    Map<String, dynamic> requestBody = {
      "requestTypes": [
        "leaveRequest",
        "loanRequest",
        "expenseRequest",
        "allowance_Increment",
        "documentRequest",
      ],
    };

    // Updated URI with query parameters
    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/employee/$employeeId?limit=$limit&page=$page',
    );
    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: singletonClass.getHeaders(),
      );

      log("Request Log: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = RequestDataModel.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        if (page == 0) {
          singletonClass.setRequestData([requestData]);
        } else {
          final existing = singletonClass.requestDataList;
          singletonClass.setRequestData([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error request Data: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error request data: $e');
      return null;
    }
  }
}

//DUMMY MODEL

class SearchedResult {
  dynamic empId;
  dynamic employeeName;
  dynamic severity;

  SearchedResult({
    this.empId,
    this.employeeName,
    this.severity,
  });

  @override
  String toString() {
    return 'SearchedResultData: {empId:$empId , employeeName: $employeeName , severity:$severity}';
  }

  // Convert CashData to JSON
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'employeeName': employeeName,
      'severity': severity,
    };
  }
}
