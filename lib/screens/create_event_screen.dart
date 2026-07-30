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
import '../widgets/loader.dart' show Loader;
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

  void _handleSubmit() {
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
  }

  Widget _buildHeader(BuildContext context) {
    final title = widget.selectedIndex == 0
        ? AppLocalizations.of(context)!.createAMeeting
        : widget.selectedIndex == 1
            ? AppLocalizations.of(context)!.createATask
            : AppLocalizations.of(context)!.createAEvent;

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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
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
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _handleSubmit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.create,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              // CARD 1: EVENT DETAILS
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.selectedIndex == 0
                                          ? AppLocalizations.of(context)!.meetingName
                                          : widget.selectedIndex == 1
                                              ? AppLocalizations.of(context)!.taskName
                                              : AppLocalizations.of(context)!.eventName,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!.pleaseFillAllFields;
                                        }
                                        return null;
                                      },
                                      controller: _eventName,
                                      cursorColor: Colors.grey,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade50,
                                        filled: true,
                                        prefixIcon: Icon(Icons.title_rounded, color: NasColors.icons),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: const BorderSide(color: Colors.redAccent),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: Colors.redAccent.shade700, width: 1.5),
                                        ),
                                        hintText: widget.selectedIndex == 0
                                            ? AppLocalizations.of(context)!.typeMeetingNameHere
                                            : widget.selectedIndex == 1
                                                ? AppLocalizations.of(context)!.typeTaskNameHere
                                                : AppLocalizations.of(context)!.typeEventNameHere,
                                        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      widget.selectedIndex == 0
                                          ? AppLocalizations.of(context)!.meetingDescription
                                          : widget.selectedIndex == 1
                                              ? AppLocalizations.of(context)!.taskDescription
                                              : AppLocalizations.of(context)!.eventDescription,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return AppLocalizations.of(context)!.pleaseFillAllFields;
                                        }
                                        return null;
                                      },
                                      controller: _eventDiscription,
                                      cursorColor: Colors.grey,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade50,
                                        filled: true,
                                        prefixIcon: Icon(Icons.notes_rounded, color: NasColors.icons),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: const BorderSide(color: Colors.redAccent),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(color: Colors.redAccent.shade700, width: 1.5),
                                        ),
                                        hintText: widget.selectedIndex == 0
                                            ? AppLocalizations.of(context)!.typeMeetingDescriptionHere
                                            : widget.selectedIndex == 1
                                                ? AppLocalizations.of(context)!.typeTaskDescriptionHere
                                                : AppLocalizations.of(context)!.typeEventDescriptionHere,
                                        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // CARD 2: MEMBERS SELECTION
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.searchEmployee,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            cursorColor: Colors.grey,
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              fillColor: Colors.grey.shade50,
                                              filled: true,
                                              prefixIcon: Icon(Icons.person_search_rounded, color: NasColors.icons),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12.0),
                                                borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
                                              ),
                                              hintText: '${AppLocalizations.of(context)!.search}...',
                                              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                                            ),
                                            style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
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
                                    if (_selectedEmployees.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        "Selected Members",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 48,
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _selectedEmployees.length,
                                          itemBuilder: (context, index) {
                                            var employee = _selectedEmployees[index];
                                            final String name = employee?.employeeName ?? "Unknown";
                                            final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                                            return Container(
                                              margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: NasColors.lightBlue,
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.06),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Colors.white24,
                                                    child: Text(
                                                      initial,
                                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    name,
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedEmployees.remove(employee);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      color: Colors.white70,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 180,
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: _employeeSearchResults.length,
                                          itemBuilder: (context, index) {
                                            var employee = _employeeSearchResults[index];
                                            final String name = employee.employeeName ?? "Unknown";
                                            final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                                            final int colorValue = name.hashCode.abs();
                                            final List<Color> avatarColors = [
                                              Colors.blue,
                                              Colors.teal,
                                              Colors.indigo,
                                              Colors.purple,
                                              Colors.orange,
                                              Colors.green,
                                            ];
                                            final Color avatarColor = avatarColors[colorValue % avatarColors.length];

                                            final isSelected = _selectedEmployees.contains(employee);

                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: avatarColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    initial,
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                name,
                                                style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue),
                                              ),
                                              subtitle: Text(
                                                employee.empId ?? "Unknown",
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey),
                                              ),
                                              trailing: isSelected
                                                  ? GestureDetector(
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
                                                        padding: const EdgeInsets.all(6.0),
                                                        child: const Icon(
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedEmployees.add(employee);
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.green,
                                                        ),
                                                        padding: const EdgeInsets.all(6.0),
                                                        child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                          size: 18,
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
                              // CARD 3: SCHEDULE
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.selectDate,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () async {
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
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "DATE & TIME",
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month_outlined, size: 18, color: NasColors.darkBlue),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _selectedDate == null
                                                        ? AppLocalizations.of(context)!.selectDate
                                                        : DateFormat('yyyy-MM-dd hh:mm a').format(_selectedDate!),
                                                    style: GoogleFonts.inter(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // CARD 4: CATEGORY & TYPE
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.selectedIndex == 0
                                          ? AppLocalizations.of(context)!.meetingCategory
                                          : widget.selectedIndex == 1
                                              ? AppLocalizations.of(context)!.taskCategory
                                              : AppLocalizations.of(context)!.eventCategory,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          elevation: 8,
                                          items: _eventCategories.map((category) {
                                            return DropdownMenuItem<String>(
                                              value: category,
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
                                          hint: Row(
                                            children: [
                                              Icon(Icons.category_outlined, color: NasColors.icons),
                                              const SizedBox(width: 10),
                                              Text(
                                                AppLocalizations.of(context)!.selectCategory,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          value: _selectedCategory,
                                          isExpanded: true,
                                          iconEnabledColor: NasColors.darkBlue,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                          borderRadius: BorderRadius.circular(12),
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
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      widget.selectedIndex == 0
                                          ? AppLocalizations.of(context)!.meetingType
                                          : widget.selectedIndex == 1
                                              ? AppLocalizations.of(context)!.taskType
                                              : AppLocalizations.of(context)!.eventType,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Autocomplete<String>(
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text.isEmpty) {
                                          return _filteredEventTypes;
                                        }
                                        return _filteredEventTypes.where(
                                          (type) => type.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                                        );
                                      },
                                      onSelected: (String selection) {
                                        _eventType.text = selection;
                                        FocusScope.of(context).unfocus();
                                      },
                                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                        controller.addListener(() {
                                          if (controller.text.isNotEmpty && focusNode.hasFocus) {
                                            Future.delayed(const Duration(milliseconds: 100), () {
                                              Scrollable.ensureVisible(
                                                focusNode.context!,
                                                duration: const Duration(milliseconds: 300),
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
                                            fillColor: Colors.grey.shade50,
                                            filled: true,
                                            prefixIcon: Icon(Icons.label_outline_rounded, color: NasColors.icons),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                              borderSide: BorderSide(color: Colors.grey.shade200),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                              borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
                                            ),
                                            hintText: widget.selectedIndex == 0
                                                ? AppLocalizations.of(context)!.typeMeetingTypeOrSelectFromList
                                                : widget.selectedIndex == 1
                                                    ? AppLocalizations.of(context)!.typeTaskTypeOrSelectFromList
                                                    : AppLocalizations.of(context)!.typeEventTypeOrSelectFromList,
                                            hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
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
                                              width: MediaQuery.of(context).size.width * 0.85,
                                              child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount: options.length,
                                                itemBuilder: (context, index) {
                                                  final String option = options.elementAt(index);
                                                  return ListTile(
                                                    tileColor: Colors.white,
                                                    hoverColor: Colors.grey[200],
                                                    title: Text(
                                                      localizeEvent(context, option),
                                                      style: GoogleFonts.inter(color: Colors.black),
                                                    ),
                                                    onTap: () {
                                                      onSelected(option);
                                                      FocusScope.of(context).unfocus();
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
                              ),
                              const SizedBox(height: 24),
                              // SUBMIT BUTTON
                              GestureDetector(
                                onTap: _handleSubmit,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        NasColors.blue,
                                        NasColors.lightBlue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: NasColors.blue.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.create,
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
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Loader(),
            ],
          ),
        ),
      ),
    ],
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
        singletonClass.employeeDataList.first.data.first.departmentId;
    String? name = singletonClass.employeeDataList.first.data.first.firstName;

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
                  builder: (context) => const MainScreen(index: 3 , selectedIndex: 0,showBanner: false)));
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
    String employeeId = _searchController.text;
    if (employeeId.isEmpty) return;
    setState(() {
      isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/search?emp=$employeeId');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    setState(() {
      isLoading = false;
    });
    print("employee search ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);
      EventSearchedResults result = EventSearchedResults(
        empId: employeeData.data?.employees!.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.employees!.first.firstName,
        employeeId: employeeData.data?.employees!.first.id,
        designation: employeeData.data?.employees!.first.employeeInfo?.first.designation,
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
