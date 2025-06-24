import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/search_employee_model.dart';
import 'main_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _eventName = TextEditingController();
  final TextEditingController _eventDiscription = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _eventType = TextEditingController();
  DateTime? _selectedDate;
  final GlobalKey<FormState> _formKey = GlobalKey();
  SingletonClass singletonClass = SingletonClass();
  bool _showSearchResult = false;
  final List<EventSearchedResults> _employeeSearchResults = [];
  final List<EventSearchedResults?> _selectedEmployees = [];
  String? _selectedCategory;
  List<String> _filteredEventTypes = [];
  final Map<String, List<String>> _eventData = {
    'Work Meeting': [
      'Team Sync',
      'Client Call',
      'Project Planning',
      'Review Session',
      'Strategy Meeting'
    ],
    'Celebration': [
      'Birthday Party',
      'Work Anniversary',
      'Achievement Celebration',
      'Farewell Party'
    ],
    'General Meeting': [
      'All Hands',
      'Department Update',
      'Company Update',
      'Management Discussion'
    ],
    'Standup': [
      'Daily Standup',
      'Weekly Standup',
      'Sprint Planning',
      'Retrospective'
    ],
    'Task Deadlines': [
      'Milestone 1',
      'Milestone 2',
      'Final Submission',
      'Bug Fix Deadline'
    ],
  };

  final List<String> _eventCategories = [
    "Work Meeting",
    "Celebration",
    "General Meetings",
    "Standup",
    "Task Deadlines"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
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
                        ]),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.createAEvent,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.check,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDate == null) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: AppLocalizations.of(context)!.selectDate,
                          autoCloseDuration: const Duration(seconds: 5),
                          showCancelBtn: false,
                          showConfirmBtn: false,
                        );
                      } else if (_selectedEmployees.isEmpty) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: "Select members",
                          autoCloseDuration: const Duration(seconds: 5),
                          showCancelBtn: false,
                          showConfirmBtn: false,
                        );
                      } else {
                        createEvent();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.eventName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return  AppLocalizations.of(context)!.pleaseFillAllFields;
                          }
                          return null;
                        },
                        controller: _eventName,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          hintText:  AppLocalizations.of(context)!.typeEventNameHere,
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          counterStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.eventDescription,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return  AppLocalizations.of(context)!.pleaseFillAllFields;
                          }
                          return null;
                        },
                        controller: _eventDiscription,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          hintText:  AppLocalizations.of(context)!.typeEventDescriptionHere,
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          counterStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
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
                                              image:
                                                  AssetImage("images/DP.png"),
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
                                          _selectedEmployees.remove(employee);
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
                            padding: EdgeInsets.zero,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employee.employeeName ?? "Unknown",
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
                                    setState(() {
                                      if (_selectedEmployees
                                          .contains(employee)) {
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
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.selectDate,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        surface: NasColors.lightBlue,
                                        primary: Colors.white,
                                        onPrimary: Colors.black,
                                        onSurface: Colors.white,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
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
                                  _selectedDate = date;
                                });
                              }
                            },
                            child: Text(
                              _selectedDate == null
                                  ? AppLocalizations.of(context)!.select
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
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
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.eventCategory,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton<String>(
                          elevation: 8,
                          items: _eventCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _filteredEventTypes = _eventData[value!]!;
                              _eventType.clear();
                            });
                          },
                          hint:  Text(
                            AppLocalizations.of(context)!.selectCategory,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          value: _selectedCategory,
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.eventType,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _filteredEventTypes;
                          }
                          return _filteredEventTypes.where((type) =>
                              type.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          _eventType.text = selection;
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          _eventType.text = controller.text; // Keep controller in sync
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              hintText:  AppLocalizations.of(context)!.typeEventTypeOrSelectFromList,
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.white, // 🔹 Custom Background Color
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9, // Adjust width
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final String option = options.elementAt(index);
                                    return ListTile(
                                      tileColor: Colors.white, // 🔹 Color of each list item
                                      hoverColor: Colors.grey, // 🔹 Hover effect
                                      title: Text(
                                        option,
                                        style: GoogleFonts.inter(color: Colors.black), // Text color
                                      ),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  //API CALLS
  void createEvent() async {
    String? empID = singletonClass.getJWTModel()?.employeeId;
    String? departmentID = singletonClass.employeeDataList.first.data!.departmentId;
    String? name = singletonClass.employeeDataList.first.data!.firstName;

    // Prepare list of selected employees
    List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
      return {
        "employeeId": employee!.employeeId,
        "empId": employee.empId,
        "name": employee.employeeName,
        "designation": employee.designation,
      };
    }).toList();

    // Check if the entered event type is from suggestions, otherwise send "custom"
    String selectedEventType = _filteredEventTypes.contains(_eventType.text)
        ? _eventType.text
        : "custom";

    // Check if a date is selected
    if (_selectedDate == null) {
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: "Please select a date!",
        type: QuickAlertType.warning,
      );
      return;
    }

    // API Endpoint
    String url = '${singletonClass.baseURL}/events/create';

    // Prepare API request body
    Map<String, dynamic> data = {
      "eventName": _eventName.text,
      "eventDescription": _eventDiscription.text,
      "eventType": selectedEventType,
      "createdBy": empID,
      "members": employees,
      "month": DateFormat('MM-yyyy').format(_selectedDate!),
      "date": DateFormat('yyyy-MM-dd').format(_selectedDate!),
      "category": _selectedCategory,
      "isNotification": true,
      "departmentId": departmentID,
      "creatorName": name,
    };

    String jsonData = jsonEncode(data);
    log("JSON OF EVENT : $jsonData");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      print("EVENT RESPONSE ${response.body}");
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['statusCode'] == 200) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.success,
            type: QuickAlertType.success,
          );

          Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()));
          singletonClass.taskModelList.clear();
        } else if (decodedResponse['statusCode'] == 400 || decodedResponse['statusCode'] == 500 ) {
          log("Server Message: ${decodedResponse['data']['message']}");
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: decodedResponse['data']['message'] ?? 'Error',
            type: QuickAlertType.error,
          );
          log("Server Message: ${decodedResponse['data']['message']}");
        }
      } else {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: 'Error: ${response.statusCode}',
          type: QuickAlertType.error,
        );
      }
    } catch (error) {
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: 'Failed to send data. Error: $error',
        type: QuickAlertType.error,
      );
    }
  }


  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text.trim();
    if (employeeId.isEmpty) return;

    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      EventSearchedResults result = EventSearchedResults(
        empId: employeeData.data?.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.first.firstName,
        employeeId: employeeData.data?.first.id,
        designation: employeeData.data?.first.employeeInfo?.first.designation,
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
}

class EventSearchedResults {
  dynamic empId;
  dynamic employeeId;
  dynamic employeeName;
  dynamic designation;

  EventSearchedResults({
    this.empId,
    this.employeeName,
    this.employeeId,
    this.designation,
  });

  @override
  String toString() {
    return 'SearchedResultData: {empId:$empId , employeeName: $employeeName , employeeId: $employeeId  , designation: $designation}';
  }

  // Convert CashData to JSON
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'designation': designation,
    };
  }
}
