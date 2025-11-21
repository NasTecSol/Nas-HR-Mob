import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/requests/allowance_and_salary_request_screen.dart';
import 'package:nashr/screens/requests/attendance_request_screen.dart';
import 'package:nashr/screens/requests/create_penalities_and_fines_request_screen.dart';
import 'package:nashr/screens/requests/create_request_screen.dart';
import 'package:nashr/screens/requests/document_request_screen.dart';
import 'package:nashr/screens/requests/expense_request_screen.dart';
import 'package:nashr/screens/requests/leave_request_screen.dart';
import 'package:nashr/screens/requests/loan_request_screen.dart';
import 'package:nashr/screens/requests/overtime_request_screen.dart';
import 'package:nashr/screens/requests/request_detail_screen.dart';
import 'package:nashr/screens/requests/self_request_detail_screen.dart';
import 'package:nashr/screens/requests/special_leave_request_screen.dart';
import 'package:nashr/singleton_class.dart';
import '../../request_controller/approver_request_data_model.dart';
import '../../request_controller/request_data_model.dart';
import '../../widgets/colors.dart';
import '../../widgets/loader.dart';

class RequestScreen extends StatefulWidget {
  final int selectedIndex;

  const RequestScreen({super.key, required this.selectedIndex});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  int _selectedOptionIndex = 0;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
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
    singletonClass.getSupervisorData();
    _fetchRequestData(0);
    _fetchApproverData(0);
    getRequestData();
    singletonClass.getApproverData();
    setState(() {
      getRequestData();
      singletonClass.getApproverData();
    });
    setState(() {
      _selectedOptionIndex = widget.selectedIndex;
    });
  }

  Future<void> fetchLatestRequestData() async {
    try {
      singletonClass.getApproverData();
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

  Future<void> _fetchApproverData(int page) async {
    setState(() {});

    final data = await singletonClass.getApproverData(page: page);
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
    setState(() {});
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

  ///Overlay

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
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: singletonClass
                            .companyDataList.first.data!.request!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final request = singletonClass
                              .companyDataList.first.data!.request![index];
                          if ((request.requestType == 'overTimeRequest' &&
                              singletonClass.policyModelDataList.first.data!.attendancePolicy!.overtimePolicy!.isAllowed == false) ||
                          request.requestType == 'complaintRequest' ||
                          request.requestType == 'approvalDoc' ||
                          request.requestType == 'payrollRequest'
                          ) {
                            return const SizedBox.shrink();
                          }

                          /// ✅ Step 1: Collect allowed submenus under "Approval" where accessType.add == true
                          final allowedRequestNames = <String>{};

                          final uiSettings = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data
                                  ?.uiSettings
                                  ?.uiModules ??
                              [];

                          for (var module in uiSettings) {
                            final moduleTitle =
                                module.title?.toString().trim().toLowerCase() ??
                                    '';

                            if (moduleTitle == 'approval') {
                              final subMenus = module.subMenu ?? [];

                              for (var sub in subMenus) {
                                final subTitle =
                                    sub.title?.toString().trim() ?? '';
                                final hasAddAccess =
                                    sub.accessType?.add == true;

                                if (subTitle.isNotEmpty && hasAddAccess) {
                                  allowedRequestNames.add(subTitle);
                                }
                              }
                            }
                          }

                          /// ✅ Step 2: Normalize both submenu title & request name for flexible comparison
                          String normalize(String text) {
                            return text
                                .trim()
                                .toLowerCase()
                                .replaceAll('requests', 'request')
                                .replaceAll(RegExp(r'\s+'), ' ');
                          }

                          final requestName =
                              normalize(request.requestName ?? '')
                                  .toLowerCase();

                          /// ✅ Step 3: Match if any allowed submenu title corresponds to this request
                          final isAllowed = allowedRequestNames.any((title) {
                            final normalized = normalize(title);
                            return normalized == requestName ||
                                normalized.contains(requestName) ||
                                requestName.contains(normalized);
                          });

                          /// ✅ Step 4: Hide request if not allowed
                          if (!isAllowed) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _removeOverlay();
                                  /// Allowance Increment (with grade check)
                                  if (request.requestType == 'allowanceIncrement' &&
                                      (singletonClass.getJWTModel()?.grade == 'L0' ||
                                          singletonClass.getJWTModel()?.grade == 'L1')) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AllowanceAndSalaryRequestScreen(
                                                            selectedRequest: request,
                                                            isTeam: false,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors.white,
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
                                                      AppLocalizations.of(context)!.yourSelf,
                                                      style: GoogleFonts.inter(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AllowanceAndSalaryRequestScreen(
                                                            selectedRequest: request,
                                                            isTeam: true,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor: Colors.white,
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
                                                      AppLocalizations.of(context)!.teams,
                                                      style: GoogleFonts.inter(
                                                        fontWeight: FontWeight.bold,
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
                                  }

                                  /// Overtime Request
                                  if (request.requestType == 'overTimeRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OvertimeRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Expense Request
                                  if (request.requestType == 'expenseRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ExpenseRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  // Document Request
                                  if (request.requestType == 'documentRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DocumentRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Loan Request
                                  if (request.requestType == 'loanRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoanRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Leave Request
                                  if (request.requestType == 'leaveRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeaveRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Special Leave Request
                                  if (request.requestType == 'specialLeaveRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SpecialLeaveRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Attendance Request
                                  if (request.requestType == 'attendanceRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AttendanceRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Penalties Request
                                  if (request.requestType == 'penalities_fines') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreatePenalitiesAndFinesRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }

                                  /// Default (if nothing matched)
                                  if (request.requestType != 'allowanceIncrement' &&
                                      request.requestType != 'overTimeRequest' &&
                                      request.requestType != 'expenseRequest' &&
                                      request.requestType != 'documentRequest' &&
                                      request.requestType != 'loanRequest' &&
                                      request.requestType != 'leaveRequest' &&
                                      request.requestType != 'specialLeaveRequest' &&
                                      request.requestType != 'attendanceRequest' &&
                                      request.requestType != 'penalities_fines')
                                  {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRequestScreen(
                                          selectedRequest: request,
                                          isTeam: false,
                                        ),
                                      ),
                                    );
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
                      singletonClass.getJWTModel()?.grade == 'L1' ||
                      singletonClass.getJWTModel()?.grade == 'L2' ||
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
                  if (singletonClass.roleAndAccessModelDataList.first.data!
                      .uiSettings!.uiModules!
                      .any((e) =>
                          e.title == 'Approval' && e.accessType!.add == true))
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
                  singletonClass.getJWTModel()?.grade == 'L1' ||
                  singletonClass.getJWTModel()?.grade == 'L2' ||
                  singletonClass.getJWTModel()?.grade == 'L3') ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildOptionsCard(
                          0, AppLocalizations.of(context)!.requests),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
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
                                            child: Lottie.asset(
                                                'images/empty.json'),
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
                                    final request =
                                        _request!.reversed.toList()[index];
                                    final searchText =
                                        searchController.text.toLowerCase();
                                    if (isSearching) {
                                      final matchesName = request.employeeName
                                              ?.toLowerCase()
                                              .contains(searchText) ??
                                          false;
                                      final matchesId = request.empId
                                              ?.toLowerCase()
                                              .contains(searchText) ??
                                          false;

                                      if (!matchesName && !matchesId) {
                                        return const SizedBox
                                            .shrink(); // hide if neither matches
                                      }
                                    }
                                    String formatDate(String updatedAt) {
                                      DateTime updatedAtDateTime =
                                          DateTime.parse(updatedAt);
                                      return DateFormat('dd-MM-yyyy')
                                          .format(updatedAtDateTime);
                                    }

                                    String date = formatDate(request.createdAt!);
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SelfRequestDetailScreen(
                                                        data1: request)));
                                      },
                                      child: Container(
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
                                                  if (DateTime.parse(request
                                                                  .createdAt!)
                                                              .toLocal()
                                                              .year ==
                                                          DateTime.now().year &&
                                                      DateTime.parse(request
                                                                  .createdAt!)
                                                              .toLocal()
                                                              .month ==
                                                          DateTime.now()
                                                              .month &&
                                                      DateTime.parse(request
                                                                  .createdAt!)
                                                              .toLocal()
                                                              .day ==
                                                          DateTime.now()
                                                              .day) ...[
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.blue,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                  ],
                                                  Row(
                                                    children: [
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
                                                                : request
                                                                            .requestData!
                                                                            .first
                                                                            .leaveType ==
                                                                        'casualLeave'
                                                                    ? Icons
                                                                        .beach_access_outlined
                                                                    : request.requestType ==
                                                                            'loanRequest'
                                                                        ? Icons
                                                                            .payments_outlined
                                                                        : Icons
                                                                            .description_outlined,
                                                        size: 30,
                                                        color: Colors.black,
                                                      ),
                                                      Spacer(),
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Text(
                                                          '${AppLocalizations.of(context)!.createAt} $date',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                                                                _translateRequestSubtype2(
                                                                    request.subType !=
                                                                            null
                                                                        ? request
                                                                            .subType!
                                                                            .replaceAllMapped(
                                                                              RegExp(r'([a-z])([A-Z])'),
                                                                              (Match match) => '${match.group(1)} ${match.group(2)}',
                                                                            )
                                                                            .replaceFirst(request.subType![0],
                                                                                request.subType![0].toUpperCase())
                                                                        : '',
                                                                    context),
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
                                                          color: _getColorForVerificationStatus(
                                                              request.status ??
                                                                  'default'),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            _translateStatus(
                                                                request.status,
                                                                context),
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
                                                  ///Request Data of every request
                                                  if(request.requestType == 'allowanceIncrement')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.date ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if(request.requestType == 'overTimeRequest')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.date ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if (request.requestType == "loanRequest")...[
                                                    ///Duration
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.duration}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  if(request.requestType == 'attendanceRequest')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.attendanceDate ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if (request.requestType == "expenseRequest")...[
                                                    ///expense Data
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.expense} ${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? (request.requestData!.first.expenseDate != null && request.requestData!.first.expenseDate!.isNotEmpty
                                                              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(request.requestData!.first.expenseDate!))
                                                              : "---")
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if(request.requestType == 'documentRequest')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.date ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if(request.requestType == 'leaveRequest')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.startDate ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        Text(
                                                          " - ",
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.endDate ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                  if(request.requestType == 'specialLeaveRequest')...[
                                                    ///date
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.date}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.startDate ?? "---"} - ${request.requestData!.first.endDate ?? "---"}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    ///duration
                                                    Row(
                                                      children: [
                                                        Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              "${AppLocalizations.of(context)!.duration}:",
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.black,
                                                                fontSize: 15,
                                                              ),
                                                            )
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          request.requestData != null && request.requestData!.isNotEmpty
                                                              ? "${request.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.days}"
                                                              : AppLocalizations.of(context)!.noData,
                                                          style: GoogleFonts.inter(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      ],
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
                              color: _requestCurrentPage == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              if (singletonClass.getJWTModel()?.grade == 'L0' ||
                  singletonClass.getJWTModel()?.grade == 'L1' ||
                  singletonClass.getJWTModel()?.grade == 'L2' ||
                  singletonClass.getJWTModel()?.grade == 'L3') ...[
                if (_selectedOptionIndex == 0) ...[
                  Expanded(
                    child: FutureBuilder(
                        future: getRequestData(),
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
                                              child: Lottie.asset(
                                                  'images/empty.json'),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .noData,
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
                                      final request =
                                          _request!.reversed.toList()[index];
                                      final searchText =
                                          searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName
                                                ?.toLowerCase()
                                                .contains(searchText) ??
                                            false;
                                        final matchesId = request.empId
                                                ?.toLowerCase()
                                                .contains(searchText) ??
                                            false;

                                        if (!matchesName && !matchesId) {
                                          return const SizedBox
                                              .shrink(); // hide if neither matches
                                        }
                                      }
                                      String formatDate(String updatedAt) {
                                        DateTime updatedAtDateTime =
                                            DateTime.parse(updatedAt);
                                        return DateFormat('dd-MM-yyyy')
                                            .format(updatedAtDateTime);
                                      }

                                      String date = formatDate(request.createdAt!);
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SelfRequestDetailScreen(
                                                          data1: request)));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                    if (DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .year ==
                                                            DateTime.now()
                                                                .year &&
                                                        DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .month ==
                                                            DateTime.now()
                                                                .month &&
                                                        DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .day ==
                                                            DateTime.now()
                                                                .day) ...[
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.blue,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                    ],
                                                    Row(
                                                      children: [
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
                                                                              .description_outlined,
                                                          size: 30,
                                                          color: Colors.black,
                                                        ),
                                                        Spacer(),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Text(
                                                            '${AppLocalizations.of(context)!.createAt} $date',
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 13,
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
                                                    SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            image:
                                                                const DecorationImage(
                                                              image: AssetImage(
                                                                  'images/DP.png'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
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
                                                                    fontSize:
                                                                        15,
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
                                                                  _translateRequestSubtype2(
                                                                      request.subType !=
                                                                              null
                                                                          ? request
                                                                              .subType!
                                                                              .replaceAllMapped(
                                                                                RegExp(r'([a-z])([A-Z])'),
                                                                                (Match match) => '${match.group(1)} ${match.group(2)}',
                                                                              )
                                                                              .replaceFirst(request.subType![0], request.subType![0].toUpperCase())
                                                                          : '',
                                                                      context),
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        15,
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
                                                        const SizedBox(
                                                            width: 5),
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
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    ///Request Data of every request
                                                    if(request.requestType == 'allowanceIncrement')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'overTimeRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if (request.requestType == "loanRequest")...[
                                                      ///Duration
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.duration}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'attendanceRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.attendanceDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if (request.requestType == "expenseRequest")...[
                                                      ///expense Data
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.expense} ${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? (request.requestData!.first.expenseDate != null && request.requestData!.first.expenseDate!.isNotEmpty
                                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(request.requestData!.first.expenseDate!))
                                                                : "---")
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'documentRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'leaveRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.startDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            " - ",
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.endDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'specialLeaveRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.startDate ?? "---"} - ${request.requestData!.first.endDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 15),
                                                      ///duration
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.duration}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.days}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
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
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child:
                                            Lottie.asset('images/empty.json'),
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
                                color: _requestCurrentPage == index
                                    ? Colors.white
                                    : Colors.black,
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
                        future: singletonClass.getApproverData(),
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
                                              child: Lottie.asset(
                                                  'images/empty.json'),
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of(context)!
                                                .noData,
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
                                      final request =
                                          _approver!.toList()[index];
                                      final searchText =
                                          searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName
                                                ?.toLowerCase()
                                                .contains(searchText) ??
                                            false;
                                        final matchesId = request.empId
                                                ?.toLowerCase()
                                                .contains(searchText) ??
                                            false;

                                        if (!matchesName && !matchesId) {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                      String formatDate(String updatedAt) {
                                        DateTime updatedAtDateTime =
                                            DateTime.parse(updatedAt);
                                        return DateFormat('dd-MM-yyyy')
                                            .format(updatedAtDateTime);
                                      }

                                      String date = formatDate(request.createdAt!);
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RequestDetailScreen(
                                                          dataApprover:
                                                              request)));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                    if (DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .year ==
                                                            DateTime.now()
                                                                .year &&
                                                        DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .month ==
                                                            DateTime.now()
                                                                .month &&
                                                        DateTime.parse(request
                                                                    .createdAt!)
                                                                .toLocal()
                                                                .day ==
                                                            DateTime.now()
                                                                .day) ...[
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.blue,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                    ],
                                                    Row(
                                                      children: [
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
                                                                              .description_outlined,
                                                          size: 30,
                                                          color: Colors.black,
                                                        ),
                                                        Spacer(),
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Text(
                                                            '${AppLocalizations.of(context)!.createAt} $date',
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 13,
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
                                                                    .circular(
                                                                        15),
                                                            image:
                                                                const DecorationImage(
                                                              image: AssetImage(
                                                                  'images/DP.png'),
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
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
                                                                    fontSize:
                                                                        15,
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
                                                                  _translateRequestSubtype2(
                                                                      request.subType !=
                                                                              null
                                                                          ? request
                                                                              .subType!
                                                                              .replaceAllMapped(
                                                                                RegExp(r'([a-z])([A-Z])'),
                                                                                (Match match) => '${match.group(1)} ${match.group(2)}',
                                                                              )
                                                                              .replaceFirst(request.subType![0], request.subType![0].toUpperCase())
                                                                          : '',
                                                                      context),
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        15,
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
                                                        const SizedBox(
                                                            width: 5),
                                                        Container(
                                                          height: 30,
                                                          width: 75,
                                                          decoration:
                                                          BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            color: _getColorForVerificationStatus(
                                                                "${request.approvers!.firstWhere((approver) => approver.approverId == singletonClass.getJWTModel()?.employeeId,).status}"),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              _translateStatus(
                                                                request.approvers!.firstWhere((approver) => approver.approverId == singletonClass.getJWTModel()?.employeeId,).status,
                                                                context,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              style: GoogleFonts.inter(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    ///Request Data of every request
                                                    if(request.requestType == 'allowanceIncrement')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'overTimeRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if (request.requestType == "loanRequest")...[
                                                      ///Duration
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.duration}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'attendanceRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.attendanceDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if (request.requestType == "expenseRequest")...[
                                                      ///expense Data
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.expense} ${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.expenseDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'documentRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.date ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'leaveRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.startDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            " - ",
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.endDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                    if(request.requestType == 'specialLeaveRequest')...[
                                                      ///date
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.date}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.startDate ?? "---"} - ${request.requestData!.first.endDate ?? "---"}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 15),
                                                      ///duration
                                                      Row(
                                                        children: [
                                                          Align(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              child: Text(
                                                                "${AppLocalizations.of(context)!.duration}:",
                                                                style: GoogleFonts.inter(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.black,
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            request.requestData != null && request.requestData!.isNotEmpty
                                                                ? "${request.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.days}"
                                                                : AppLocalizations.of(context)!.noData,
                                                            style: GoogleFonts.inter(
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.grey,
                                                              fontSize: 15,
                                                            ),
                                                          )
                                                        ],
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
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 200,
                                        width: 200,
                                        child:
                                            Lottie.asset('images/empty.json'),
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
                              _fetchApproverData(index);
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
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.black,
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

  //Request
  Future<RequestDataModel?> getRequestData(
      {int page = 0, int limit = 30}) async {
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
        "attendanceRequest",
        "overTimeRequest"
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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

///DUMMY MODEL

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
