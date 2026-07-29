import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/singleton_class.dart';
import '../../request_controller/attachment_response_model.dart';
import '../../request_controller/company_model.dart';
import '../../widgets/colors.dart';
import '../../widgets/loader.dart';
import '../main_screen.dart';

class ExpenseRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const ExpenseRequestScreen({super.key, this.selectedRequest});

  @override
  State<ExpenseRequestScreen> createState() => _ExpenseRequestScreenState();
}

class _ExpenseRequestScreenState extends State<ExpenseRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? dateTime;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController _amountOfExpense = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  PlatformFile? selectedFile;
  SubTypes? _selectedSubType;
  String? selectedCategory;
  String? selectedPaymentMethods;
  String? selectedTransactionType;

  @override
  void dispose() {
    notesController.dispose();
    _amountOfExpense.dispose();
    _purpose.dispose();
    super.dispose();
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: NasColors.darkBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SubTypes> subTypeList = widget.selectedRequest?.subTypes ?? [];

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard(
                          title: _translateRequest(widget.selectedRequest?.requestName, context),
                          child: DropdownButtonFormField<SubTypes>(
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            value: subTypeList.contains(_selectedSubType) ? _selectedSubType : null,
                            validator: (value) {
                              if (value == null) {
                                return AppLocalizations.of(context)!.selectSubType;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(''),
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
                        
                        _buildCard(
                          title: AppLocalizations.of(context)!.category,
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            value: selectedCategory,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.pleaseSelectCategory;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.selectCategory),
                            hint: Text(
                              AppLocalizations.of(context)!.selectCategory,
                              style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                            ),
                            items: ["travel", "meal", "supplies"].map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) => setState(() => selectedCategory = newValue),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.paymentMethods,
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            value: selectedPaymentMethods,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.pleaseSelectPaymentMethod;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.selectPaymentMethod),
                            hint: Text(
                              AppLocalizations.of(context)!.selectPaymentMethod,
                              style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                            ),
                            items: ["Cash", "Personal Card", "Company Card"].map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) => setState(() => selectedPaymentMethods = newValue),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.transactionType,
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            value: selectedTransactionType,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.pleaseSelectTransactionType;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.selectTransactionType),
                            hint: Text(
                              AppLocalizations.of(context)!.selectTransactionType,
                              style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                            ),
                            items: ["Deposit", "Collection"].map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) => setState(() => selectedTransactionType = newValue),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.date,
                          child: InkWell(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: dateTime ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: NasColors.darkBlue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: NasColors.darkBlue,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) setState(() => dateTime = date);
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
                                    dateTime == null
                                        ? AppLocalizations.of(context)!.datePlaceholder
                                        : DateFormat('yyyy-MM-dd').format(dateTime!),
                                    style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.amount,
                          child: TextFormField(
                            cursorColor: Colors.grey,
                            controller: _amountOfExpense,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.enterAmountValidation;
                              }
                              if (double.tryParse(value) == null) {
                                return AppLocalizations.of(context)!.enterValidNumber;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.enterExpenseAmount),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.purpose,
                          child: TextFormField(
                            cursorColor: Colors.grey,
                            controller: _purpose,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.enterPurposeValidation;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.enterPurpose),
                          ),
                        ),

                        _buildCard(
                          title: AppLocalizations.of(context)!.notes,
                          child: TextFormField(
                            cursorColor: Colors.grey,
                            controller: notesController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!.enterNotesValidation;
                              }
                              return null;
                            },
                            decoration: _getInputDecoration(AppLocalizations.of(context)!.typeYourDescription),
                          ),
                        ),

                        if (_selectedSubType != null && _selectedSubType!.docRequired == true) ...[
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
                                          child: Text(
                                            AppLocalizations.of(context)!.ok,
                                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                if (kDebugMode) print('File selection canceled.');
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.add, color: Colors.black, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)!.attachDocuments,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                                ),
                                const SizedBox(width: 10),
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
                                          onTap: () => setState(() => selectedFile = null),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [NasColors.darkBlue, NasColors.lightBlue]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  postRequest();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent, 
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.requests, 
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  /// Translation helpers (unchanged mapping but use safe null-aware callers)
  String _translateRequestSubtype(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'leave Request':
        return localizations.leaveRequests;
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
      case "Marriage Leave":
        return localizations.marriageLeave;
      case "Exam Leave":
        return localizations.examLeave;
      case "Death Leave":
        return localizations.deathLeave;
      case "Special Document":
        return localizations.specialDocument;
      case "Maternity Leave":
        return localizations.maternityLeave;
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

  /// Upload document to s3 (keeps original behavior)
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
    try {
      final jwtModel = singletonClass.getJWTModel();

      final String? employeeId = jwtModel?.employeeId;
      final String? empId = jwtModel?.empId;
      final String? companyId = jwtModel?.companyId;
      final String? branchId = jwtModel?.branchId;

      if (singletonClass.employeeDataList.isEmpty || singletonClass.companyDataList.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.employeeOrCompanyMissing,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final String? firstName = singletonClass.employeeDataList.first.data.first.firstName;
      final String? middleName = singletonClass.employeeDataList.first.data.first.middleName;
      final String? lastName = singletonClass.employeeDataList.first.data.first.lastName;

      final String employeeName = [firstName, middleName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

      final String? policyId = singletonClass.companyDataList.first.data?.policies?.first.policyId;

      final String? selectedRequestType = widget.selectedRequest?.requestType;
      final String? selectedSubType = _selectedSubType?.requestType;

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

      if (dateTime == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.selectDate,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final String formattedFromDate = DateFormat('yyyy-MM-dd').format(dateTime!);

      final List<Map<String, dynamic>> attachments = [];
      if (selectedFile != null) {
        if (singletonClass.attachmentResponseDataList.isNotEmpty && singletonClass.attachmentResponseDataList.first.data != null) {
          attachments.add({
            "type": singletonClass.attachmentResponseDataList.first.data!
                .attachmentType,
            "url": singletonClass.attachmentResponseDataList.first.data!.url,
          });
        }
      }

      final Map<String, dynamic> data = {
        "empId": empId,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "companyId": companyId,
        "policyId": policyId,
        "branchId": branchId,
        "requestType": selectedRequestType,
        "subType": selectedSubType,
        "requestData": [
          {
            "amount": _amountOfExpense.text,
            "purpose": _purpose.text,
            "description": notesController.text,
            "expenseDate": formattedFromDate,
            "category": selectedCategory.toString(),
            "paymentMethod": selectedPaymentMethods.toString(),
            "isAdvanceUsed": true,
            "transactionType": selectedTransactionType.toString(),
          }
        ],
        "approvers": [],
        "reason": notesController.text,
        "attachments": attachments,
      };

      if (kDebugMode) print("REQUEST JSON POST: ${jsonEncode(data)}");

      if (mounted) setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse("${singletonClass.baseURL}/request/create"),
        headers: singletonClass.getHeaders(),
        body: json.encode(data),
      );

      if (mounted) setState(() => isLoading = false);

      final decodedResponse = json.decode(response.body);
      if (kDebugMode) print("REQUEST RESPONSE: $decodedResponse");

      final int statusCode = (decodedResponse['statusCode'] ?? response.statusCode) as int;

      if (statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ?? "Request completed successfully",
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );

        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(index: 2, selectedIndex: 0 , showBanner: false)),
          );
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: decodedResponse['errorMessage'] ?? AppLocalizations.of(context)!.unexpectedError,
          autoCloseDuration: const Duration(seconds: 4),
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      if (kDebugMode) print("ERROR: $e");

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: AppLocalizations.of(context)!.somethingWentWrong,
        autoCloseDuration: const Duration(seconds: 4),
        showConfirmBtn: false,
      );
    }
  }
}
