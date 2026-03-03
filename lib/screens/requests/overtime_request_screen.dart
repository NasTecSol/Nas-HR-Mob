import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/screens/project_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/widgets/loader.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/company_model.dart';
import '../../request_controller/search_employee_model.dart';
import '../../singleton_class.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main_screen.dart';

class OvertimeRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const OvertimeRequestScreen({super.key, this.selectedRequest});

  @override
  State<OvertimeRequestScreen> createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? dateTime;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResult = false;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  SubTypes? _selectedSubType;
  final List<SearchedResults> _employeeSearchResults = [];
  final List<SearchedResults> _selectedEmployees = [];
  bool isChecked = true;
  List<Map<String, dynamic>> paidAsList = [];
  String? _selectedPaidAsType;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 600), () {
        if (_searchController.text.trim().isNotEmpty) {
          getSearchEmployeeData(_searchController.text.trim());
        }
      });
    });
    /// Load policy data safely
    try {
      var policyData =
          singletonClass.policyModelDataList.first.data!.attendancePolicy!.overtimePolicy;
      if (policyData != null && policyData.paidAs != null) {
        paidAsList = List<Map<String, dynamic>>.from(
            (policyData.paidAs as List).map((e) => Map<String, dynamic>.from(e)));
      }
    } catch (e) {
      paidAsList = [];
    }

    hoursController.addListener(() {
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    if (_selectedPaidAsType == null || hoursController.text.isEmpty) {
      totalAmountController.text = '';
      return;
    }

    double hours = double.tryParse(hoursController.text) ?? 0;
    if (hours == 0) {
      totalAmountController.text = '';
      return;
    }

    // Get employee salary info (parse safely)
    double salary = 0;
    try {
      var salaryRaw = singletonClass.employeeDataList.first.data!.salaryInfo!.baseSalary;
      if (salaryRaw is String) {
        salary = double.tryParse(salaryRaw) ?? 0;
      } else if (salaryRaw is num) {
        salary = salaryRaw.toDouble();
      }
    } catch (e) {
      salary = 0;
    }

    // Default hourly salary assuming 30 days/month and 8 hours/day
    double hourlySalary = salary / 30 / 8;

    var selected =
    paidAsList.firstWhere((e) => e['type'].toString() == _selectedPaidAsType, orElse: () => {});
    double dropdownAmount = 0;
    try {
      var amountRaw = selected['amount'];
      if (amountRaw is String) {
        dropdownAmount = double.tryParse(amountRaw) ?? 0;
      } else if (amountRaw is num) {
        dropdownAmount = amountRaw.toDouble();
      }
    } catch (e) {
      dropdownAmount = 0;
    }

    double total = 0;

    if (_selectedPaidAsType == 'bonus') {
      // Bonus -> amount * hours
      total = dropdownAmount * hours;
    } else {
      // daily_wage or paidLeave -> percentage
      total = hourlySalary * (dropdownAmount / 100) * hours;
    }

    totalAmountController.text = total.toStringAsFixed(2);
  }


// Update _onPaidAsChanged
  void _onPaidAsChanged(String? type) {
    setState(() {
      _selectedPaidAsType = type;

      var selected =
      paidAsList.firstWhere((e) => e['type'].toString() == type, orElse: () => {});
      amountController.text = selected['amount']?.toString() ?? '';

      _calculateTotalAmount();
    });
  }


  @override
  Widget build(BuildContext context) {
    List<SubTypes> subTypeList = widget.selectedRequest!.subTypes ?? [];

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
          child: Stack(
            children: [ ListView(
              padding: EdgeInsets.zero,
              children: [
                /// HEADER
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
                if (singletonClass.policyModelDataList.first.data!.attendancePolicy!.overtimePolicy!.approvalType == "both" &&
                    ["L0", "L1", "L2", "L3"].contains(singletonClass.getJWTModel()?.grade)) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        activeColor: NasColors.darkBlue,
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                      ),
                      const Text('Self'),
                    ],
                  ),
                  if (isChecked == false) ...[
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
                                    borderRadius: BorderRadius.circular(15),
                                    color: NasColors.lightBlue,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  width: 160,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage("images/DP.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      // Wrap Column with Expanded
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // start so text aligns left
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              employee.employeeName ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              employee.empId ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
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
                    ],
                    Text(
                      AppLocalizations.of(context)!.searchEmployee,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              controller: _searchController,
                              cursorColor: Colors.grey,
                              onChanged: (value) {
                                if (value.trim().isNotEmpty) {
                                  getSearchEmployeeData(_searchController.text);
                                } else {
                                  setState(() {
                                    _showSearchResult = false;
                                    _employeeSearchResults.clear();
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: '${AppLocalizations.of(context)!.search}...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              getSearchEmployeeData(_searchController.text);
                            });
                          },
                          icon: Icon(Icons.search, size: 25, color: NasColors.darkBlue),
                        ),
                      ],
                    ),
                    if (_showSearchResult) ...[
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
                              AppLocalizations.of(context)!.clearAll,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _employeeSearchResults.length,
                          itemBuilder: (context, index) {
                            var employee = _employeeSearchResults[index];
                            return ListTile(
                              title: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage("images/DP.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.employeeName ?? "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                      Text(
                                        employee.empId ?? "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedEmployees.contains(employee)) {
                                      _selectedEmployees.remove(employee);
                                    } else {
                                      _selectedEmployees.add(employee);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
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
                  const SizedBox(height: 20),
                  Text(
                    _translateBottomText(
                        widget.selectedRequest!.requestName, context),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  /// SubType Dropdown
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
                        _translateRequest(widget.selectedRequest!.requestName, context),
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
                        setState(() {
                          _selectedSubType = newValue;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  /// DATE PICKER
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.date,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 6),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateTime == null
                                          ? "mm/dd/yyyy"
                                          : DateFormat('yyyy-MM-dd')
                                          .format(dateTime!),
                                      style: GoogleFonts.inter(
                                          fontSize: 15, color: Colors.black87),
                                    ),
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  /// Paid As Dropdown
                  Text(AppLocalizations.of(context)!.paidAs,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: _selectedPaidAsType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint:  Text(AppLocalizations.of(context)!.selectPaidAs),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.selectPaidAsValidation;
                        }
                        return null;
                      },
                      isExpanded: true,
                      items: paidAsList.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['type']?.toString(),
                          child: Text(e['type']?.toString() ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        _onPaidAsChanged(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  /// Number of Hours
                  Text(AppLocalizations.of(context)!.numberOfHours,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: hoursController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.enterNumberOfHoursValidation;
                      }
                      if (double.tryParse(value) == null) {
                        return AppLocalizations.of(context)!.enterValidNumber;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterHoursPlaceholder,
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

                  const SizedBox(height: 10),
                  /// Amount per Hour
                  Text(AppLocalizations.of(context)!.amountPerHour,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: amountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.amountAppearHere,
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: NasColors.darkBlue, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.totalAmount,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: totalAmountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.totalAmountAppearHere,
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: NasColors.darkBlue, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Notes Field
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

                  const SizedBox(height: 20),
                ]
                else if (singletonClass.policyModelDataList.first.data!.attendancePolicy!.overtimePolicy!.approvalType == "manager" &&
                    ["L0", "L1", "L2", "L3"].contains(singletonClass.getJWTModel()?.grade)) ...[
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
                                  borderRadius: BorderRadius.circular(15),
                                  color: NasColors.lightBlue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
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
                                          image: AssetImage("images/DP.png"),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          employee.employeeName ?? "Unknown",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                                      _selectedEmployees.remove(employee);
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
                  ],
                  Text(
                    AppLocalizations.of(context)!.searchEmployee,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            controller: _searchController,
                            cursorColor: Colors.grey,
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                getSearchEmployeeData(_searchController.text);
                              } else {
                                setState(() {
                                  _showSearchResult = false;
                                  _employeeSearchResults.clear();
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: '${AppLocalizations.of(context)!.search}...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            getSearchEmployeeData(_searchController.text);
                          });
                        },
                        icon: Icon(Icons.search, size: 25, color: NasColors.darkBlue),
                      ),
                    ],
                  ),
                  if (_showSearchResult) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _employeeSearchResults.clear();
                            });
                          },
                          child: Text(
                            AppLocalizations.of(context)!.clearAll,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _employeeSearchResults.length,
                        itemBuilder: (context, index) {
                          var employee = _employeeSearchResults[index];
                          return ListTile(
                            title: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 60,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage("images/DP.png"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employee.employeeName ?? "Unknown",
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      employee.empId ?? "Unknown",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedEmployees.contains(employee)) {
                                    _selectedEmployees.remove(employee);
                                  } else {
                                    _selectedEmployees.add(employee);
                                  }
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    _translateBottomText(
                        widget.selectedRequest!.requestName, context),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // SubType Dropdown
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
                        _translateRequest(widget.selectedRequest!.requestName, context),
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
                        setState(() {
                          _selectedSubType = newValue;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  /// DATE PICKER
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.date,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey[700])),
                            const SizedBox(height: 6),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateTime == null
                                          ? "mm/dd/yyyy"
                                          : DateFormat('yyyy-MM-dd')
                                          .format(dateTime!),
                                      style: GoogleFonts.inter(
                                          fontSize: 15, color: Colors.black87),
                                    ),
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  /// Paid As Dropdown
                  Text(AppLocalizations.of(context)!.paidAs,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: _selectedPaidAsType,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      hint:  Text(AppLocalizations.of(context)!.selectPaidAs),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.selectPaidAsValidation;
                        }
                        return null;
                      },
                      isExpanded: true,
                      items: paidAsList.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['type']?.toString(),
                          child: Text(e['type']?.toString() ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        _onPaidAsChanged(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  /// Number of Hours
                  Text(AppLocalizations.of(context)!.numberOfHours,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: hoursController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.enterNumberOfHoursValidation;
                      }
                      if (double.tryParse(value) == null) {
                        return AppLocalizations.of(context)!.enterValidNumber;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterHoursPlaceholder,
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

                  const SizedBox(height: 10),
                  /// Amount per Hour
                  Text(AppLocalizations.of(context)!.amountPerHour,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: amountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.amountAppearHere,
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: NasColors.darkBlue, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.totalAmount,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[700])),
                  const SizedBox(height: 6),
                  TextFormField(
                    cursorColor: Colors.grey,
                    controller: totalAmountController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.totalAmountAppearHere,
                      hintStyle: GoogleFonts.inter(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        BorderSide(color: NasColors.darkBlue, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Notes Field
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

                  const SizedBox(height: 20),
                ]
                else if (singletonClass.policyModelDataList.first.data!.attendancePolicy!.overtimePolicy!.approvalType == "employee" &&
                      singletonClass.getJWTModel()?.grade == "L4") ...[
                    const SizedBox(height: 20),
                    Text(
                      _translateBottomText(
                          widget.selectedRequest!.requestName, context),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // SubType Dropdown
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
                          _translateRequest(widget.selectedRequest!.requestName, context),
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
                          setState(() {
                            _selectedSubType = newValue;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    /// DATE PICKER
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.date,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.grey[700])),
                              const SizedBox(height: 6),
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
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateTime == null
                                            ? "mm/dd/yyyy"
                                            : DateFormat('yyyy-MM-dd')
                                            .format(dateTime!),
                                        style: GoogleFonts.inter(
                                            fontSize: 15, color: Colors.black87),
                                      ),
                                      const Icon(Icons.calendar_today_outlined,
                                          color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    /// Paid As Dropdown
                    Text(AppLocalizations.of(context)!.paidAs,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: _selectedPaidAsType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        hint:  Text(AppLocalizations.of(context)!.selectPaidAs),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.selectPaidAsValidation;
                          }
                          return null;
                        },
                        isExpanded: true,
                        items: paidAsList.map((e) {
                          return DropdownMenuItem<String>(
                            value: e['type']?.toString(),
                            child: Text(e['type']?.toString() ?? ''),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          _onPaidAsChanged(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    /// Number of Hours
                    Text(AppLocalizations.of(context)!.numberOfHours,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextFormField(
                      cursorColor: Colors.grey,
                      controller: hoursController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.enterNumberOfHoursValidation;
                        }
                        if (double.tryParse(value) == null) {
                          return AppLocalizations.of(context)!.enterValidNumber;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterHoursPlaceholder,
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

                    const SizedBox(height: 10),
                    /// Amount per Hour
                    Text(AppLocalizations.of(context)!.amountPerHour,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextFormField(
                      cursorColor: Colors.grey,
                      controller: amountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.amountAppearHere,
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: NasColors.darkBlue, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(AppLocalizations.of(context)!.totalAmount,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    TextFormField(
                      cursorColor: Colors.grey,
                      controller: totalAmountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.totalAmountAppearHere,
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                          BorderSide(color: NasColors.darkBlue, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Notes Field
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
                    const SizedBox(height: 20),
                  ],
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.requests,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
              if(isLoading)
                Loader(),
            ]
          ),
        ),
      ),
    );
  }

  ///API METHODS
  Future<void> getSearchEmployeeData(String query) async {
    final employeeId = query;
    if (employeeId.isEmpty) return;

    setState(() {
      isLoading = true;
      _showSearchResult = false;
    });

    try {
      var client = http.Client();
      var uri = Uri.parse(
          '${singletonClass.baseURL}/employee/search?emp=$employeeId');
      var response =
      await client.get(uri, headers: singletonClass.getHeaders());

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var employeeData = SearchEmployeeData.fromJson(responseBody);

        if (employeeData.data != null &&
            employeeData.data!.employees!.isNotEmpty) {
          final emp = employeeData.data!.employees!.first;
          final empInfo = emp.employeeInfo != null &&
              emp.employeeInfo!.isNotEmpty
              ? emp.employeeInfo!.first
              : null;

          if (empInfo != null) {
            final result = SearchedResults(
              empId: empInfo.empId,
              employeeName: emp.userName ?? "---",
              employeeId: emp.id,
              designation: empInfo.designation,
            );

            setState(() {
              if (!_employeeSearchResults.any((e) => e.empId == result.empId)) {
                _employeeSearchResults.add(result);
              }
              _showSearchResult = true;
            });
          } else {
          }
        } else {
        }
      } else {

      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> postRequest() async {
    try {
      final jwtModel = singletonClass.getJWTModel();

      String? employeeId = jwtModel?.employeeId;
      String? empId = jwtModel?.empId;
      String? companyId = jwtModel?.companyId;
      String? branchId = jwtModel?.branchId;
      if (singletonClass.employeeDataList.isEmpty ||
          singletonClass.companyDataList.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'Employee or Company data missing.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      String? firstName = singletonClass.employeeDataList.first.data?.firstName;
      String? middleName = singletonClass.employeeDataList.first.data?.middleName;
      String? lastName = singletonClass.employeeDataList.first.data?.lastName;

      String employeeName = [
        firstName,
        middleName,
        lastName
      ].where((e) => e != null && e.isNotEmpty).join(" ");

      String? policyId =
          singletonClass.companyDataList.first.data?.policies?.first.policyId;

      String? selectedRequestType = widget.selectedRequest?.requestType;
      String? selectedSubType = _selectedSubType?.requestType;
      String? supervisorID = singletonClass.reportManagerDataList.first.data!.first.id;

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

      String formattedFromDate = DateFormat('yyyy-MM-dd').format(dateTime!);

      /// ✅ Build request body
      Map<String, dynamic> data = {
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
            "date": formattedFromDate,
            "overTimeHours": hoursController.text,
            "paidAs": {
              "type": _selectedPaidAsType,
              "amount": amountController.text,
              "totalAmount": totalAmountController.text,
            },

            // ✅ SELF OR SELECTED EMPLOYEES
            "to": isChecked
                ? [
              {"employeeId": supervisorID}
            ]
                : _selectedEmployees
                .map((e) => {"employeeId": e.employeeId})
                .toList(),
          }
        ],

        "approvers": [],
        "reason": notesController.text,
        "attachments": [],
      };

      print("REQUEST JSON POST: ${jsonEncode(data)}");

      setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse("${singletonClass.baseURL}/request/create"),
        headers: singletonClass.getHeaders(),
        body: json.encode(data),
      );

      setState(() => isLoading = false);

      final decodedResponse = json.decode(response.body);
      print("REQUEST RESPONSE: $decodedResponse");

      if ((decodedResponse['statusCode'] ?? response.statusCode) == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ??
              "Request completed successfully",
          autoCloseDuration: const Duration(seconds: 4),
          showConfirmBtn: false,
        );

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
          text:
          decodedResponse['errorMessage'] ?? "Unexpected error occurred.",
          autoCloseDuration: const Duration(seconds: 4),
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      print("ERROR: $e");

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: "Something went wrong. Check your connection.",
        autoCloseDuration: const Duration(seconds: 4),
        showConfirmBtn: false,
      );
    }
  }

  /// Helper Methods
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
        return status!;
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
        return status!;
    }
  }
}
