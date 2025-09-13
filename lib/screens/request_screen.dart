import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/create_request_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/approver_request_data_model.dart';
import '../request_controller/request_data_model.dart';
import '../request_controller/ui_settings_model.dart';
import '../widgets/colors.dart';


class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int _selectedOptionIndex = 0;
  bool isSearching = false;
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  int? _expandedIndex;
  String? _selectedRequestType;
  List<String> requestType = [];
  List<String> subTypeList = [];
  int? totalDays;
  int? installmentAmount;
  String? totalMonths;
  int _currentPage = 0;
  int _totalPages = 1;
  int _requestCurrentPage = 0;
  int _requestTotalPages = 1;
  List<DataApprover>? _approver;
  List<Data1>? _request;

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


  Future<void> fetchLatestRequestData() async {
    try {
      getApproverData();
      getRequestData();
      _fetchRequestData(0);
      _fetchApproverData(0);
    } catch (e) {
      print("Error fetching data: $e");
    }
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
    });

    final data = await getApproverData(page: page);
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
    setState(() {
    });
    final data = await getRequestData(page: page);
    if (data != null && data.data != null) {
      setState(() {
        _request = data.data!.data;
        _requestTotalPages = data.data!.totalPages ?? 1;
        _requestCurrentPage = page;
      });
    } else {
      setState(() {
        _request = [];
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
                                                    _selectedRequestType = request.requestType;
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateRequestScreen(selectedRequest: request,isTeam: false,)));
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
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateRequestScreen(selectedRequest: request,isTeam: true)));
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
                                      _selectedRequestType = request.requestType;
                                    });
                                    _removeOverlay();
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateRequestScreen(selectedRequest: request, isTeam: false,)));
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
        child: RefreshIndicator(
          color: NasColors.darkBlue,
          backgroundColor: Colors.white,
          onRefresh: fetchLatestRequestData,
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
                  Expanded(
                    child: Container(
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
                              cursorColor: Colors.grey,
                              onChanged: (value) {
                                setState(() {
                                  isSearching = true;
                                });
                              },
                              controller: searchController,
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
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (singletonClass.getJWTModel()?.grade == 'L4') ...[
                Expanded(
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
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/error.json'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return _request == null || _request!.isEmpty
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
                                  itemBuilder: (BuildContext context, int index) {
                                    final request = _request!.reversed.toList()[index];
                                    final searchText = searchController.text.toLowerCase();
                                    if (isSearching) {
                                      final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                      final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;

                                      if (!matchesName && !matchesId) {
                                        return const SizedBox.shrink(); // hide if neither matches
                                      }
                                    }
                                    final allApproved = request.approvers != null &&
                                        request.approvers!.isNotEmpty &&
                                        request.approvers!.every((approver) =>
                                        approver.status?.toLowerCase() == 'approved');
                                    String formatDate(String updatedAt) {
                                      DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                                      return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                                    }
                                    String date = formatDate(request.createdAt!);
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
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
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Text(
                                                      date,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15),
                                                          image: const DecorationImage(
                                                            image: AssetImage('images/DP.png'),
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
                                                               _translateRequestSubtype2( request.subType !=
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
                                                                   : '', context),
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
                                                      Icon(
                                                        request.requestData!.first.leaveType == 'sickLeave'
                                                            ? Icons.sick_outlined : request.requestData!.first.leaveType == 'annualLeave'
                                                            ? Icons.calendar_today_outlined : request.requestData!.first.leaveType == 'casualLeave'
                                                            ? Icons.beach_access_outlined : request.requestType == 'loanRequest'
                                                            ? Icons.payments_outlined : Icons.description_outlined,
                                                        size: 30,
                                                        color: Colors.black,
                                                      )
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
                                                                ? "${AppLocalizations.of(context)!.duration}: ${request.requestData!.first.duration}"
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
                                                          "25 ${AppLocalizations.of(context)!.days}",
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
                                                    SingleChildScrollView(
                                                      scrollDirection:Axis.horizontal,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
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
                                                                      color: NasColors.onTime,
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
                                                              Text(
                                                                "➡️",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          // Line after Req
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 20.0),
                                                            child: Container(
                                                              width: 40,
                                                              height: 2,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          ...[
                                                            if (request.approvers != null && request.approvers!.isNotEmpty)
                                                              for (int i = 0; i < request.approvers!.length; i++) ...[
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
                                                                            color: _getColorForApproverStatus(
                                                                                request.approvers![i].status),
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
                                                                      request.approvers![i].approverName ?? '---',
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                if (i != request.approvers!.length - 1)
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(bottom: 20.0),
                                                                    child: Container(
                                                                      width: 40,
                                                                      height: 2,
                                                                      color: Colors.grey,
                                                                    ),
                                                                  ),
                                                              ]
                                                            else
                                                              Text(
                                                                '---',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 15,
                                                                  color: Colors.grey,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                          ],
                                                          // Line before CEO
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 20.0),
                                                            child: Container(
                                                              width: 40,
                                                              height: 2,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          // CEO
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
                                                                      color: allApproved ? NasColors.onTime : NasColors.pending,
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
                                                              Text(
                                                                allApproved ? "✅" : "⏳",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                        ],
                                                      ),
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
                              child: Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Lottie.asset('images/error.json'),
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return _request == null || _request!.isEmpty
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
                                      final searchText = searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                        final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;

                                        if (!matchesName && !matchesId) {
                                          return const SizedBox.shrink(); // hide if neither matches
                                        }
                                      }
                                      final allApproved = request.approvers != null &&
                                          request.approvers!.isNotEmpty &&
                                          request.approvers!.every((approver) =>
                                          approver.status?.toLowerCase() == 'approved');
                                      String formatDate(String updatedAt) {
                                        DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                                        return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                                      }
                                      String date = formatDate(request.createdAt!);
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
                                                    Align(
                                                      alignment: Alignment.topRight,
                                                      child: Text(
                                                        date,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(15),
                                                            image: const DecorationImage(
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
                                                                alignment: Alignment.topLeft,
                                                                child: Text(
                                                                  _translateRequestSubtype2(request.subType != null ? request.subType!.replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
                                                                        (Match match) => '${match.group(1)} ${match.group(2)}',
                                                                  ).replaceFirst(request.subType![0], request.subType![0].toUpperCase()) : '', context),
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
                                                            SizedBox(width: 5),
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
                                                              : Icons.description_outlined,
                                                          // Fallback icon if no match
                                                          size: 30,
                                                          color: Colors.black,
                                                        )
                                                          ],
                                                        ),
                                                    const SizedBox(height: 10),
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: request.requestType == "loanRequest"
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
                                                      if (request.requestType == 'leaveRequest') ...[
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
                                                            "25 ${AppLocalizations.of(context)!.days}",
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
                                                      if (request.requestType == 'loanRequest') ...[
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
                                                              request.requestData != null &&
                                                                      request.requestData!.isNotEmpty
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
                                                      SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
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
                                                                        color: NasColors.completed,
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
                                                                Text(
                                                                  "➡️",
                                                                  style: GoogleFonts.inter(
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Colors.black,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            // Line after Req
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 20.0),
                                                              child: Container(
                                                                width: 40,
                                                                height: 2,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                            ...[
                                                              if (request.approvers != null && request.approvers!.isNotEmpty)
                                                                for (int i = 0; i < request.approvers!.length; i++) ...[
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
                                                                              color: _getColorForApproverStatus(
                                                                                  request.approvers![i].status),
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
                                                                        request.approvers![i].approverName ?? '---',
                                                                        style: GoogleFonts.inter(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  if (i != request.approvers!.length - 1)
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 20.0),
                                                                      child: Container(
                                                                        width: 40,
                                                                        height: 2,
                                                                        color: Colors.grey,
                                                                      ),
                                                                    ),
                                                                ]
                                                              else
                                                                Text(
                                                                  '---',
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 15,
                                                                    color: Colors.grey,
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                            ],
                                                            // Line before CEO
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 20.0),
                                                              child: Container(
                                                                width: 40,
                                                                height: 2,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                            // CEO
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
                                                                        color: allApproved ? NasColors.completed : NasColors.pending,
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
                                                                Text(
                                                                  allApproved ? "✅" : "⏳",
                                                                  style: GoogleFonts.inter(
                                                                    fontWeight: FontWeight.w500,
                                                                    color: Colors.black,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                          ],
                                                        ),
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
                              child: Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Lottie.asset('images/error.json'),
                                ),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return singletonClass
                                    .approverDataList.first.data!.data!.isEmpty
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
                                      final request = _approver!.toList()[index];
                                      final searchText = searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                        final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;

                                        if (!matchesName && !matchesId) {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                      String formatDate(String updatedAt) {
                                        DateTime updatedAtDateTime = DateTime.parse(updatedAt);
                                        return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
                                      }
                                      String date = formatDate(request.createdAt!);
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
                                                    Align(
                                                      alignment:
                                                      Alignment.topRight,
                                                      child: Text(
                                                        date,
                                                        style:
                                                        GoogleFonts
                                                            .inter(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
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
                                                                 _translateRequestSubtype2( request.subType !=
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
                                                                     : '', context),
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
                                                        SizedBox(width: 5),
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
                                                              : Icons.description_outlined,
                                                          size: 30,
                                                          color: Colors.black,
                                                        )
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
                                                            "25 ${AppLocalizations.of(context)!.days}",
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

                ],
              ],
            ],
          ),
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
      case 'Leave Request':
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
      case "Special leave Request":
        return localizations.specialLeaveRequest;
      case "Approval Document Request":
        return localizations.approvalDocumentRequest;
      default:
        return status!;
    }
  }




  ///Request subtype on get method
  String _translateRequestSubtype2(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Sick Leave':
        return localizations.sickLeave;
      case 'Annual Leave':
        return localizations.annualLeave;
      case 'Casual Leave':
        return localizations.casualLeave;
      case 'Advancesalaryrequest':
        return localizations.advanceSalaryRequest;
      case 'LongTermloanrequest':
        return localizations.longTermLoanRequest;
      case "Housingallowance":
        return localizations.housingAllowance;
      case "Travelingallowance":
        return localizations.travellingAllowance;
      case 'Salaryincrementalallowance':
        return localizations.salaryIncrementalAllowance;
      case "Salaryslip":
        return localizations.salarySlip;
      case "Promotionalletter":
        return localizations.promotionalLetter;
      case "Contract":
        return localizations.contract;
      case "ID Card":
        return localizations.idCard;
      case "Advanceexpense":
        return localizations.advanceExpense;
      case "Businessexpense":
        return localizations.businessExpense;
      case "Reimbursement":
        return localizations.reimbursement;
      case "Disbursement":
        return localizations.disbursement;
      case "Star":
        return localizations.star;
      case "Moon":
        return localizations.moon;
      case "Badbehaviour":
        return localizations.badBehaviour;
      case "Marraigeleave":
        return localizations.marriageLeave;
      case "Exams Leave":
        return localizations.examLeave;
      case "Exam Leave":
        return localizations.examLeave;
      case "Death Leave":
        return localizations.deathLeave;
      case "Specialdocument":
        return localizations.specialDocument;
      default:
        return status!;
    }
  }
  //Approve Colors
  Color _getColorForApproverStatus(String? approverStatus) {
    if (approverStatus == null ||
        approverStatus.isEmpty ||
        approverStatus == 'pending') {
      return NasColors.pending;
    } else {
      return NasColors
          .completed;
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
        return Colors.grey;
    }
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'leaveRequest':
        return 'images/time.png';
      case 'specialLeaveRequest':
        return 'images/leaveRequest.png';
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
        "specialLeaveRequest",
      ],
    };
    final uri = Uri.parse(
      '${singletonClass.baseURL}/request/approver/$employeeId?limit=$limit&page=$page',
    );
    print(uri);
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
        "specialLeaveRequest",
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
