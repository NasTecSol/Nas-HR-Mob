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
import 'package:nashr/screens/requests/create_remote_request_screen.dart';
import 'package:nashr/screens/requests/create_request_screen.dart';
import 'package:nashr/screens/requests/document_request_screen.dart';
import 'package:nashr/screens/requests/expense_request_screen.dart';
import 'package:nashr/screens/requests/file_complaints_screen.dart';
import 'package:nashr/screens/requests/leave_request_screen.dart';
import 'package:nashr/screens/requests/loan_request_screen.dart';
import 'package:nashr/screens/requests/overtime_request_screen.dart';
import 'package:nashr/screens/requests/request_detail_screen.dart';
import 'package:nashr/screens/requests/resignation_request_screen.dart';
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
  Future<ApproverRequestData?>? _approvalsFuture;
  bool _isTeamChecked = false;
  int _totalApprovedRequestsCount = 0;
  int _totalPendingApprovalsCount = 0;

  @override
  void initState() {
    super.initState();
    singletonClass.getSupervisorData();
    _fetchRequestData(0);
    _fetchApproverData(0);
    _fetchTotalApprovedRequestsCount();
    _fetchTotalPendingApprovalsCount();
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
      _fetchTotalApprovedRequestsCount();
      _fetchTotalPendingApprovalsCount();
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<ApproverRequestData?> _fetchApproverData(int page) {
    final future = _fetchApproverDataAsync(page);
    setState(() {
      _approvalsFuture = future;
    });
    return future;
  }

  Future<ApproverRequestData?> _fetchApproverDataAsync(int page) async {
    final grade = singletonClass.getJWTModel()?.grade;
    final isTargetGrade = ['L0', 'L1'].contains(grade);

    ApproverRequestData? data;
    if (isTargetGrade && !_isTeamChecked) {
      final companyId = singletonClass.selectedCompanyId;
      final branchId = singletonClass.branchID;
      if (companyId != null && branchId != null && companyId.isNotEmpty && branchId.isNotEmpty) {
        data = await singletonClass.getRequestByCompanyAndBranch(companyId, branchId, page: page);
      }
    } else {
      data = await singletonClass.getApproverData(page: page);
    }

    if (data != null && data.data != null) {
      setState(() {
        _approver = data!.data!.data;
        _totalPages = data.data!.totalPages ?? 1;
        _currentPage = page;
      });
    } else {
      setState(() {
        _approver = [];
        _totalPages = 1;
        _currentPage = 0;
      });
    }
    return data;
  }

  Future<void> _fetchRequestData(int page) async {
    setState(() {});

    if (page == 0) {
      _requestTotalPages = 1;
    }

    int apiPage = page;
    if (_requestTotalPages > 1) {
      apiPage = _requestTotalPages - 1 - page;
    }

    var data = await getRequestData(page: apiPage);

    if (_requestTotalPages == 1 &&
        data != null &&
        data.data != null &&
        data.data!.totalPages != null &&
        data.data!.totalPages! > 1) {
      final totalP = data.data!.totalPages!;
      _requestTotalPages = totalP;
      apiPage = totalP - 1 - page;
      data = await getRequestData(page: apiPage);
    }

    if (data != null && data.data != null) {
      final list = data.data!.data ?? [];
      list.sort((a, b) {
        final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
      setState(() {
        _request = list;
        _requestTotalPages = data?.data?.totalPages ?? 1;
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
                        itemCount: singletonClass.companyDataList.isNotEmpty
                            ? (singletonClass.companyDataList.first.data?.request?.length ?? 0)
                            : 0,
                        itemBuilder: (context, index) {
                          final companyList = singletonClass.companyDataList;
                          final policyList = singletonClass.policyModelDataList;

                          if (companyList.isEmpty ||
                              policyList.isEmpty ||
                              companyList.first.data?.request == null ||
                              policyList.first.data?.attendancePolicy?.overtimePolicy == null) {
                            return const SizedBox.shrink();
                          }

                          final request = companyList.first.data!.request![index];

                          final isOvertimeBlocked =
                              request.requestType == 'overTimeRequest' &&
                                  policyList.first.data!.attendancePolicy!.overtimePolicy!.isAllowed == false;

                          if (isOvertimeBlocked ||
                              request.requestType == 'approvalDoc' ||
                              request.requestType == 'payrollRequest') {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _removeOverlay();
                                  /// Allowance Increment (with grade check)
                                  if (request.requestType == 'allowanceIncrement' || request.requestType == 'allowance_Increment' || request.requestType == 'allowance_increment'){
                                    if ((singletonClass.getJWTModel()?.grade == 'L0' ||
                                        singletonClass.getJWTModel()?.grade == 'L1')){
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
                                    } else {
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
                                    }
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
                                  ///Complaint Request
                                  if (request.requestType == 'complaintRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FileComplaintsScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }
                                  ///Remote Request
                                  if (request.requestType == 'remoteRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRemoteRequestScreen(
                                          selectedRequest: request,
                                        ),
                                      ),
                                    );
                                  }
                                  ///Remote Request
                                  if (request.requestType == 'resignationRequest') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResignationRequestScreen(
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

                                  /// Document Request
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
                                  if (request.requestType == 'penalities_fines' || request.requestType == 'penalties_fines') {
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
                                      request.requestType != 'allowance_increment' &&
                                      request.requestType != 'allowance_Increment' &&
                                      request.requestType != 'overTimeRequest' &&
                                      request.requestType != 'expenseRequest' &&
                                      request.requestType != 'documentRequest' &&
                                      request.requestType != 'loanRequest' &&
                                      request.requestType != 'leaveRequest' &&
                                      request.requestType != 'specialLeaveRequest' &&
                                      request.requestType != 'attendanceRequest' &&
                                      request.requestType != 'penalities_fines' &&
                                      request.requestType != 'penalties_fines' &&
                                      request.requestType != 'resignationRequest' &&
                                      request.requestType != 'complaintRequest' &&
                                      request.requestType != 'remoteRequest' )
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

  Widget _buildHeader(BuildContext context, bool showRequest) {
    final title = singletonClass.getJWTModel()?.grade == 'L4'
        ? AppLocalizations.of(context)!.requests
        : AppLocalizations.of(context)!.requestAndApproval;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (showRequest == true)
                    GestureDetector(
                      onTap: () {
                        _overlayEntry = _createOverlayEntry();
                        Overlay.of(context).insert(_overlayEntry!);
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.requests,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: NasColors.darkBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) {
                          setState(() {});
                        },
                        cursorColor: NasColors.darkBlue,
                        style: GoogleFonts.inter(fontSize: 14, color: NasColors.darkBlue),
                        decoration: InputDecoration(
                          hintText: '${AppLocalizations.of(context)!.search}...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          searchController.clear();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRequest = singletonClass.roleAndAccessModelDataList.first.data
        ?.uiSettings
        ?.uiModules
        ?.any((module) {
      if (module.title?.trim().toLowerCase() != 'approval') return false;

      final requests = module.subMenu
          ?.where((item) =>
      item.title?.trim().toLowerCase() == 'requests')
          .toList();

      return requests?.any((req) =>
          (req.subMenu ?? [])
              .any((sub) => sub.accessType?.add == true)) ??
          false;
    }) ??
        false;

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context, showRequest),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                color: NasColors.darkBlue,
                backgroundColor: Colors.white,
                onRefresh: fetchLatestRequestData,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (singletonClass.getJWTModel()?.grade == 'L0' ||
                        singletonClass.getJWTModel()?.grade == 'L1' ||
                        singletonClass.getJWTModel()?.grade == 'L2' ||
                        singletonClass.getJWTModel()?.grade == 'L3') ...[
                      _buildSegmentedControl(),
                    ],
              const SizedBox(height: 10),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  itemCount: _request!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final request = _request![index];
                                    final searchText = searchController.text.toLowerCase();
                                    if (isSearching) {
                                      final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                      final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;
                                      if (!matchesName && !matchesId) {
                                        return const SizedBox.shrink();
                                      }
                                    }
                                    return _buildUnifiedRequestCard(
                                      context: context,
                                      request: request,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SelfRequestDetailScreen(data1: request),
                                          ),
                                        );
                                      },
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
                          width: 30,
                          height: 30,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: _request!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final request = _request![index];
                                      final searchText = searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                        final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;
                                        if (!matchesName && !matchesId) {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                      return _buildUnifiedRequestCard(
                                        context: context,
                                        request: request,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SelfRequestDetailScreen(data1: request),
                                            ),
                                          );
                                        },
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
                            width: 30,
                            height: 30,
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
                  if (_selectedOptionIndex == 1 &&
                      ['L0', 'L1', 'L2'].contains(singletonClass.getJWTModel()?.grade)) ...[
                    Row(
                      children: [
                        _buildBranchDropdown(context),
                        const Spacer(),
                        _buildLabeledCheckbox(
                          label: AppLocalizations.of(context)!.teams,
                          value: _isTeamChecked,
                          enabled: singletonClass.branchID != null,
                          onChanged: _onTeamCheckboxChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: FutureBuilder(
                        future: _approvalsFuture,
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
                            return (_approver == null || _approver!.isEmpty)
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: _approver!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final request = _approver![index];
                                      final searchText = searchController.text.toLowerCase();
                                      if (isSearching) {
                                        final matchesName = request.employeeName?.toLowerCase().contains(searchText) ?? false;
                                        final matchesId = request.empId?.toLowerCase().contains(searchText) ?? false;
                                        if (!matchesName && !matchesId) {
                                          return const SizedBox.shrink();
                                        }
                                      }
                                      return _buildUnifiedRequestCard(
                                        context: context,
                                        request: request,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RequestDetailScreen(dataApprover: request),
                                            ),
                                          );
                                        },
                                        isApproval: true,
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
                            width: 30,
                            height: 30,
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
    ),
  ],
),
);
  }

  Widget _buildSegmentedControl() {
    return  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSegmentedTab(0, AppLocalizations.of(context)!.requests, _totalApprovedRequestsCount),
         const SizedBox(width: 5),
        _buildSegmentedTab(1, AppLocalizations.of(context)!.approvals, _totalPendingApprovalsCount),
        ],
      );
  }

  Widget _buildSegmentedTab(int index, String label, int badgeCount) {
    final isSelected = _selectedOptionIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? NasColors.darkBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.inter(
                      color: isSelected ? NasColors.darkBlue : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
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
      case 'Penalty And Fine Requests':
        return localizations.penaltiesAndFine;
      case 'penalties_fines':
        return localizations.penaltiesAndFine;
      case 'OverTime':
        return localizations.overTime;
      case 'Training':
        return localizations.training;
      case "Complaint Request":
        return localizations.complaints;
      case "Allowance Increment":
        return localizations.allowanceIncrement;
      case "allowance_Increment":
        return localizations.allowanceIncrement;
      case 'Document Request':
        return localizations.documentRequest;
      case "Expense Request":
        return localizations.expenseRequest;
      case "Special leave Request":
        return localizations.specialLeaveRequest;
      case "Approval Document Request":
        return localizations.approvalDocumentRequest;
      case "Remote Request":
        return localizations.remoteRequest;
      case "Attendance Request":
        return localizations.attendanceRequest;
      case "Short Leave":
        return localizations.shortLeaves;
      case "Resignation Request":
        return localizations.resignationRequest;
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
      case 'allowance_increment':
        return 'images/creditCard.png';
      case 'documentRequest':
        return 'images/files.png';
      case 'expenseRequest':
        return 'images/loan.png';
      case 'complaintRequest':
        return 'images/Complain.png';
      case 'penalities_fines':
        return 'images/Penalties.png';
      case 'attendanceRequest':
        return 'images/attendance.png';
      case 'remoteRequest':
        return 'images/pc.png';
      case 'shortLeave':
        return 'images/clocking.png';
      case 'resignationRequest':
        return 'images/clock.png';
      default:
        return 'images/OverTime.png';
    }
  }

  //Request
  Future<RequestDataModel?> getRequestData(
      {int page = 0, int limit = 100}) async {
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
        "overTimeRequest",
        "remoteRequest",
        "resignationRequest",
        "complaintRequest"
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

  Future<void> _onBranchSelected(String value) async {
    setState(() => isLoading = true);
    try {
      singletonClass.branchID = value;
      dynamic selectedBr;
      for (var b in singletonClass.availableBranches) {
        if (b.branchId.toString() == value) {
          selectedBr = b;
          break;
        }
      }
      if (selectedBr != null) {
        singletonClass.branchName = selectedBr.branchName ?? '';
      }

      _isTeamChecked = false;
      await _fetchApproverData(0);
      await _fetchTotalPendingApprovalsCount();
    } catch (e) {
      print("Error selecting branch: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onTeamCheckboxChanged(bool? value) async {
    setState(() {
      _isTeamChecked = value ?? false;
    });
    await _fetchApproverData(0);
    await _fetchTotalPendingApprovalsCount();
  }

  Widget _buildBranchDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: _onBranchSelected,
      itemBuilder: (_) => singletonClass.availableBranches
          .map((b) => PopupMenuItem<String>(
        value: b.branchId,
        child: Text(b.branchName ?? '---',
            style: GoogleFonts.inter(fontSize: 14)),
      ))
          .toList(),
      child: Container(
        height: 38,
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/site.png', height: 14, width: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                singletonClass.branchName?.isNotEmpty == true
                    ? singletonClass.branchName!
                    : (singletonClass.availableBranches.isNotEmpty
                    ? singletonClass.availableBranches.first.branchName ?? '---'
                    : '---'),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool enabled = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              activeColor: NasColors.onTime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: enabled ? onChanged : null,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled ? NasColors.darkBlue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUnifiedRequestCard({
    required BuildContext context,
    required dynamic request,
    required VoidCallback onTap,
    bool isApproval = false,
  }) {
    String formatDate(String createdAt) {
      DateTime dateTime = (DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0));
      return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    }

    final dateStr = request.createdAt != null ? formatDate(request.createdAt!) : '---';
    final status = request.status ?? 'pending';
    final statusColor = _getColorForVerificationStatus(status);
    final statusLabel = _translateStatus(status, context);

    // Check if new today
    bool isNewToday = false;
    if (request.createdAt != null) {
      try {
        final parsed = DateTime.parse(request.createdAt!).toLocal();
        final now = DateTime.now();
        isNewToday = parsed.year == now.year && parsed.month == now.month && parsed.day == now.day;
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row (ID and date)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NasColors.darkBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.empId ?? '---',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isNewToday)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Main Info Row (Avatar + Name + Status Badges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('images/DP.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName ?? '---',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _translateRequestSubtype2(
                              request.subType != null
                                  ? request.subType!
                                      .replaceAllMapped(
                                        RegExp(r'([a-z])([A-Z])'),
                                        (Match match) => '${match.group(1)} ${match.group(2)}',
                                      )
                                      .replaceFirst(request.subType![0], request.subType![0].toUpperCase())
                                  : '',
                              context),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subtle divider before details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Divider(color: Colors.grey.shade100, height: 16, thickness: 1),
            ),

            // Card specific details
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildRequestDetailsList(context, request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRequestDetailsList(BuildContext context, dynamic request) {
    final list = <Widget>[];

    void addDetailRow(IconData icon, String label, String value) {
      if (list.isNotEmpty) {
        list.add(const SizedBox(height: 6));
      }
      list.add(
        Row(
          children: [
            Icon(icon, size: 16, color: NasColors.darkBlue.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              "$label: ",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final reqType = request.requestType;
    final firstData = (request.requestData != null && request.requestData!.isNotEmpty)
        ? request.requestData!.first
        : null;

    if (reqType == 'allowanceIncrement' || reqType == 'allowance_Increment') {
      final date = (firstData != null && firstData.effectiveDate != null && firstData.effectiveDate.toString().isNotEmpty)
          ? singletonClass.formatDate2(firstData.effectiveDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.date, date);
    } 
    else if (reqType == 'overTimeRequest') {
      final date = (firstData != null && firstData.date != null && firstData.date.toString().isNotEmpty)
          ? singletonClass.formatDate2(firstData.date.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.date, date);
    } 
    else if (reqType == 'loanRequest') {
      final amount = (firstData != null && firstData.loanAmount != null)
          ? firstData.loanAmount.toString()
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.payments_outlined, AppLocalizations.of(context)!.amount, amount);
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    } 
    else if (reqType == 'attendanceRequest') {
      final date = (firstData != null && firstData.date != null && firstData.attendanceDate.toString().isNotEmpty)
          ? singletonClass.formatDate2(firstData.attendanceDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.date, date);
      
      final attendanceTime = (firstData != null && firstData.attendanceTime != null) ? singletonClass.formatDateTime(firstData.attendanceTime!) : '---';
      final punchingType = (firstData != null && firstData.punchingType != null) ? firstData.punchingType! : '---';
      addDetailRow(Icons.fingerprint_outlined, punchingType , attendanceTime);
    }

    else if (reqType == 'expenseRequest') {
      final amount = (firstData != null && firstData.totalAmount != null)
          ? firstData.totalAmount.toString()
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.payments_outlined, AppLocalizations.of(context)!.amount, amount);
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    } 
    else if (reqType == 'documentRequest') {
      final subTypeLabel = (request.subType != null) ? request.subType! : '---';
      addDetailRow(Icons.badge_outlined, AppLocalizations.of(context)!.type, subTypeLabel);
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    } 
    else if (reqType == 'leaveRequest') {
      final start = (firstData != null && firstData.startDate != null)
          ? singletonClass.formatDate2(firstData.startDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      final end = (firstData != null && firstData.endDate != null)
          ? singletonClass.formatDate2(firstData.endDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.startDate, start);
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.endDate, end);
    } 
    else if (reqType == 'specialLeaveRequest') {
      final start = (firstData != null && firstData.startDate != null)
          ? singletonClass.formatDate2(firstData.startDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      final end = (firstData != null && firstData.endDate != null)
          ? singletonClass.formatDate2(firstData.endDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.startDate, start);
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.endDate, end);
    } 
    else if (reqType == 'remoteRequest') {
      final start = (firstData != null && firstData.startDate != null)
          ? singletonClass.formatDate2(firstData.startDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      final end = (firstData != null && firstData.endDate != null)
          ? singletonClass.formatDate2(firstData.endDate.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.startDate, start);
      addDetailRow(Icons.date_range_outlined, AppLocalizations.of(context)!.endDate, end);
    } 
    else if (reqType == 'resignationRequest') {
      final date = (firstData != null && firstData.date != null && firstData.date.toString().isNotEmpty)
          ? singletonClass.formatDate2(firstData.date.toString(), context)
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.calendar_today_outlined, AppLocalizations.of(context)!.date, date);
    } 
    else if (reqType == 'complaintRequest') {
      final type = (request.subType != null) ? request.subType! : '---';
      addDetailRow(Icons.badge_outlined, AppLocalizations.of(context)!.type, type);
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    } 
    else if (reqType == 'penalities_fines' || reqType == 'penalties_fines') {
      final type = (request.subType != null) ? request.subType! : '---';
      addDetailRow(Icons.badge_outlined, AppLocalizations.of(context)!.type, type);
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    } 
    else {
      final reason = (request.reason != null && request.reason.toString().isNotEmpty)
          ? request.reason!
          : AppLocalizations.of(context)!.noData;
      addDetailRow(Icons.description_outlined, AppLocalizations.of(context)!.reason, reason);
    }

    return list;
  }

  Future<void> _fetchTotalApprovedRequestsCount() async {
    final count = await singletonClass.fetchTotalApprovedRequestsCount();
    if (mounted) {
      setState(() {
        _totalApprovedRequestsCount = count;
      });
    }
  }

  Future<void> _fetchTotalPendingApprovalsCount() async {
    final count = await singletonClass.fetchTotalPendingApprovalsCount(isTeamChecked: _isTeamChecked);
    if (mounted) {
      setState(() {
        _totalPendingApprovalsCount = count;
      });
    }
  }
}

///DUMMY MODEL

class SearchedResult {
  dynamic empId;
  dynamic employeeName;
  dynamic severity;
  dynamic netSalary;
  dynamic annualLeaveRemaining;

  SearchedResult({
    this.empId,
    this.employeeName,
    this.severity,
    this.netSalary,
    this.annualLeaveRemaining
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
      'netSalary': netSalary,
      'annualLeaveRemaining': annualLeaveRemaining,
    };
  }
}
