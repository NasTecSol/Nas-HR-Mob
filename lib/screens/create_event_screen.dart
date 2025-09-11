import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/search_employee_model.dart';
import 'main_screen.dart';

class CreateEventScreen extends StatefulWidget {
  final int selectedIndex;

  const CreateEventScreen({super.key, required this.selectedIndex});

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
  bool isLoading = false;
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
    "General Meeting",
    "Standup",
    "Task Deadlines"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(
          children: [
            Column(
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
                      widget.selectedIndex == 0
                          ? AppLocalizations.of(context)!.createAMeeting
                          : widget.selectedIndex == 1
                              ? AppLocalizations.of(context)!.createATask
                              : AppLocalizations.of(context)!.createAEvent,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.check,
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
                              content: Text(AppLocalizations.of(context)!
                                  .pleaseFillAllFields),
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
                            widget.selectedIndex == 0
                                ? AppLocalizations.of(context)!.meetingName
                                : widget.selectedIndex == 1
                                    ? AppLocalizations.of(context)!.taskName
                                    : AppLocalizations.of(context)!.eventName,
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
                                return AppLocalizations.of(context)!
                                    .pleaseFillAllFields;
                              }
                              return null;
                            },
                            controller: _eventName,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              hintText: widget.selectedIndex == 0
                                  ? AppLocalizations.of(context)!
                                      .typeMeetingNameHere
                                  : widget.selectedIndex == 1
                                      ? AppLocalizations.of(context)!
                                          .typeTaskNameHere
                                      : AppLocalizations.of(context)!
                                          .typeEventNameHere,
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
                            widget.selectedIndex == 0
                                ? AppLocalizations.of(context)!
                                    .meetingDescription
                                : widget.selectedIndex == 1
                                    ? AppLocalizations.of(context)!
                                        .taskDescription
                                    : AppLocalizations.of(context)!
                                        .eventDescription,
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
                                return AppLocalizations.of(context)!
                                    .pleaseFillAllFields;
                              }
                              return null;
                            },
                            controller: _eventDiscription,
                            cursorColor: Colors.grey,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                              ),
                              hintText: widget.selectedIndex == 0
                                  ? AppLocalizations.of(context)!
                                      .typeMeetingDescriptionHere
                                  : widget.selectedIndex == 1
                                      ? AppLocalizations.of(context)!
                                          .typeTaskDescriptionHere
                                      : AppLocalizations.of(context)!
                                          .typeEventDescriptionHere,
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
                                                      "---",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis, // Optional: Handle long text
                                                ),
                                                Text(
                                                  employee.empId ?? "---",
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
                                        _showSearchResult = false;
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
                                                employee.employeeName ?? "---",
                                                style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue),
                                              ),
                                              Text(
                                                employee.empId ?? "---",
                                                style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: (_selectedEmployees
                                                  .contains(employee) &&
                                              _employeeSearchResults
                                                  .contains(employee))
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_selectedEmployees
                                                      .contains(employee)) {
                                                    _selectedEmployees
                                                        .remove(employee);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedEmployees
                                                      .add(employee);
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
                                            ));
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
                              TextButton.icon(
                                onPressed: () async {
                                  // Pick the date
                                  DateTime? pickedDate = await showDatePicker(
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

                                  if (pickedDate != null) {
                                    /// Pick the time
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
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

                                    if (pickedTime != null) {
                                      final combinedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );

                                      setState(() {
                                        _selectedDate = combinedDateTime;
                                      });
                                    }
                                  }
                                },
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  size: 30,
                                  color: NasColors.darkBlue,
                                ),
                                label: Text(
                                  _selectedDate == null
                                      ? AppLocalizations.of(context)!.selectDate
                                      : DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDate!),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.selectedIndex == 0
                                ? AppLocalizations.of(context)!.meetingCategory
                                : widget.selectedIndex == 1
                                    ? AppLocalizations.of(context)!.taskCategory
                                    : AppLocalizations.of(context)!
                                        .eventCategory,
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
                                  value: category, // keep the raw key
                                  child: Text(
                                    localizeCategory(category, context),
                                    style: GoogleFonts.inter(color: Colors.black),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null && _eventData.containsKey(value)) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _filteredEventTypes = _eventData[value] ?? [];
                                    _eventType.clear();
                                  });
                                }
                              },
                              hint: Text(
                                AppLocalizations.of(context)!.selectCategory,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              value: _selectedCategory,
                              isExpanded: true,
                              iconEnabledColor: Colors.black,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              borderRadius: BorderRadius.circular(15),
                              dropdownColor: Colors.white,
                              selectedItemBuilder: (context) {
                                return _eventCategories.map((category) {
                                  return Text(
                                    localizeCategory(category, context),
                                    style: GoogleFonts.inter(color: Colors.black),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.selectedIndex == 0
                                ? AppLocalizations.of(context)!.meetingType
                                : widget.selectedIndex == 1
                                    ? AppLocalizations.of(context)!.taskType
                                    : AppLocalizations.of(context)!.eventType,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return _filteredEventTypes;
                              }
                              return _filteredEventTypes.where(
                                (type) => type.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase()),
                              );
                            },
                            onSelected: (String selection) {
                              _eventType.text = selection;
                              FocusScope.of(context).unfocus();
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onEditingComplete) {
                              controller.addListener(() {
                                if (controller.text.isNotEmpty &&
                                    focusNode.hasFocus) {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    Scrollable.ensureVisible(
                                      focusNode.context!,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  });
                                }
                              });

                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  onEditingComplete();
                                },
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  hintText: widget.selectedIndex == 0
                                      ? AppLocalizations.of(context)!
                                          .typeMeetingTypeOrSelectFromList
                                      : widget.selectedIndex == 1
                                          ? AppLocalizations.of(context)!
                                              .typeTaskTypeOrSelectFromList
                                          : AppLocalizations.of(context)!
                                              .typeEventTypeOrSelectFromList,
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
                                textInputAction: TextInputAction.done,
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final String option =
                                            options.elementAt(index);
                                        return ListTile(
                                          tileColor: Colors.white,
                                          hoverColor: Colors.grey[200],
                                          title: Text(
                                            localizeEvent(context , option),
                                            style: GoogleFonts.inter(
                                                color: Colors.black),
                                          ),
                                          onTap: () {
                                            onSelected(option);
                                            FocusScope.of(context)
                                                .unfocus(); // Close keyboard on tap
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 500),
                        ],
                      ),
                    )
                  ],
                )),
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
          ],
        ),
      ),
    );
  }

  ///Method for localization
  String localizeCategory(String? category, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (category) {
      case "Work Meeting":
        return localizations.workMeeting;
      case "Celebration":
        return localizations.celebration;
      case "General Meeting":
        return localizations.generalMeeting;
      case "Standup":
        return localizations.standup;
      case "Task Deadlines":
        return localizations.taskDeadlines;
      default:
        return category!;
    }
  }

  String localizeEvent(BuildContext context, String event) {
    switch (event) {
      case "Team Sync":
        return AppLocalizations.of(context)!.teamSync;
      case "Client Call":
        return AppLocalizations.of(context)!.clientCall;
      case "Project Planning":
        return AppLocalizations.of(context)!.projectPlanning;
      case "Review Session":
        return AppLocalizations.of(context)!.reviewSession;
      case "Strategy Meeting":
        return AppLocalizations.of(context)!.strategyMeeting;

      case "Birthday Party":
        return AppLocalizations.of(context)!.birthdayParty;
      case "Work Anniversary":
        return AppLocalizations.of(context)!.workAnniversary;
      case "Achievement Celebration":
        return AppLocalizations.of(context)!.achievementCelebration;
      case "Farewell Party":
        return AppLocalizations.of(context)!.farewellParty;

      case "All Hands":
        return AppLocalizations.of(context)!.allHands;
      case "Department Update":
        return AppLocalizations.of(context)!.departmentUpdate;
      case "Company Update":
        return AppLocalizations.of(context)!.companyUpdate;
      case "Management Discussion":
        return AppLocalizations.of(context)!.managementDiscussion;

      case "Daily Standup":
        return AppLocalizations.of(context)!.dailyStandup;
      case "Weekly Standup":
        return AppLocalizations.of(context)!.weeklyStandup;
      case "Sprint Planning":
        return AppLocalizations.of(context)!.sprintPlanning;
      case "Retrospective":
        return AppLocalizations.of(context)!.retrospective;

      case "Milestone 1":
        return AppLocalizations.of(context)!.milestoneOne;
      case "Milestone 2":
        return AppLocalizations.of(context)!.milestoneTwo;
      case "Final Submission":
        return AppLocalizations.of(context)!.finalSubmission;
      case "Bug Fix Deadline":
        return AppLocalizations.of(context)!.bugFixDeadline;

      default:
        return event;
    }
  }

  //API CALLS
  void createEvent() async {
    String? empID = singletonClass.getJWTModel()?.employeeId;
    String? departmentID =
        singletonClass.employeeDataList.first.data!.departmentId;
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
    Map<String, dynamic> data = {
      "eventName": _eventName.text,
      "eventDescription": _eventDiscription.text,
      "eventType": selectedEventType,
      "createdBy": empID,
      "members": employees,
      "month": DateFormat('MM-yyyy').format(_selectedDate!),
      "date":DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDate!),
      "category": _selectedCategory,
      "isNotification": true,
      "departmentId": departmentID,
      "creatorName": name,
    };

    String jsonData = jsonEncode(data);
    log("JSON OF EVENT : $jsonData");
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      print("EVENT RESPONSE ${response.body}");
      setState(() {
        isLoading = false;
      });
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

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainScreen(index: 3)));
          singletonClass.taskModelList.clear();
        } else if (decodedResponse['statusCode'] == 400 ||
            decodedResponse['statusCode'] == 500) {
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
      setState(() {
        isLoading = false;
      });
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
    String employeeId = _searchController.text.trim().toUpperCase();
    ;
    if (employeeId.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    setState(() {
      isLoading = false;
    });
    print("employee search ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);
      EventSearchedResults result = EventSearchedResults(
        empId: employeeData.data?.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.first.firstName,
        employeeId: employeeData.data?.first.id,
        designation: employeeData.data?.first.employeeInfo?.first.designation,
      );

      print(">>>>$result");
      setState(() {
        // Only add if not already in the list
        final exists =
            _employeeSearchResults.any((e) => e.empId == result.empId);

        if (!exists) {
          _employeeSearchResults.add(result);
        }

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
