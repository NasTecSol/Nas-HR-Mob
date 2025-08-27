import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nashr/screens/request_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/attachment_response_model.dart';
import '../request_controller/company_model.dart';
import '../request_controller/request_data_model.dart';
import '../request_controller/search_employee_model.dart';
import '../widgets/colors.dart';

class CreateRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  final bool? isTeam;
  const CreateRequestScreen({super.key, this.selectedRequest, this.isTeam});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final TextEditingController _totalLoanAmount = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool _showSearchResult = false;
  bool isLoading = false;
  final List<SearchedResult> _employeeSearchResults = [];
  final List<SearchedResult?> _selectedEmployees = [];
  DateTime? fromDate;
  DateTime? toDate;
  PlatformFile? selectedFile;
  SingletonClass singletonClass = SingletonClass();
  int? totalDays;
  final bool _isTeamSelected = false;
  int? installmentAmount;
  SubTypes? _selectedSubType;
  String? totalMonths;

  @override
  Widget build(BuildContext context) {
    List<SubTypes> subTypeList = widget.selectedRequest!.subTypes ?? [];
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: widget.isTeam == false ? Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: Stack(
              children: [ ListView(
                padding: EdgeInsets.zero,
                children: [
                  Row(
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
                                color: Colors.grey.withValues(alpha: 0.4),
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
                        AppLocalizations.of(context)!.applyRequests,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _translateBottomText(widget.selectedRequest!.requestName, context),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton<SubTypes>(
                      value: subTypeList.contains(_selectedSubType)
                          ? _selectedSubType
                          : null,
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      hint: Text(
                        _translateRequest(widget.selectedRequest!.requestName, context),
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
                            _translateRequestSubtype(
                                subType.requestName!, context),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (SubTypes? newValue) {
                        if (newValue != null) {
                          if (widget.selectedRequest!.requestType == 'leaveRequest') {
                            double? remainingBalance =
                            _getRemainingLeaveBalance(
                                newValue.requestType);

                            if (remainingBalance == null ||
                                remainingBalance <= 0) {
                              // Show warning if the selected leave balance is insufficient
                              _showWarningDialog(context,
                                  '${AppLocalizations.of(context)!.insufficientBalance} ${_translateRequestSubtype(newValue.requestName, context)}');
                            } else {
                              setState(() {
                                _selectedSubType = newValue;
                              });
                            }
                          } else {
                            setState(() {
                              _selectedSubType = newValue;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.requestType  == 'penalties_fines') ...[
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
                                // Main container for the employee tile
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
                                  // Set a fixed width for each employee tile
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
                                        children: [
                                          Text(
                                            employee!.employeeName ??
                                                "Unknown",
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Optional: Handle long text
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
                                // Small remove button on top-right
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
                                      // Adjust padding for icon size
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16, // Adjust icon size
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
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            cursorColor: Colors.grey,
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                              '${AppLocalizations.of(context)!.search}...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
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
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.clearAll,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
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
                                        image:
                                        AssetImage("images/DP.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.employeeName ??
                                            "Unknown",
                                        style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: NasColors.darkBlue),
                                      ),
                                      Text(
                                        employee.empId ?? "Unknown",
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  // Show an alert dialog when the GestureDetector is tapped
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .selectSeverityOfEmployee,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        content: SizedBox(
                                          height: 120,
                                          // Adjust the height as needed to fit content
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              // Low Severity Option
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity = 1;
                                                    if (_selectedEmployees
                                                        .contains(
                                                        employee)) {
                                                      _selectedEmployees
                                                          .remove(
                                                          employee);
                                                    } else {
                                                      _selectedEmployees
                                                          .add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/1.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .low,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Medium Severity Option
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity =
                                                    2; // Set severity level to 2 for Medium
                                                    if (_selectedEmployees
                                                        .contains(
                                                        employee)) {
                                                      _selectedEmployees
                                                          .remove(
                                                          employee);
                                                    } else {
                                                      _selectedEmployees
                                                          .add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/2.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .medium,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // High Severity Option
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity =
                                                    3; // Set severity level to 3 for High
                                                    if (_selectedEmployees
                                                        .contains(
                                                        employee)) {
                                                      _selectedEmployees
                                                          .remove(
                                                          employee);
                                                    } else {
                                                      _selectedEmployees
                                                          .add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/3.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .high,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  // Space around the icon
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
                  if (_isTeamSelected == true) ...[
                    if ((singletonClass.getJWTModel()?.grade == "L0" ||
                        singletonClass.getJWTModel()?.grade ==
                            "L1") &&
                        widget.selectedRequest!.requestType  ==
                            "allowance_Increment") ...[
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
                                  // Main container for the employee tile
                                  Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      const BorderRadius.all(
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
                                    // Set a fixed width for each employee tile
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
                                          children: [
                                            Text(
                                              employee!.employeeName ??
                                                  "Unknown",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Optional: Handle long text
                                            ),
                                            Text(
                                              employee.empId ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight:
                                                FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Small remove button on top-right
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
                                        padding:
                                        const EdgeInsets.all(4.0),
                                        // Adjust padding for icon size
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16, // Adjust icon size
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
                          Container(
                            height: 50,
                            width:
                            MediaQuery.of(context).size.width - 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              cursorColor: Colors.grey,
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText:
                                '${AppLocalizations.of(context)!.search}...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
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
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.clearAll,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
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
                                          image:
                                          AssetImage("images/DP.png"),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employee.employeeName ??
                                              "Unknown",
                                          style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue),
                                        ),
                                        Text(
                                          employee.empId ?? "Unknown",
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    // Show an alert dialog when the GestureDetector is tapped
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .selectSeverityOfEmployee,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          content: SizedBox(
                                            height: 120,
                                            // Adjust the height as needed to fit content
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                // Low Severity Option
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      employee.severity =
                                                      1; // Set severity level to 1 for Low
                                                      if (_selectedEmployees
                                                          .contains(
                                                          employee)) {
                                                        _selectedEmployees
                                                            .remove(
                                                            employee);
                                                      } else {
                                                        _selectedEmployees
                                                            .add(
                                                            employee);
                                                      }
                                                    });
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      ClipOval(
                                                        child:
                                                        CircleAvatar(
                                                          backgroundColor:
                                                          Colors
                                                              .white,
                                                          radius: 20,
                                                          child:
                                                          Image.asset(
                                                            'images/1.png',
                                                            fit: BoxFit
                                                                .fill,
                                                            height: 40,
                                                            width: 40,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(
                                                            context)!
                                                            .low,
                                                        style: GoogleFonts
                                                            .inter(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Medium Severity Option
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      employee.severity =
                                                      2; // Set severity level to 2 for Medium
                                                      if (_selectedEmployees
                                                          .contains(
                                                          employee)) {
                                                        _selectedEmployees
                                                            .remove(
                                                            employee);
                                                      } else {
                                                        _selectedEmployees
                                                            .add(
                                                            employee);
                                                      }
                                                    });
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      ClipOval(
                                                        child:
                                                        CircleAvatar(
                                                          backgroundColor:
                                                          Colors
                                                              .white,
                                                          radius: 20,
                                                          child:
                                                          Image.asset(
                                                            'images/2.png',
                                                            fit: BoxFit
                                                                .fill,
                                                            height: 40,
                                                            width: 40,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(
                                                            context)!
                                                            .medium,
                                                        style: GoogleFonts
                                                            .inter(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // High Severity Option
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      employee.severity =
                                                      3; // Set severity level to 3 for High
                                                      if (_selectedEmployees
                                                          .contains(
                                                          employee)) {
                                                        _selectedEmployees
                                                            .remove(
                                                            employee);
                                                      } else {
                                                        _selectedEmployees
                                                            .add(
                                                            employee);
                                                      }
                                                    });
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    children: [
                                                      ClipOval(
                                                        child:
                                                        CircleAvatar(
                                                          backgroundColor:
                                                          Colors
                                                              .white,
                                                          radius: 20,
                                                          child:
                                                          Image.asset(
                                                            'images/3.png',
                                                            fit: BoxFit
                                                                .fill,
                                                            height: 40,
                                                            width: 40,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(
                                                            context)!
                                                            .high,
                                                        style: GoogleFonts
                                                            .inter(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
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
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    // Space around the icon
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
                  ],
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.notes,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!
                            .pleaseEnterNotes;
                      }
                      return null;
                    },
                    controller: _notes,
                    cursorColor: Colors.black,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Color of the underline when focused
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Color of the underline when not focused
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Default color of the underline
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.selectDate,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  if (widget.selectedRequest!.requestType  != 'loanRequest') ...[
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    fromDate = date;

                                    // Recalculate totalDays and totalMonths if toDate is also selected
                                    if (toDate != null) {
                                      final daysDiff = toDate!
                                          .difference(fromDate!)
                                          .inDays +
                                          1;
                                      totalDays = daysDiff;
                                    }
                                  });
                                }
                              },
                              child: Text(
                                fromDate == null
                                    ? AppLocalizations.of(context)!
                                    .fromDate
                                    : DateFormat('yyyy-MM-dd')
                                    .format(fromDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    toDate = date;

                                    if (fromDate != null) {
                                      final daysDiff = toDate!
                                          .difference(fromDate!)
                                          .inDays +
                                          1;
                                      totalDays = daysDiff;
                                    } else {
                                      totalDays = null;
                                      totalMonths = null;
                                    }
                                  });
                                }
                              },
                              child: Text(
                                toDate == null
                                    ? AppLocalizations.of(context)!.toDate
                                    : DateFormat('yyyy-MM-dd')
                                    .format(toDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.requestType  == 'loanRequest') ...[
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (date != null) {
                                  setState(() {
                                    fromDate = DateTime(date.year, date.month);

                                    if (toDate != null) {
                                      int totalMonthCount =
                                      ((toDate!.year -
                                          fromDate!.year) *
                                          12 +
                                          (toDate!.month -
                                              fromDate!.month) +
                                          1);
                                      totalMonths =
                                          totalMonthCount.toString();
                                    }
                                  });
                                }
                              },
                              child: Text(
                                fromDate == null
                                    ? AppLocalizations.of(context)!
                                    .fromDate
                                    : DateFormat('yyyy-MM')
                                    .format(fromDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                            TextButton(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (date != null) {
                                  setState(() {
                                    toDate = DateTime(date.year,
                                        date.month); // ignore day

                                    if (fromDate != null) {
                                      int totalMonthCount =
                                      ((toDate!.year -
                                          fromDate!.year) *
                                          12 +
                                          (toDate!.month -
                                              fromDate!.month) +
                                          1);
                                      totalMonths =
                                          totalMonthCount.toString();
                                    }
                                  });
                                }
                              },
                              child: Text(
                                toDate == null
                                    ? AppLocalizations.of(context)!.toDate
                                    : DateFormat('yyyy-MM')
                                    .format(toDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 30,
                              color: NasColors.darkBlue,
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        if (totalMonths != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Total Months: $totalMonths',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.requestType  == "leaveRequest") ...[
                    Text(
                      AppLocalizations.of(context)!.days,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      totalDays == null ? "0" : "$totalDays",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.requestType  == 'loanRequest') ...[
                    Text(
                      AppLocalizations.of(context)!.totalLoanAmount,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a value";
                        }
                        return null;
                      },
                      controller: _totalLoanAmount,
                      cursorColor: Colors.black,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when focused
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when not focused
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Default color of the underline
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          double parsedValue =
                              double.tryParse(value) ?? 0.0;
                          double safeTotalMonths =
                              double.tryParse(totalMonths ?? "0") ?? 0.0;

                          if (safeTotalMonths > 0) {
                            installmentAmount = (parsedValue /
                                safeTotalMonths)
                                .round(); // or .toInt() if you want to truncate
                          } else {
                            installmentAmount = 0;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.installmentAmount,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      (installmentAmount == null)
                          ? "N/A"
                          : "$installmentAmount",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  ],
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.requestType  == 'penalties_fines') ...[
                    Text(
                      AppLocalizations.of(context)!.amount,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterNotes;
                        }
                        return null;
                      },
                      controller: _amount,
                      cursorColor: Colors.black,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when focused
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when not focused
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Default color of the underline
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.details,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterNotes;
                        }
                        return null;
                      },
                      controller: _details,
                      cursorColor: Colors.black,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when focused
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Color of the underline when not focused
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .grey, // Default color of the underline
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.docRequired == true) ...[
                    TextButton(
                      onPressed: () async {
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );

                        if (result != null &&
                            result.files.single.path != null) {
                          PlatformFile file = result.files.single;

                          // Show the image immediately
                          setState(() => selectedFile = file);

                          // Start upload in the background
                          final results = await uploadProfile(file);
                          final success = results["success"] as bool;
                          final message = results["message"] as String;

                          if (!success && context.mounted) {
                            setState(() => selectedFile = null);

                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!
                                    .uploadFailed),
                                content: Text(message),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      AppLocalizations.of(context)!.ok,
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          print('File selection canceled.');
                        }
                      },
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.attachDocuments,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (selectedFile != null)
                            Flexible(
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topRight,
                                children: [
                                  ClipOval(
                                    child: Image.file(
                                      File(selectedFile!.path!),
                                      width: 60, // reduced width to help fit
                                      height: 60,
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
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50),
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (fromDate == null || toDate == null) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: AppLocalizations.of(context)!
                                  .enterToAndFromDate,
                              autoCloseDuration:
                              const Duration(seconds: 5),
                              showCancelBtn: false,
                              showConfirmBtn: false,
                            );
                          } else if (widget.selectedRequest!.docRequired ==
                              true &&
                              selectedFile == null) {
                            // Validation for required document
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: AppLocalizations.of(context)!
                                  .pleaseAttachDocument,
                              autoCloseDuration:
                              const Duration(seconds: 5),
                              showCancelBtn: false,
                              showConfirmBtn: false,
                            );
                          } else {
                            // All validations passed, proceed to post the request
                            postRequest();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .pleaseEnterNotes),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(15)),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF47734D),
                              Color(0xFF5B9362),
                              Color(0xFF66A56E),
                              Color(0xFF76BE7F),
                              Color(0xFF86D991),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.submit,
                            style: GoogleFonts.inter(
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
                if (isLoading)
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('images/loader.json'),
                    ),
                  )
              ]
            ),
          ),
      ) :
      Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: Stack(
              children: [ ListView(
                padding: EdgeInsets.zero,
                children: [
                  Row(
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
                                color: Colors.grey.withValues(alpha: 0.4),
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
                        AppLocalizations.of(context)!.applyRequests,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _translateBottomText(widget.selectedRequest!.requestName, context),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton<SubTypes>(
                      value: subTypeList.contains(_selectedSubType)
                          ? _selectedSubType
                          : null,
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      hint: Text(
                        "${AppLocalizations.of(context)!.select} ${_translateRequest(widget.selectedRequest!.requestName, context)} ${AppLocalizations.of(context)!.type}",
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
                            _translateRequestSubtype(
                                subType.requestName, context),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (SubTypes? newValue) {
                        if (newValue != null) {
                          if (widget.selectedRequest!.requestType  == 'leaveRequest') {
                            double? remainingBalance =
                            _getRemainingLeaveBalance(
                                newValue.requestType);
                            if (remainingBalance == null ||
                                remainingBalance <= 0) {
                              _showWarningDialog(context,
                                  '${AppLocalizations.of(context)!.insufficientBalance} ${_translateRequestSubtype(newValue.requestName, context)}');
                            } else {
                              setState(() {
                                _selectedSubType = newValue;
                              });
                            }
                          } else {
                            setState(() {
                              _selectedSubType = newValue;
                            });
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if ((singletonClass.getJWTModel()?.grade == "L0" ||
                      singletonClass.getJWTModel()?.grade == "L1") &&
                      widget.selectedRequest!.requestType  == "allowance_Increment") ...[
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
                                // Main container for the employee tile
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
                                  // Set a fixed width for each employee tile
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
                                        children: [
                                          Text(
                                            employee!.employeeName ??
                                                "Unknown",
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Optional: Handle long text
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
                                // Small remove button on top-right
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
                                      // Adjust padding for icon size
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16, // Adjust icon size
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
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                              '${AppLocalizations.of(context)!.search}...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
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
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.clearAll,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
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
                                        image:
                                        AssetImage("images/DP.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        employee.employeeName ??
                                            "Unknown",
                                        style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: NasColors.darkBlue),
                                      ),
                                      Text(
                                        employee.empId ?? "Unknown",
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  // Show an alert dialog when the GestureDetector is tapped
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .selectSeverityOfEmployee,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        content: SizedBox(
                                          height: 120,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity = 1;
                                                    if (_selectedEmployees.contains(employee)) {
                                                      _selectedEmployees.remove(employee);
                                                    } else {
                                                      _selectedEmployees.add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/1.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .low,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Medium Severity Option
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity =
                                                    2; // Set severity level to 2 for Medium
                                                    if (_selectedEmployees
                                                        .contains(
                                                        employee)) {
                                                      _selectedEmployees
                                                          .remove(
                                                          employee);
                                                    } else {
                                                      _selectedEmployees
                                                          .add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/2.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .medium,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // High Severity Option
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    employee.severity =
                                                    3; // Set severity level to 3 for High
                                                    if (_selectedEmployees
                                                        .contains(
                                                        employee)) {
                                                      _selectedEmployees
                                                          .remove(
                                                          employee);
                                                    } else {
                                                      _selectedEmployees
                                                          .add(employee);
                                                    }
                                                  });
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    ClipOval(
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                        Colors.white,
                                                        radius: 20,
                                                        child:
                                                        Image.asset(
                                                          'images/3.png',
                                                          fit:
                                                          BoxFit.fill,
                                                          height: 40,
                                                          width: 40,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                          context)!
                                                          .high,
                                                      style: GoogleFonts
                                                          .inter(
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  // Space around the icon
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
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.notes,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!
                            .pleaseEnterNotes;
                      }
                      return null;
                    },
                    controller: _notes,
                    cursorColor: Colors.black,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Color of the underline when focused
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Color of the underline when not focused
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .grey, // Default color of the underline
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.selectDate,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context,
                                    Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        surface: NasColors.lightBlue,
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                        onSurface: Colors.white,
                                      ),
                                      textButtonTheme:
                                      TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setState(() {
                                  fromDate = date;
                                });
                              }
                            },
                            child: Text(
                              fromDate == null
                                  ? AppLocalizations.of(context)!.fromDate
                                  : DateFormat('yyyy-MM-dd')
                                  .format(fromDate!),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: NasColors.darkBlue,
                          ),
                          TextButton(
                            onPressed: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: toDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context,
                                    Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        surface: NasColors.lightBlue,
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                        onSurface: Colors.white,
                                      ),
                                      textButtonTheme:
                                      TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setState(() {
                                  toDate = date;
                                  if (fromDate != null) {
                                    totalDays = toDate!
                                        .difference(fromDate!)
                                        .inDays +
                                        1; // Calculate totalDays
                                  } else {
                                    totalDays =
                                    null; // Handle case where fromDate is null
                                  }
                                });
                              }
                            },
                            child: Text(
                              toDate == null
                                  ? AppLocalizations.of(context)!.toDate
                                  : DateFormat('yyyy-MM-dd')
                                  .format(toDate!),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: NasColors.darkBlue,
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.selectedRequest!.docRequired == true) ...[
                    TextButton(
                      onPressed: () async {
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null &&
                            result.files.single.path != null) {
                          PlatformFile file = result.files.single;
                          setState(() => selectedFile = file);
                          final results = await uploadProfile(file);
                          final success = results["success"] as bool;
                          final message = results["message"] as String;
                          if (!success && context.mounted) {
                            setState(() => selectedFile = null);
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("Upload Failed"),
                                content: Text(message),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      "OK",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          print('File selection canceled.');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)!.attachDocuments,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            children: [
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
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50),
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Check if fromDate and toDate are selected
                          if (fromDate == null || toDate == null) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: AppLocalizations.of(context)!
                                  .enterToAndFromDate,
                              autoCloseDuration:
                              const Duration(seconds: 5),
                              showCancelBtn: false,
                              showConfirmBtn: false,
                            );
                          } else if (widget.selectedRequest!.docRequired ==
                              true &&
                              selectedFile == null) {
                            // Validation for required document
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: AppLocalizations.of(context)!
                                  .pleaseAttachDocument,
                              autoCloseDuration:
                              const Duration(seconds: 5),
                              showCancelBtn: false,
                              showConfirmBtn: false,
                            );
                          } else {
                            // All validations passed, proceed to post the request
                            postRequest();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .pleaseEnterNotes),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(15)),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF47734D),
                              Color(0xFF5B9362),
                              Color(0xFF66A56E),
                              Color(0xFF76BE7F),
                              Color(0xFF86D991),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.submit,
                            style: GoogleFonts.inter(
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                if (isLoading)
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('images/loader.json'),
                    ),
                  )
              ]
            ),
          ),
        ),
    );
  }


  ///Other methods
  double? _getRemainingLeaveBalance(String? requestName) {
    if (requestName == null) return null;
    var leaveBalance = singletonClass.employeeDataList.first.data!.leaveBalance;
    for (var entry in leaveBalance!.toJson().entries) {
      print('Checking entry: ${entry.key}');
      if (entry.key.toLowerCase() == requestName.toLowerCase()) {
        print('Found entry: ${entry.key}: ${entry.value}');
        var remaining = entry.value['remaining'];
        print('Remaining for ${entry.key}: $remaining');

        return remaining is num
            ? remaining.toDouble()
            : null;
      }
    }

    return null;
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
                Navigator.of(context).pop(); // Close the dialog
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

  String _translateBottomText(String? status, BuildContext context){
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


  ///API Calls
  Future<Map<String, dynamic>> uploadProfile(PlatformFile file) async {
    try {
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }
      setState(() {
        isLoading = true;
      });
      var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      var request = http.MultipartRequest('POST', uri);

      final mimeType =
          lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(fileBytes),
        fileBytes.length,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("API Response Body: $responseBody");
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        AttachmentResponse attachmentResponse = AttachmentResponse.fromJson(decodedJson);
        singletonClass.attachmentResponseDataList = [attachmentResponse];
        return {"success": true, "message": ""};
      } else {
        return {
          "success": false,
          "message": "Upload failed: ${response.statusCode}\n\n$responseBody"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  ///POST API CALL
  Future<void> postRequest() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String? companyId = singletonClass.getJWTModel()?.companyId;
    String? branchId = singletonClass.getJWTModel()?.branchId;
    String? firstName = singletonClass.employeeDataList.first.data!.firstName;
    String? middleName = singletonClass.employeeDataList.first.data!.middleName;
    String? lastName = singletonClass.employeeDataList.first.data!.lastName;
    String? policyId = singletonClass.companyDataList.first.data!.policies!.first.policyId;
    String? employeeName = [firstName, middleName, lastName].where((name) => name != null && name.isNotEmpty).join(' ');

    String? selectedRequestType = widget.selectedRequest!.requestType;
    String? selectedSubType = _selectedSubType?.requestType;
    String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    int totalDays = toDate!.difference(fromDate!).inDays + 1;
    String totalDaysString = totalDays.toString();

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

    List<Map<String, dynamic>> attachments = [];
    if (selectedFile != null) {
      attachments.add({
        "fileName": singletonClass.attachmentResponseDataList.first.data!.attachmentName,
        "fileType": singletonClass.attachmentResponseDataList.first.data!.attachmentType,
        "fileContent": singletonClass.attachmentResponseDataList.first.data!.url,
      });
    }

    List<Map<String, dynamic>> requestData = [];

    if (selectedRequestType == 'loanRequest') {
      int? loanAmount = int.tryParse(_totalLoanAmount.text);
      int? totalMonth = int.tryParse(totalMonths!);
      requestData.add({
        "loanAmount": loanAmount,
        "loanCycle": "monthly",
        "loanInstallment": installmentAmount,
        "loanDuration": totalMonth,
        "loanType": selectedSubType,
      });
    } else if (selectedRequestType == 'penalties_fines') {
      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
          "severity": employee.severity,
        };
      }).toList();

      requestData.add({
        "employees": employees,
        "fine_penality": selectedSubType,
        "amount": _amount.text,
        "details": _details.text,
        "date&time": formattedFromDate,
        "remark": _notes.text,
      });
    } else if (selectedRequestType == 'allowance_Insurance') {
      List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
        return {
          "empId": employee!.empId,
          "name": employee.employeeName,
        };
      }).toList();

      requestData.add({
        "employees": employees,
        "startDate": formattedFromDate,
        "endDate": formattedToDate,
        "duration": totalDaysString,
        "allowanceType": selectedSubType,
      });
    } else {
      requestData.add({
        "startDate": formattedFromDate,
        "endDate": formattedToDate,
        "duration": totalDaysString,
        "leaveType": selectedSubType,
      });
    }

    // Construct the data map for the API call
    Map<String, dynamic> data = {
      "employeeId": employeeId,
      "companyId": companyId,
      "empId": singletonClass.getJWTModel()?.empId,
      "employeeName": employeeName,
      "branchId": branchId,
      "policyId": policyId,
      "requestType": selectedRequestType,
      "subType": selectedSubType,
      "requestData": requestData,
      "approvers": [],
      "reason": _notes.text,
      "attachments": attachments,
    };

    String body = json.encode(data);
    print("Request JSON POST $body");
    var uri = Uri.parse('${singletonClass.baseURL}/request/create');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );

      setState(() {
        isLoading = false;
      });

      final decodedResponse = json.decode(response.body);
      print("REQUEST RESPONSE $decodedResponse");

      int responseCode = decodedResponse['statusCode'] ?? response.statusCode;

      if (responseCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: AppLocalizations.of(context)!.success,
          text: decodedResponse['statusMessage'] ??
              'Request completed successfully.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        await getRequestData();
        Navigator.pop(context);
      } else {
        String errorMessage = decodedResponse['errorMessage'] ??
            'An unexpected error occurred. Please try again.';
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title:  AppLocalizations.of(context)!.internalServerError,
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

  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text.trim();
    if (employeeId.isEmpty) return;

    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri,headers: singletonClass.getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResult result = SearchedResult(
        empId: employeeData.data?.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.first.firstName,
      );

      print(">>>>$result");
      setState(() {
        // Remove existing entry with the same empId first
        _employeeSearchResults.removeWhere((e) => e.empId == result.empId);

        // Then add the new result
        _employeeSearchResults.add(result);

        _showSearchResult = true;
      });
      print("???$_employeeSearchResults");
    } else {
      setState(() {
        _showSearchResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.employeeNotFound)),
      );
    }
  }

  Future<RequestDataModel?> getRequestData(
      {int page = 0, int limit = 10}) async {
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

      if (response.statusCode == 201) {
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
