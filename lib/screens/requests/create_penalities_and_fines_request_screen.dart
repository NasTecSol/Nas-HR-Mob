import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:nashr/screens/requests/request_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/widgets/loader.dart';
import '../../request_controller/company_model.dart';
import '../../request_controller/policy_model.dart';
import '../../request_controller/search_employee_model.dart';
import '../../singleton_class.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/attachment_response_model.dart';
import '../main_screen.dart';

class CreatePenalitiesAndFinesRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const CreatePenalitiesAndFinesRequestScreen({super.key, this.selectedRequest});

  @override
  State<CreatePenalitiesAndFinesRequestScreen> createState() => _CreatePenalitiesAndFinesRequestScreenState();
}

class _CreatePenalitiesAndFinesRequestScreenState extends State<CreatePenalitiesAndFinesRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  SingletonClass singletonClass = SingletonClass();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _detail = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  bool isLoading = false;
  PenaltiesFines? _selectedSubType;
  DateTime? dateTime;
  PlatformFile? selectedFile;
  final List<SearchedResult> _employeeSearchResults = [];
  final List<SearchedResult?> _selectedEmployees = [];
  bool _showSearchResult = false;
  String _calculatedAmount = "0";

  @override
  Widget build(BuildContext context) {
    final List<PenaltiesFines> subTypeList = singletonClass.policyModelDataList.first.data!.penaltiesFines ?? [];
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Employee Card
                        Text(AppLocalizations.of(context)!.searchEmployee, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                        const SizedBox(height: 8),
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
                                          Container(
                                            margin: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                                              color: NasColors.lightBlue,
                                              boxShadow: [
                                                BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)
                                              ],
                                            ),
                                            width: 150,
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 30,
                                                  width: 40,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(image: AssetImage("images/DP.png"), fit: BoxFit.fill),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      employee!.employeeName ?? "Unknown",
                                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      employee.empId ?? "Unknown",
                                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedEmployees.remove(employee);
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                                padding: const EdgeInsets.all(4.0),
                                                child: const Icon(Icons.close, color: Colors.white, size: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: '${AppLocalizations.of(context)!.search}...',
                                        hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade100),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade100),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        getSearchEmployeeData();
                                      });
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: NasColors.lightBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.search, color: NasColors.darkBlue, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                              if (_showSearchResult) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _employeeSearchResults.clear();
                                          _showSearchResult = false;
                                        });
                                      },
                                      child: Text(AppLocalizations.of(context)!.clearAll, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: _employeeSearchResults.length,
                                    itemBuilder: (context, index) {
                                      var employee = _employeeSearchResults[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Row(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: AssetImage("images/DP.png"), fit: BoxFit.fill),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(employee.employeeName ?? "Unknown", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                                                Text(employee.empId ?? "Unknown", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(AppLocalizations.of(context)!.selectSeverityOfEmployee, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                                                  content: SizedBox(
                                                    height: 120,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              employee.severity = 1;
                                                              if (_selectedEmployees.contains(employee)) {
                                                                _selectedEmployees.remove(employee);
                                                              } else {
                                                                _selectedEmployees.add(employee);
                                                                _calculateAmount();
                                                              }
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              ClipOval(child: CircleAvatar(backgroundColor: Colors.white, radius: 20, child: Image.asset('images/1.png', fit: BoxFit.fill, height: 40, width: 40))),
                                                              Text(AppLocalizations.of(context)!.low, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              employee.severity = 2;
                                                              if (_selectedEmployees.contains(employee)) {
                                                                _selectedEmployees.remove(employee);
                                                              } else {
                                                                _selectedEmployees.add(employee);
                                                                _calculateAmount();
                                                              }
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              ClipOval(child: CircleAvatar(backgroundColor: Colors.white, radius: 20, child: Image.asset('images/2.png', fit: BoxFit.fill, height: 40, width: 40))),
                                                              Text(AppLocalizations.of(context)!.medium, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                                                            ],
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              employee.severity = 3;
                                                              if (_selectedEmployees.contains(employee)) {
                                                                _selectedEmployees.remove(employee);
                                                              } else {
                                                                _selectedEmployees.add(employee);
                                                                _calculateAmount();
                                                              }
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              ClipOval(child: CircleAvatar(backgroundColor: Colors.white, radius: 20, child: Image.asset('images/3.png', fit: BoxFit.fill, height: 40, width: 40))),
                                                              Text(AppLocalizations.of(context)!.high, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
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
                                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Icon(Icons.add, color: Colors.white),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text(_translateBottomText(widget.selectedRequest?.requestName, context), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                        const SizedBox(height: 8),
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
                              DropdownButtonFormField<PenaltiesFines>(
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                value: subTypeList.contains(_selectedSubType) ? _selectedSubType : null,
                                validator: (value) {
                                  if (value == null) {
                                    return AppLocalizations.of(context)!.selectSubType;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                hint: Text(
                                  _translateRequest(widget.selectedRequest?.requestName, context),
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                                ),
                                items: subTypeList.map((PenaltiesFines subType) {
                                  return DropdownMenuItem<PenaltiesFines>(
                                    value: subType,
                                    child: Text(
                                      _translateRequestSubtype(subType.penalityName!, context),
                                      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (PenaltiesFines? newValue) {
                                  setState(() {
                                    _selectedSubType = newValue;
                                  });
                                  _calculateAmount();
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.date, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              InkWell(
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
                                  if (date != null) {
                                    setState(() {
                                      dateTime = date;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateTime == null ? "mm/dd/yyyy" : DateFormat('yyyy-MM-dd').format(dateTime!),
                                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                                      ),
                                      const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.amount, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _amount,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!.enterAmountValidation;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.enterAmountValidation,
                                  hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                  filled: true,
                                  suffixText: "SAR",
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              if (_selectedSubType?.penalityName == "daily salary percentage") ...[
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)!.days, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _daysController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => _calculateAmount(),
                                  decoration: InputDecoration(
                                    hintText: "Enter days",
                                    hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade100),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade100),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                              if (_selectedSubType?.penalityType == "HourlySalary") ...[
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context)!.totalHours, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _hoursController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => _calculateAmount(),
                                  decoration: InputDecoration(
                                    hintText: "Enter hours",
                                    hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade100),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade100),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(AppLocalizations.of(context)!.notes, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: NasColors.darkBlue, letterSpacing: 0.3)),
                        const SizedBox(height: 8),
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
                              TextFormField(
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
                                  hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.description, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _detail,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context)!.enterNotesValidation;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.typeYourDescription,
                                  hintStyle: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.add, color: Colors.black, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      AppLocalizations.of(context)!.attachDocuments,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
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
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: -5,
                                            right: -5,
                                            child: GestureDetector(
                                              onTap: () => setState(() => selectedFile = null),
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                child: const Icon(Icons.close, color: Colors.white, size: 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [NasColors.darkBlue, NasColors.lightBlue],
                              ),
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
            if (isLoading) const Loader(),
          ],
        ),
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
        boxShadow: [
          BoxShadow(
              color: NasColors.darkBlue.withOpacity(0.28),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
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
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(AppLocalizations.of(context)!.applyRequests,
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
              ]),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Row(children: [
                  Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.event_note_rounded,
                          color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            _translateBottomText(
                                widget.selectedRequest?.requestName, context),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.75))),
                        Text(
                            _translateRequest(
                                widget.selectedRequest?.requestName, context),
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ])),
                ]),
              ),
            ],
          ),
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

      final String? firstName = singletonClass.employeeDataList.first.data.first.firstName;
      final String? middleName = singletonClass.employeeDataList.first.data.first.middleName;
      final String? lastName = singletonClass.employeeDataList.first.data.first.lastName;

      final String employeeName = [firstName, middleName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

      final String? policyId = singletonClass.companyDataList.first.data?.policies?.first.policyId;

      final String? selectedRequestType = widget.selectedRequest?.requestType;
      final String? selectedSubType = _selectedSubType?.penalityName;

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
      final List<Map<String, dynamic>> attachments = [];
      if (selectedFile != null) {
        if (singletonClass.attachmentResponseDataList.isNotEmpty && singletonClass.attachmentResponseDataList.first.data != null) {
          attachments.add({
            "type": singletonClass.attachmentResponseDataList.first.data!.attachmentType,
            "url": singletonClass.attachmentResponseDataList.first.data!.url,
          });
        }
      }
      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
          "severity": employee.severity,
          "amount": double.tryParse(_amount.text) ?? 0.0,
        };
      }).toList();
      final Map<String, dynamic> data = {
        "empId": empId,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "companyId": companyId,
        "policyId": policyId,
        "branchId": branchId,
        "requestType": "penalties_fines",
        "subType": selectedSubType,
        "requestData": [
           {
             "employees": employees,
             "amount": double.tryParse(_amount.text) ?? 0.0,
             "remark": _notes.text.toString(),
              "date": dateTime!.toIso8601String().split('T').first,
              "fine_penality": selectedSubType.toString(),
             "fineType": _selectedSubType!.fineType.toString(),
             "details": _detail.text.toString(),
             "penalityType": selectedSubType.toString(),
             "penaltyDays": int.tryParse(_daysController.text) ?? 0
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


  ///Search Employee call
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text;
    if (employeeId.isEmpty) return;
    setState(() {
      isLoading = true;
      _showSearchResult = false;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/search?emp=$employeeId');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResult result = SearchedResult(
        empId: employeeData.data?.employees!.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.employees!.first.firstName,
        netSalary: employeeData.data!.employees!.first.salaryInfo!.netSalary,
      );

      debugPrint(">>>>$result");
      setState(() {
        // Remove existing entry with the same empId first
        _employeeSearchResults.removeWhere((e) => e.empId == result.empId);

        // Then add the new result
        _employeeSearchResults.add(result);

        _showSearchResult = true;
      });
      debugPrint("???$_employeeSearchResults");
    } else {
      setState(() {
        _showSearchResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.employeeNotFound)),
      );
    }
  }

  ///Helper method to calculate
  void _calculateAmount() {
    if (_selectedSubType == null || _selectedEmployees.isEmpty) return;

    final penalty = _selectedSubType!;
    final employee = _selectedEmployees.first;

    double netSalary = _toDouble(employee?.netSalary);

    double amount = 0;

    double fineAmount = _toDouble(penalty.fineAmount);

    // Fixed
    if (penalty.fineType == null || penalty.fineType == "Fixed") {
      amount = fineAmount;
    }

    // Percentage
    else if (penalty.fineType == "Percentage") {
      double percentage = fineAmount / 100;

      if (penalty.penalityType == "MonthlySalary") {
        amount = netSalary * percentage;
      }

      else if (penalty.penalityType == "DailySalary") {
        double daily = netSalary / 30;
        amount = daily * percentage;

        int days = int.tryParse(_daysController.text) ?? 1;
        amount *= days;
      }

      else if (penalty.penalityType == "HourlySalary") {
        double hourly = (netSalary / 30) / 8;
        amount = hourly * percentage;

        int hours = int.tryParse(_hoursController.text) ?? 1;
        amount *= hours;
      }
    }

    _calculatedAmount = amount.toStringAsFixed(2);

    setState(() {
      _amount.text = _calculatedAmount;
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
