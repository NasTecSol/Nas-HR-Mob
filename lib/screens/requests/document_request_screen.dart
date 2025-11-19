import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/company_model.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_screen.dart';


class DocumentRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const DocumentRequestScreen({super.key, this.selectedRequest});

  @override
  State<DocumentRequestScreen> createState() => _DocumentRequestScreenState();
}

class _DocumentRequestScreenState extends State<DocumentRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController documentNameController = TextEditingController();
  SubTypes? _selectedSubType;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final List<SubTypes> subTypeList = widget.selectedRequest?.subTypes ?? [];
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Stack(
            children: [ ListView(
              padding: EdgeInsets.zero,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
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
                const SizedBox(height: 20),
                Text(
                  _translateBottomText(widget.selectedRequest?.requestName, context),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                /// SubType Dropdown (unchanged functionality)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<SubTypes>(
                    dropdownColor: Colors.white,
                    value: subTypeList.contains(_selectedSubType) ? _selectedSubType : null,
                    validator: (value) {
                      if (value == null) {
                        return AppLocalizations.of(context)!.selectSubType;
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                /// Document Name
                Text(
                  "${AppLocalizations.of(context)!.document} ${AppLocalizations.of(context)!.name}",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[700])),
                const SizedBox(height: 6),
                TextFormField(
                  cursorColor: Colors.grey,
                  controller: documentNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a document name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter document name",
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                /// Notes
                Text(AppLocalizations.of(context)!.notes,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[700])),
                const SizedBox(height: 6),
                TextFormField(
                  cursorColor: Colors.grey,
                  controller: notesController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.enterNotesValidation;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeYourDescription,
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          postRequest();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NasColors.darkBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.requests,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),]
          ),
        ),
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

  ///API CALL
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

      final String? firstName = singletonClass.employeeDataList.first.data?.firstName;
      final String? middleName = singletonClass.employeeDataList.first.data?.middleName;
      final String? lastName = singletonClass.employeeDataList.first.data?.lastName;

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
            "docType": selectedSubType,
            "name": documentNameController.text,
            "remarks": notesController.text,
            "date": DateTime.now().toIso8601String(),
          }
        ],
        "approvers": [],
        "reason": notesController.text,
        "attachments": [],
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
        // Show success alert then close it programmatically and navigate to MainScreen
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ?? "Request completed successfully",
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );

        // Close the QuickAlert after a short delay and navigate
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          // Close any dialogs (QuickAlert).
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(index: 2, selectedIndex: 0)),
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
