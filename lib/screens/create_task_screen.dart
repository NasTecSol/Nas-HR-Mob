import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:open_file/open_file.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_attachment_model.dart';
import 'package:nashr/l10n/app_localizations.dart';

import '../widgets/loader.dart';

class CreateTaskScreen extends StatefulWidget {
  final Data? projectData;

  const CreateTaskScreen({super.key, this.projectData});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _description = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  final GlobalKey<FormState> _formKey = GlobalKey();
  PlatformFile? selectedFile;
  List<ProjectMembers>? _options;
  DateTime? fromDate;
  DateTime? toDate;
  int? totalDays;
  final List<String> _typeList = [
    'BUG',
    'FEATURE',
    'IMPROVEMENT',
    'TASK',
    'EPIC',
    'STORY',
    'SUBTASK',
    'SPIKE',
    'RESEARCH',
    'TEST',
    'OTHER'
  ];
  String? _selectedType;
  ProjectMembers? _selectedOption;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _options = widget.projectData?.projectMembers;
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BUG':
        return Icons.bug_report_rounded;
      case 'FEATURE':
        return Icons.star_rounded;
      case 'IMPROVEMENT':
        return Icons.trending_up_rounded;
      case 'TASK':
        return Icons.assignment_rounded;
      case 'EPIC':
        return Icons.bolt_rounded;
      case 'STORY':
        return Icons.bookmark_rounded;
      case 'SUBTASK':
        return Icons.account_tree_rounded;
      case 'SPIKE':
        return Icons.radar_rounded;
      case 'RESEARCH':
        return Icons.biotech_rounded;
      case 'TEST':
        return Icons.flaky_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'BUG':
        return Colors.red.shade400;
      case 'FEATURE':
        return Colors.green.shade500;
      case 'IMPROVEMENT':
        return Colors.orange.shade500;
      case 'TASK':
        return Colors.blue.shade500;
      case 'EPIC':
        return Colors.purple.shade500;
      case 'STORY':
        return Colors.teal.shade500;
      case 'SUBTASK':
        return Colors.cyan.shade500;
      case 'SPIKE':
        return Colors.indigo.shade500;
      case 'RESEARCH':
        return Colors.amber.shade700;
      case 'TEST':
        return Colors.pink.shade400;
      default:
        return Colors.grey.shade500;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (fromDate == null || toDate == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: AppLocalizations.of(context)!.enterToAndFromDate,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else if (_selectedType == null || _selectedOption == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: AppLocalizations.of(context)!.selectAssignee,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      } else {
        createTask();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Row(
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
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.createAnIssue,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            // CARD 1: TASK DETAILS
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
                                    AppLocalizations.of(context)!.subject,
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
                                        return AppLocalizations.of(context)!.typeTaskNameHere;
                                      }
                                      return null;
                                    },
                                    controller: _subject,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                      prefixIcon: Icon(Icons.edit_note_rounded, color: NasColors.icons),
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
                                      hintText: AppLocalizations.of(context)!.typeYourSubject,
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
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    AppLocalizations.of(context)!.description,
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
                                        return AppLocalizations.of(context)!.typeYourDescription;
                                      }
                                      return null;
                                    },
                                    controller: _description,
                                    cursorColor: Colors.black,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                      prefixIcon: Icon(Icons.description_outlined, color: NasColors.icons),
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
                                      hintText: AppLocalizations.of(context)!.typeYourDescription,
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
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // CARD 2: ASSIGNEE & ISSUE TYPE
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
                                    AppLocalizations.of(context)!.selectAssignee,
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
                                      child: DropdownButton<ProjectMembers?>(
                                        elevation: 8,
                                        items: _options!.map((option) {
                                          final String name = option.name ?? 'N/A';
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

                                          return DropdownMenuItem<ProjectMembers>(
                                            value: option,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: avatarColor,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      initial,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  name,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value;
                                          });
                                        },
                                        hint: Row(
                                          children: [
                                            Icon(Icons.person_outline_rounded, color: NasColors.icons),
                                            const SizedBox(width: 10),
                                            Text(
                                              AppLocalizations.of(context)!.selectAssignee,
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        value: _selectedOption,
                                        isExpanded: true,
                                        iconEnabledColor: NasColors.darkBlue,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                        borderRadius: BorderRadius.circular(12),
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    AppLocalizations.of(context)!.selectType,
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
                                        items: _typeList.map((type) {
                                          final icon = _getTypeIcon(type);
                                          final color = _getTypeColor(type);
                                          return DropdownMenuItem<String>(
                                            value: type,
                                            child: Row(
                                              children: [
                                                Icon(icon, color: color, size: 20),
                                                const SizedBox(width: 10),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: color.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    type,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      color: color,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedType = value;
                                          });
                                        },
                                        hint: Row(
                                          children: [
                                            Icon(Icons.label_outline_rounded, color: NasColors.icons),
                                            const SizedBox(width: 10),
                                            Text(
                                              AppLocalizations.of(context)!.selectType,
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        value: _selectedType,
                                        isExpanded: true,
                                        iconEnabledColor: NasColors.darkBlue,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                        borderRadius: BorderRadius.circular(12),
                                        dropdownColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // CARD 3: SCHEDULE & DURATION
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
                                    AppLocalizations.of(context)!.selectDuration,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            DateTime? date = await showDatePicker(
                                              context: context,
                                              initialDate: fromDate ?? DateTime.now(),
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
                                                fromDate = date;
                                              });
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
                                                  AppLocalizations.of(context)!.fromDate.toUpperCase(),
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
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        fromDate == null
                                                            ? AppLocalizations.of(context)!.fromDate
                                                            : DateFormat('yyyy-MM-dd').format(fromDate!),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
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
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            DateTime? date = await showDatePicker(
                                              context: context,
                                              initialDate: toDate ?? DateTime.now(),
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
                                                toDate = date;
                                                if (fromDate != null) {
                                                  totalDays = toDate!.difference(fromDate!).inDays + 1;
                                                } else {
                                                  totalDays = null;
                                                }
                                              });
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
                                                  AppLocalizations.of(context)!.toDate.toUpperCase(),
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
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        toDate == null
                                                            ? AppLocalizations.of(context)!.toDate
                                                            : DateFormat('yyyy-MM-dd').format(toDate!),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
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
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.days,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: NasColors.darkBlue.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.access_time_filled_rounded, size: 16, color: NasColors.darkBlue),
                                            const SizedBox(width: 6),
                                            Text(
                                              totalDays == null ? "0 Days" : "$totalDays Days",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // CARD 4: ATTACHMENTS
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
                                    AppLocalizations.of(context)!.addAttachments,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (selectedFile == null || selectedFile!.path == null || selectedFile!.path!.isEmpty)
                                    GestureDetector(
                                      onTap: () async {
                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                        );
                                        if (result != null && result.files.single.path != null) {
                                          PlatformFile file = result.files.single;
                                          setState(() {
                                            selectedFile = file;
                                          });
                                          _showConfirmationDialog(file);
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(Icons.cloud_upload_outlined, size: 36, color: NasColors.darkBlue),
                                            const SizedBox(height: 8),
                                            Text(
                                              AppLocalizations.of(context)!.addAttachments,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Tap to select image files",
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await OpenFile.open(selectedFile!.path);
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: () {
                                                  final extension = selectedFile!.path!.split('.').last.toLowerCase();
                                                  if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(extension)) {
                                                    return Image.file(
                                                      File("${selectedFile!.path}"),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 20),
                                                    );
                                                  } else if (extension == 'pdf') {
                                                    return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24);
                                                  } else if (extension == 'docx' || extension == 'doc') {
                                                    return const Icon(Icons.description, color: Colors.blue, size: 24);
                                                  } else {
                                                    return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 24);
                                                  }
                                                }(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedFile!.name,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Tap image to preview",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                            onPressed: () {
                                              setState(() {
                                                selectedFile = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
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
              ],
            ),
            if (isLoading)
              Loader(),
          ],
        ),
      ),
    );
  }

  //API CALLS
  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.confirmUpload),
          content:
              Text('${AppLocalizations.of(context)!.areYouSureYouWantToUploadThisFile}: ${file.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel,style: GoogleFonts.inter(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await uploadProfile();
              },
              child:  Text(AppLocalizations.of(context)!.yes,style: GoogleFonts.inter(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadProfile() async {
    if (selectedFile == null) {
      return;
    }

    if (selectedFile!.bytes == null) {
      try {
        final file = File(selectedFile!.path!);
        final fileBytes = await file.readAsBytes();
        if (fileBytes.isEmpty) {
          return;
        }
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        debugPrint('Error reading file: $e');
      }
    } else {
      _uploadFileWithBytes(selectedFile!.bytes!);
    }
  }

  void _uploadFileWithBytes(Uint8List fileBytes) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', uri);
      
      final mimeType = lookupMimeType(selectedFile!.path ?? '') ??
          'application/octet-stream';

      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream.fromBytes(fileBytes),
        fileBytes.length,
        filename: selectedFile!.name,
        contentType: MediaType.parse(mimeType),
      ));
      request.fields['attachmentName'] = selectedFile!.name;
      request.fields['attachmentType'] = selectedFile!.extension ?? '';
      var response = await request.send();

      final responseBody = await response.stream.bytesToString();
      debugPrint("API Response Body: $responseBody");
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        TaskAttachmentModel attachmentResponse =
            TaskAttachmentModel.fromJson(decodedJson);
        singletonClass.taskAttachmentDataList = [attachmentResponse];
        setState(() {});
      } else {
        debugPrint('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }


  String generateTaskId(String projectKey, int number) {
    return "$projectKey-${number.toString().padLeft(2, '0')}";
  }

  void createTask() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String url = '${singletonClass.baseURL}/kanban-task/create';
    Map<String, dynamic> data = {
      "projectId": widget.projectData!.id,
      "taskId": generateTaskId("${widget.projectData!.projectKey}", 1),
      "subject": _subject.text,
      "description": _description.text,
      "attachments": singletonClass.taskAttachmentDataList.isNotEmpty
          ? singletonClass.taskAttachmentDataList.first.data!.url
          : "",
      "status": "TODO",
      "estimatedDuration": totalDays.toString(),
      "type": _selectedType,
      "tag": "urgent",
      "assignTo":  [
        {
          "userId": _selectedOption!.empId,
          "userName": _selectedOption!.name,
        }
      ],
      "reportedTo": {"manager": employeeId},
      "logDuration": [
        {
          "date": fromDate?.toIso8601String(),
          "hours": totalDays.toString(),
          "description": _description.text,
          "loggedBy": singletonClass.getJWTModel()?.userName,
        }
      ],
      "subTask": [""],
      "comments": []
    };
    String jsonData = jsonEncode(data);
    log(jsonData);
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      debugPrint(response.body);
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

          Navigator.push(context, MaterialPageRoute(builder: (context)=>const MainScreen(index: 1,selectedIndex: 0,showBanner: false)));
          singletonClass.taskModelList.clear();
        } else if (decodedResponse['statusCode'] == 400) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: decodedResponse['data']['message'] ?? 'Error',
            type: QuickAlertType.error,
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: "Ahtlam",
          type: QuickAlertType.error,
        );
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
}
