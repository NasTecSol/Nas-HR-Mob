import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../request_controller/company_model.dart';
import '../../widgets/loader.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../request_controller/company_model.dart' show Request, SubTypes;
import 'package:flutter/foundation.dart';
import '../../request_controller/company_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/attachment_response_model.dart';

class FileComplaintsScreen extends StatefulWidget {
  final Request? selectedRequest;
  const FileComplaintsScreen({super.key, this.selectedRequest});

  @override
  State<FileComplaintsScreen> createState() => _FileComplaintsScreenState();
}

class _FileComplaintsScreenState extends State<FileComplaintsScreen> {
  SingletonClass singletonClass = SingletonClass();
  SubTypes? _selectedSubType;
  List<SubTypes> subTypeList = [];
  bool isLoading = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? startDate;
  PlatformFile? selectedFile;
  String _characterCount = "0/300";

  @override
  void initState() {
    super.initState();
    singletonClass.getCompanyData();
    _filterComplaintRequests();
  }

  void _filterComplaintRequests() {
    final complaints = singletonClass.companyDataList.first.data?.request
        ?.where((request) => request.requestType == "complaintRequest")
        .toList();

    if (complaints != null && complaints.isNotEmpty) {
      subTypeList = complaints
          .expand((request) => (request.subTypes ?? []).cast<SubTypes>())
          .toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.subType, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: DropdownButtonFormField<SubTypes>(
                                  dropdownColor: Colors.white,
                                  isExpanded: true,
                                  value: subTypeList.contains(_selectedSubType) ? _selectedSubType : null,
                                  validator: (value) {
                                    if (value == null) return AppLocalizations.of(context)!.selectSubType;
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  hint: Text(
                                    _translateRequest(widget.selectedRequest?.requestName, context),
                                    style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                                  ),
                                  items: subTypeList.map((SubTypes subType) {
                                    return DropdownMenuItem<SubTypes>(
                                      value: subType,
                                      child: Text(
                                        _translateRequestSubtype(subType.requestName!, context),
                                        style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (SubTypes? newValue) => setState(() => _selectedSubType = newValue),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(AppLocalizations.of(context)!.selectDate, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(primary: NasColors.darkBlue, onPrimary: Colors.white, onSurface: Colors.black),
                                          dialogBackgroundColor: Colors.white,
                                          textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: NasColors.darkBlue)),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) setState(() => startDate = date);
                                },
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        startDate == null ? "DD/MM/YYYY" : DateFormat('yyyy-MM-dd').format(startDate!),
                                        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                                      ),
                                      const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(AppLocalizations.of(context)!.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _title,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: NasColors.darkBlue)),
                                  hintText: AppLocalizations.of(context)!.typeYourTitleHere,
                                  hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 20),

                              Text(AppLocalizations.of(context)!.notes, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _notes,
                                maxLength: 300,
                                maxLines: 5,
                                onChanged: (text) => setState(() => _characterCount = "${text.length}/300"),
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: NasColors.darkBlue)),
                                  hintText: AppLocalizations.of(context)!.typeYourComplainHere,
                                  hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                                  counterText: _characterCount,
                                  counterStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(AppLocalizations.of(context)!.maximum300, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey)),
                              
                              if (_selectedSubType != null && _selectedSubType!.docRequired == true) ...[
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: () async {
                                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                                    if (result != null && result.files.single.path != null) {
                                      final PlatformFile file = result.files.single;
                                      setState(() => selectedFile = file);
                                      final results = await uploadDocuments(file);
                                      final bool success = results["success"] as bool;
                                      final String message = results["message"] as String;
                                      if (!success && context.mounted) {
                                        setState(() => selectedFile = null);
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: Text(AppLocalizations.of(context)!.uploadFailedTitle),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: Text(AppLocalizations.of(context)!.ok, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.add, color: Colors.black, size: 20),
                                      const SizedBox(width: 5),
                                      Text(AppLocalizations.of(context)!.attachDocuments, textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                                      const SizedBox(width: 10),
                                      if (selectedFile != null)
                                        Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.topRight,
                                          children: [
                                            ClipOval(child: Image.file(File(selectedFile!.path!), width: 80, height: 80, fit: BoxFit.cover)),
                                            Positioned(
                                              top: -5,
                                              right: -5,
                                              child: GestureDetector(
                                                onTap: () => setState(() => selectedFile = null),
                                                child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [NasColors.darkBlue, NasColors.lightBlue]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () { if (_formKey.currentState!.validate()) { postRequest(); } },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                    child: Text(AppLocalizations.of(context)!.requests, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) Loader(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        boxShadow: [BoxShadow(color: NasColors.darkBlue.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40, width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(AppLocalizations.of(context)!.applyRequests,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Row(children: [
                  Container(height: 38, width: 38,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_translateBottomText(widget.selectedRequest?.requestName, context),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.75))),
                    Text(_translateRequest(widget.selectedRequest?.requestName, context),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ])),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translateRequestSubtype(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Complaint Against Colleague':
        return localizations.complaintAgainstColleague;
      case 'Complaint Against Supervisor':
        return localizations.complaintAgainstSupervisor;
      case 'General Complaint':
        return localizations.generalComplaint;
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

  String _translateBottomText(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Leave Request':
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
      case "Special leave Request":
        return localizations.specialLeaveRequestBottom;
      case "Approval Document Request":
        return localizations.approvalDocumentRequestBottom;
      default:
        return status ?? '';
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
        return status ?? '';
    }
  }

  /// APi methods
  Future<Map<String, dynamic>> uploadDocuments(PlatformFile file) async {
    try {
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }

      setState(() => isLoading = true);

      final uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        final attachmentResponse = AttachmentResponse.fromJson(decodedJson);
        singletonClass.attachmentResponseDataList.clear();
        singletonClass.attachmentResponseDataList = [attachmentResponse];
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Upload failed: ${response.statusCode}\n\n$responseBody"};
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<void> postRequest() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String? companyId = singletonClass.getJWTModel()?.companyId;
    String? branchId = singletonClass.getJWTModel()?.branchId;
    String? firstName = singletonClass.employeeDataList.first.data.first.firstName;
    String? middleName = singletonClass.employeeDataList.first.data.first.middleName;
    String? lastName = singletonClass.employeeDataList.first.data.first.lastName;
    String? employeeName = [firstName, middleName, lastName]
        .where((name) => name != null && name.isNotEmpty)
        .join(' ');

    String? selectedRequestType = "complaintRequest";
    String? selectedSubType = _selectedSubType?.requestType;

    // Check if requestType and subType are selected
    if (selectedSubType == null) {
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

    List<Map<String, dynamic>> requestData = [];

    if (selectedRequestType == 'complaintRequest') {
      requestData.add({
        "title": _title.text,
        "message": _notes.text,
      });
    }

    // Construct the data map for the API call
    Map<String, dynamic> data = {
      "employeeId": employeeId,
      "companyId": companyId,
      "empId": singletonClass.getJWTModel()?.empId,
      "employeeName": employeeName,
      "branchId": branchId,
      "policyId": "${singletonClass.companyDataList.first.data!.policies!.first.policyId}",
      "requestType": selectedRequestType,
      "subType": selectedSubType,
      "requestData": requestData,
      "approvers": [],
      "reason": _notes.text,
      "attachments": [],
    };

    String body = json.encode(data);
    debugPrint(body);
    var uri = Uri.parse('${singletonClass.baseURL}/request/create');
    debugPrint("$uri");
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
          headers: singletonClass.getHeaders()
      );

      setState(() {
        isLoading = false;
      });

      final decodedResponse = json.decode(response.body);
      debugPrint(decodedResponse);

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
      debugPrint('Error: $e');
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
}
