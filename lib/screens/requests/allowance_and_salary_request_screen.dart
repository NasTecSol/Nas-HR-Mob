import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:flutter/services.dart';
import 'package:nashr/screens/requests/request_screen.dart';
import '../../request_controller/search_employee_model.dart';
import '../../widgets/loader.dart';
class AllowanceAndSalaryRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  final bool? isTeam;
  const AllowanceAndSalaryRequestScreen({super.key, this.selectedRequest, this.isTeam});

  @override
  State<AllowanceAndSalaryRequestScreen> createState() => _AllowanceAndSalaryRequestScreenState();
}

class _AllowanceAndSalaryRequestScreenState extends State<AllowanceAndSalaryRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _amount= TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResult = false;
  SubTypes? _selectedSubType;
  DateTime? dateTime;
  PlatformFile? selectedFile;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  final List<SearchedResult> _employeeSearchResults = [];
  final List<SearchedResult?> _selectedEmployees = [];
  int? _selectedCashOutDays;
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

  @override
  Widget build(BuildContext context) {
    final List<SubTypes> subTypeList = widget.selectedRequest?.subTypes ?? [];
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isTeam == true) ...[
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
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                employee!.employeeName ??
                                                    "Unknown",
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
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
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.searchEmployee,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NasColors.darkBlue,
                                    letterSpacing: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade100),
                                      ),
                                      child: TextFormField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText:
                                              '${AppLocalizations.of(context)!.search}...',
                                          hintStyle: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                            _showSearchResult = false;
                                          });
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .clearAll,
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
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
                                                  image: AssetImage(
                                                      "images/DP.png"),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    employee.employeeName ??
                                                        "Unknown",
                                                    style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: NasColors
                                                            .darkBlue),
                                                  ),
                                                  Text(
                                                    employee.empId ??
                                                        "Unknown",
                                                    style: GoogleFonts.inter(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (_selectedEmployees
                                                  .contains(employee)) {
                                                _selectedEmployees
                                                    .remove(employee);
                                              } else {
                                                _selectedEmployees
                                                    .add(employee);
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                            padding:
                                                const EdgeInsets.all(8.0),
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
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Main Request Form Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _translateBottomText(
                                  widget.selectedRequest?.requestName,
                                  context),
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NasColors.darkBlue,
                                  letterSpacing: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade100),
                              ),
                              child: DropdownButtonFormField<SubTypes>(
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                value: subTypeList.contains(_selectedSubType)
                                    ? _selectedSubType
                                    : null,
                                validator: (value) {
                                  if (value == null) {
                                    return AppLocalizations.of(context)!
                                        .selectSubType;
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                ),
                                hint: Text(
                                  _translateRequest(
                                      widget.selectedRequest?.requestName,
                                      context),
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: Colors.black),
                                ),
                                items: subTypeList.map((SubTypes subType) {
                                  return DropdownMenuItem<SubTypes>(
                                    value: subType,
                                    child: Text(
                                      _translateRequestSubtype(
                                          subType.requestName!, context),
                                      style: GoogleFonts.inter(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (SubTypes? newValue) => setState(
                                    () {
                                  _selectedSubType = newValue;
                                  _selectedCashOutDays = null;
                                }),
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (_selectedSubType?.requestName ==
                                    'annualLeaveCashOut' &&
                                widget.isTeam == false) ...[
                              Text('Remaining Annual Leave',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: NasColors.darkBlue,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 12),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade100)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        singletonClass.employeeDataList
                                                .isNotEmpty
                                            ? (singletonClass
                                                        .employeeDataList
                                                        .first
                                                        .data
                                                        .first
                                                        .leaveBalance!
                                                        .annualLeave!
                                                        .remaining ??
                                                    0)
                                                .toString()
                                            : '0',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.black87))),
                              ),
                              const SizedBox(height: 20),
                              Text('Cash Out Days',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: NasColors.darkBlue,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade100)),
                                child: DropdownButtonFormField<int>(
                                  dropdownColor: Colors.white,
                                  value: _selectedCashOutDays,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12)),
                                  hint: Text('Select Days',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black)),
                                  items: List.generate(
                                          singletonClass.employeeDataList
                                                  .isNotEmpty
                                              ? (singletonClass
                                                      .employeeDataList
                                                      .first
                                                      .data
                                                      .first
                                                      .leaveBalance!
                                                      .annualLeave!
                                                      .remaining ??
                                                  0)
                                              : 0,
                                          (i) => i + 1)
                                      .map((day) => DropdownMenuItem<int>(
                                          value: day,
                                          child: Text(day.toString(),
                                              style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.black))))
                                      .toList(),
                                  onChanged: (int? val) => setState(() {
                                    _selectedCashOutDays = val;
                                    if (val != null &&
                                        singletonClass
                                            .employeeDataList.isNotEmpty) {
                                      final netSalary = double.tryParse(
                                              singletonClass
                                                      .employeeDataList
                                                      .first
                                                      .data
                                                      .first
                                                      .salaryInfo!
                                                      .netSalary
                                                      ?.toString() ??
                                                  '0') ??
                                          0;
                                      _amount.text =
                                          ((netSalary / 30) * val)
                                              .toStringAsFixed(2);
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            if (_selectedSubType?.requestName ==
                                    'annualLeaveCashOut' &&
                                widget.isTeam == true) ...[
                              Text('Remaining Annual Leave',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: NasColors.darkBlue,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 12),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade100)),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        _selectedEmployees.isNotEmpty
                                            ? (_selectedEmployees.first!
                                                        .annualLeaveRemaining ??
                                                    0)
                                                .toString()
                                            : '0',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.black87))),
                              ),
                              const SizedBox(height: 20),
                              Text('Cash Out Days',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: NasColors.darkBlue,
                                      letterSpacing: 0.3)),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade100)),
                                child: DropdownButtonFormField<int>(
                                  dropdownColor: Colors.white,
                                  value: _selectedCashOutDays,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12)),
                                  hint: Text('Select Days',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black)),
                                  items: List.generate(
                                          _selectedEmployees.isNotEmpty
                                              ? (_selectedEmployees.first!
                                                      .annualLeaveRemaining ??
                                                  0)
                                              : 0,
                                          (i) => i + 1)
                                      .map((day) => DropdownMenuItem<int>(
                                          value: day,
                                          child: Text(day.toString(),
                                              style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.black))))
                                      .toList(),
                                  onChanged: (int? val) => setState(() {
                                    _selectedCashOutDays = val;
                                    if (val != null &&
                                        _selectedEmployees.isNotEmpty) {
                                      final netSalary = double.tryParse(
                                              _selectedEmployees.first!
                                                      .netSalary
                                                      ?.toString() ??
                                                  '0') ??
                                          0;
                                      _amount.text =
                                          ((netSalary / 30) * val)
                                              .toStringAsFixed(2);
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            Text(AppLocalizations.of(context)!.date,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NasColors.darkBlue,
                                    letterSpacing: 0.3)),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: dateTime ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder:
                                      (BuildContext context, Widget? child) {
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
                                            foregroundColor:
                                                NasColors.darkBlue,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() => dateTime = date);
                                }
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateTime == null
                                          ? AppLocalizations.of(context)!
                                              .datePlaceholder
                                          : DateFormat('yyyy-MM-dd')
                                              .format(dateTime!),
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black87),
                                    ),
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.grey, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(AppLocalizations.of(context)!.amount,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NasColors.darkBlue,
                                    letterSpacing: 0.3)),
                            const SizedBox(height: 12),
                            TextFormField(
                              cursorColor: Colors.grey,
                              controller: _amount,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterAmountValidation;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .enterAmountValidation,
                                hintStyle: GoogleFonts.inter(
                                    color: Colors.grey, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade100),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade100),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(AppLocalizations.of(context)!.notes,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NasColors.darkBlue,
                                    letterSpacing: 0.3)),
                            const SizedBox(height: 12),
                            TextFormField(
                              cursorColor: Colors.grey,
                              controller: notesController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterNotesValidation;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .typeYourDescription,
                                hintStyle: GoogleFonts.inter(
                                    color: Colors.grey, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade100),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade100),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (_selectedSubType != null &&
                                _selectedSubType!.docRequired == true) ...[
                              TextButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform
                                          .pickFiles(type: FileType.any);
                                  if (result != null &&
                                      result.files.single.path != null) {
                                    final PlatformFile file =
                                        result.files.single;
                                    setState(() => selectedFile = file);

                                    final results =
                                        await uploadDocuments(file);
                                    final bool success =
                                        results["success"] as bool;
                                    final String message =
                                        results["message"] as String;

                                    if (!success && context.mounted) {
                                      setState(() => selectedFile = null);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .uploadFailedTitle),
                                          content: Text(message),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .ok,
                                                style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } else {
                                    if (kDebugMode) {
                                      print('File selection canceled.');
                                    }
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.add,
                                        color: Colors.black, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .attachDocuments,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14),
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
                                              onTap: () => setState(
                                                  () => selectedFile = null),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration:
                                                    const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape
                                                            .circle),
                                                child: const Icon(Icons.close,
                                                    color: Colors.white,
                                                    size: 14),
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
                                  gradient: LinearGradient(colors: [
                                    NasColors.darkBlue,
                                    NasColors.lightBlue
                                  ]),
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))),
                                  child: Text(
                                      AppLocalizations.of(context)!.requests,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
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
          ),
          if (isLoading) const Loader(),
        ],
      ),
    )]));
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
      case "housingAllowance":
        return localizations.housingAllowance;
      case "travelingAllowance":
        return localizations.travellingAllowance;
      case 'salaryIncrementalAllowance':
        return localizations.salaryIncrementalAllowance;
      case 'annualLeaveCashOut':
        return localizations.annualLeaveCashOut;
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
      case "allowance_Increment":
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

  /// Api methods
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
            "type": singletonClass.attachmentResponseDataList.first.data!.attachmentType,
            "url": singletonClass.attachmentResponseDataList.first.data!.url,
          });
        }
      }

      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
        };
      }).toList();

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
            if (widget.isTeam == true) "employees": employees,
            "allowanceType": selectedSubType,
            "amount": _amount.text,
            "remark": notesController.text,
            "effectiveDate": formattedFromDate,
            if (selectedSubType == "annualleavecashout") "days": _selectedCashOutDays?.toString() ?? "undefined",
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
            MaterialPageRoute(builder: (context) => MainScreen(index: 2, selectedIndex: 0 , showBanner: false,)),
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

  ///Search  Employee
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
        annualLeaveRemaining:  employeeData.data!.employees!.first.leaveBalance!.annualLeave!.remaining,
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
}
