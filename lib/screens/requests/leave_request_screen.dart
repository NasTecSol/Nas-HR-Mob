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
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../request_controller/company_model.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/attachment_response_model.dart';
import '../main_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const LeaveRequestScreen({super.key, this.selectedRequest});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  bool isLoading = false;
  SingletonClass singletonClass = SingletonClass();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _totalDays = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  SubTypes? _selectedSubType;
  DateTime? startDate;
  DateTime? endDate;
  PlatformFile? selectedFile;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    final List<SubTypes> subTypeList = widget.selectedRequest?.subTypes ?? [];
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Stack(children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                ///Header
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
                const SizedBox(height: 20),
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

                    onChanged: (SubTypes? newValue) {
                      if(newValue!.requestName == 'Short Leave' || newValue.requestName == 'UnPaid Leave '){
                        setState(() {
                          _selectedSubType = newValue;
                        });
                      } else {
                        double? remainingBalance = _getRemainingLeaveBalance(newValue.requestType);
                        if (remainingBalance == null ||
                            remainingBalance <= 0) {
                          _showWarningDialog(context,
                              '${AppLocalizations.of(context)!.insufficientBalance} ${_translateRequestSubtype(newValue.requestName, context)}');

                          _selectedSubType = null;
                        } else {
                          setState(() {
                            _selectedSubType = newValue;
                          });
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ///Date Picker
                if(_selectedSubType?.requestName == 'Short Leave')...[
                  ///Duration
                  Text(AppLocalizations.of(context)!.date,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ///Start Date
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
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
                            if (date != null) {
                              setState(() {
                                startDate = date;
                              });
                              calculateTotalDays();
                            }
                          },

                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startDate == null
                                      ? AppLocalizations.of(context)!.selectDate
                                      : DateFormat('MMM yyyy').format(startDate!),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                                ),
                                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.time,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      /// START TIME
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: NasColors.darkBlue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                startTime = picked;
                                updateTotalTime();
                              });

                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startTime == null
                                      ? AppLocalizations.of(context)!.startTime
                                      : startTime!.format(context),
                                  style: GoogleFonts.inter(fontSize: 15),
                                ),
                                const Icon(Icons.access_time, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// END TIME
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: NasColors.darkBlue,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                endTime = picked;
                                updateTotalTime();
                              });

                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endTime == null
                                      ? AppLocalizations.of(context)!.endTime
                                      : endTime!.format(context),
                                  style: GoogleFonts.inter(fontSize: 15),
                                ),
                                const Icon(Icons.access_time, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${AppLocalizations.of(context)!.totalHours}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _totalDays,
                    readOnly: true,
                    enabled: false,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: "0h 0m",
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ] else ...[
                  ///Duration
                  Text(AppLocalizations.of(context)!.duration,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ///Start Date
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
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
                            if (date != null) {
                              setState(() {
                                startDate = date;
                              });
                              calculateTotalDays();
                            }
                          },

                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  startDate == null
                                      ? AppLocalizations.of(context)!.selectDate
                                      : DateFormat('MMM yyyy').format(startDate!),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                                ),
                                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(AppLocalizations.of(context)!.to,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey[700])),
                      const SizedBox(width: 5),
                      /// END DATE
                      Expanded(
                        child:
                        InkWell(
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
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
                            if (date != null) {
                              setState(() => endDate = date);
                              calculateTotalDays();
                            }
                          },

                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  endDate == null
                                      ? AppLocalizations.of(context)!.selectDate
                                      : DateFormat('MMM yyyy').format(endDate!),
                                  style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
                                ),
                                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ///No of Days
                  Text(AppLocalizations.of(context)!.totalDays,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _totalDays,
                    readOnly: true,
                    enabled: false, // completely non-editable
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ///Notes
                Text(AppLocalizations.of(context)!.notes,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[700])),
                const SizedBox(height: 6),
                TextFormField(
                  cursorColor: Colors.grey,
                  controller: _notes,
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
                const SizedBox(height: 20),
                /// Attachment button (only if required)
                if (widget.selectedRequest?.docRequired == true) ...[
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
                          // keep behavior same but show AlertDialog as in original
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
                        // keep original behaviour of printing cancellation
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
                ],
                const SizedBox(height: 20),
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

              ],
            ),
            if (isLoading) Loader()
          ]),
        ),
      ),
    );
  }

  ///Helper methods for translation of text values from english to arabic
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


  ///Helper  method to calculate total days
  void calculateTotalDays() {
    if (startDate == null || endDate == null) return;
    int days = endDate!.difference(startDate!).inDays + 1;
    if (days < 0) days = 0;
    setState(() {
      _totalDays.text = days.toString();
    });
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

      if (startDate == null && endDate == null) {
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

      if (selectedFile == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.attachDocuments,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final List<Map<String, dynamic>> attachments = [];
      if (selectedFile != null) {
        if (singletonClass.attachmentResponseDataList.isNotEmpty && singletonClass.attachmentResponseDataList.first.data != null) {
          attachments.add({
            "type": singletonClass.attachmentResponseDataList.first.data!.attachmentType,
            "url": singletonClass.attachmentResponseDataList.first.data!.url,
          });
        }
      }
      final bool isShortLeave = selectedSubType.toLowerCase() == 'short leave' ||
              selectedSubType.toLowerCase() == 'shortleave';

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
          isShortLeave
              ? {
            "leaveType": "shortLeave",
            "startDate": _combineDateAndTime(startDate!, startTime!).toIso8601String(),
            "endDate": _combineDateAndTime(startDate!, endTime!).toIso8601String(),
            "duration": _calculateDurationInHours(),
          }
              : {
            "leaveType": selectedSubType,
            "startDate": startDate!.toIso8601String().split('T').first,
            "endDate": endDate!.toIso8601String().split('T').first,
            "duration": _totalDays.text,
          }
        ],
        "approvers": [],
        "reason": _notes.text,
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


  ///Helper method to calculate remaining days
  double? _getRemainingLeaveBalance(String? requestName) {
    if (requestName == null) return null;
    var leaveBalance = singletonClass.employeeDataList.first.data!.leaveBalance;
    for (var entry in leaveBalance!.toJson().entries) {
      print('Checking entry: ${entry.key}');
      if (entry.key.toLowerCase() == requestName.toLowerCase()) {
        print('Found entry: ${entry.key}: ${entry.value}');

        if (entry.key == 'UnPaid Leave ' || entry.key == 'Short Leave') {
          print('No balance check needed for ${entry.key}');
          return null; // or any sentinel value indicating balance not required
        }
        var remaining = entry.value['remaining'];
        print('Remaining for ${entry.key}: $remaining');

        return remaining is num ? remaining.toDouble() : null;
      }
    }
    return null;
  }
  String calculateTotalTime() {
    if (startTime == null || endTime == null) {
      return '0h 0m';
    }

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    if (endMinutes <= startMinutes) {
      return '0h 0m';
    }

    final diffMinutes = endMinutes - startMinutes;
    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;

    return '${hours}h ${minutes}m';
  }
  void updateTotalTime() {
    _totalDays.text = calculateTotalTime();
  }
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  double _calculateDurationInHours() {
    if (startTime == null || endTime == null) return 0;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes / 60;
  }


  ///Alert Dialogue
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
                Navigator.of(context).pop();
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

}
