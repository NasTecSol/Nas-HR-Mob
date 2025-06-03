import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/company_model.dart';

class FileComplaintsScreen extends StatefulWidget {
  const FileComplaintsScreen({super.key});

  @override
  State<FileComplaintsScreen> createState() => _FileComplaintsScreenState();
}

class _FileComplaintsScreenState extends State<FileComplaintsScreen> {
  SingletonClass singletonClass = SingletonClass();
  SubTypes? _selectedSubType;
  List<SubTypes> subTypeList = [];
  bool isLoading = false;
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _characterCount = "0/300";

  @override
  void initState() {
    super.initState();
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
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.complaints,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
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
                    postRequest();
                  },
                  child: SizedBox(
                    height: 30,
                    width: 90,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.submit,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.complaints,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<SubTypes>(
                value: _selectedSubType,
                hint: Text(
                  AppLocalizations.of(context)!.selectComplaintType,
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
                      _translateRequestSubtype(subType.requestName , context),
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
           const Divider(
             color: Colors.grey,
           ),
            const SizedBox(height:10),
            Text(
              AppLocalizations.of(context)!.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height:20),
            TextFormField(
              controller: _titleController,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: AppLocalizations.of(context)!.typeYourTitleHere,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height:10),
            TextFormField(
              controller: _complaintController,
              maxLength: 300,
              maxLines: 5,
              onChanged: (text) {
                setState(() {
                  _characterCount = "${text.length}/300";
                });
              },
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                hintText: AppLocalizations.of(context)!.typeYourComplainHere,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                counterText: _characterCount,
                counterStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.maximum300,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
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
        "title": _titleController.text,
        "message": _complaintController.text,
      });
    }

    // Construct the data map for the API call
    Map<String, dynamic> data = {
      "employeeId": employeeId,
      "companyId": companyId,
      "empId": singletonClass.getJWTModel()?.empId,
      "employeeName": employeeName,
      "branchId": branchId,
      "policyId": "123",
      "requestType": selectedRequestType,
      "subType": selectedSubType,
      "requestData": requestData,
      "approvers": [],
      "reason": _complaintController.text,
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
}
