import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:nashr/screens/project_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/branch_model.dart';
import '../request_controller/project_logo_model.dart';
import '../request_controller/search_employee_model.dart';
import '../request_controller/task_model.dart';
import '../singleton_class.dart';
import '../widgets/loader.dart';
import 'main_screen.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  SingletonClass singletonClass = SingletonClass();
  final TextEditingController _projectName = TextEditingController();
  final TextEditingController _projectDescription = TextEditingController();
  final TextEditingController _projectKey = TextEditingController();
  final TextEditingController _teamName = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String reportingManagerId;
  PlatformFile? selectedFile;
  bool _showSearchResult = false;
  final List<SearchedResults> _employeeSearchResults =[];
  final List<SearchedResults?> _selectedEmployees = [];
  bool isLoading = false;
  late List<Teams> filteredTeams;

  @override
  void initState() {
    super.initState();
    getTasks();
    initData();
  }

  Future<void> initData() async {
    setState(() {
      isLoading = true;
    });

    await singletonClass.getBranchData();
    await singletonClass.getTeamBranchData();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';

    final branchDataList = singletonClass.branchDataList;
    final filteredData = getFilteredTeams(branchDataList, reportingManagerId);

    setState(() {
      filteredTeams = filteredData['ownTeams'] ?? [];

      if (filteredTeams.isNotEmpty) {
        debugPrint("✅ Found ${filteredTeams.length} team(s)");
        debugPrint("First teamId: ${filteredTeams.first.teamId}");
      } else {
        debugPrint("⚠️ No teams found for this user (empId: $reportingManagerId)");
      }

      isLoading = false;
    });
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> ownTeams = [];

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails
      in branchData.data?.branch?.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          final teams = department.teams ?? [];
          final supervisors = department.supervisors ?? [];

          for (var team in teams) {
            bool isUserInTeam = team.teamData
                ?.any((member) => member.empId == reportingManagerId) ??
                false;

            bool isUserSupervisor =
            supervisors.any((s) => s.empId == reportingManagerId);

            if (isUserInTeam || isUserSupervisor) {
              if (kDebugMode) {
                debugPrint(
                    '👤 User (empId: $reportingManagerId) is part of team ${team.teamId}');
              }
              ownTeams.add(team);
            }
          }
        }
      }
    }

    return {
      'ownTeams': ownTeams,
    };
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
                  AppLocalizations.of(context)!.createAProject,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          children: [
                            const SizedBox(height: 8),
                            // CARD 1: PROJECT DETAILS
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
                                    AppLocalizations.of(context)!.projectName,
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
                                        return "Please Enter Project name";
                                      }
                                      return null;
                                    },
                                    controller: _projectName,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                      prefixIcon: Icon(Icons.topic_outlined, color: NasColors.icons),
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
                                      hintText: AppLocalizations.of(context)!.typeYourProjectNameHere,
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
                                    AppLocalizations.of(context)!.projectKey,
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
                                        return "Please Enter Project Key";
                                      }
                                      return null;
                                    },
                                    controller: _projectKey,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                      prefixIcon: Icon(Icons.key_rounded, color: NasColors.icons),
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
                                      hintText: AppLocalizations.of(context)!.typeYourProjectKeyHere,
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
                                    maxLength: 300,
                                    maxLines: 4,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please Enter Project Description";
                                      }
                                      return null;
                                    },
                                    controller: _projectDescription,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    cursorColor: Colors.black,
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
                                      hintText: AppLocalizations.of(context)!.typeYourProjectDescriptionHere,
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
                            // CARD 2: TEAM & LOGO
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
                                    AppLocalizations.of(context)!.teamName,
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
                                        return "Please Enter your team name";
                                      }
                                      return null;
                                    },
                                    controller: _teamName,
                                    cursorColor: Colors.black,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                                    decoration: InputDecoration(
                                      fillColor: Colors.grey.shade50,
                                      filled: true,
                                      prefixIcon: Icon(Icons.group_work_rounded, color: NasColors.icons),
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
                                      hintText: AppLocalizations.of(context)!.typeYourTeamNameHere,
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
                                    AppLocalizations.of(context)!.logo,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
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
                                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                                              AppLocalizations.of(context)!.addLogo,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Tap to select project logo image file",
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
                                                  "Tap to preview logo",
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
                            const SizedBox(height: 16),
                            // CARD 3: TEAM MEMBERS SELECTION
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
                            const SizedBox(height: 24),
                            // SUBMIT BUTTON
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (selectedFile == null) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: AppLocalizations.of(context)!.pleaseAttachDocument,
                                        autoCloseDuration: const Duration(seconds: 5),
                                        showCancelBtn: false,
                                        showConfirmBtn: false,
                                      );
                                    } else if (_selectedEmployees.isEmpty) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: AppLocalizations.of(context)!.selectAssignee,
                                        autoCloseDuration: const Duration(seconds: 5),
                                        showCancelBtn: false,
                                        showConfirmBtn: false,
                                      );
                                    } else {
                                      createProject();
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.pleaseEnterNotes),
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF47734D),
                                        Color(0xFF5B9362),
                                        Color(0xFF66A56E),
                                        Color(0xFF76BE7F),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF47734D).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.submit,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
                  if (isLoading)
                    Loader(),
                ],
              ),
            );
          },
        ),
      );
    }

  ///S3 buckets API calls

  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.confirmUpload,
            style: GoogleFonts.inter(
                color: Colors.black
            ),),
          content:
          Text('${AppLocalizations.of(context)!
              .areYouSureYouWantToUploadThisFile} ${file.name}?',
            style: GoogleFonts.inter(
                color: Colors.black
            ),),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.inter(
                    color: Colors.red
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Trigger the API call to upload the file
                await uploadProfile();
              },
              child: Text(AppLocalizations.of(context)!.yes,
                style: GoogleFonts.inter(
                    color: Colors.black
                ),),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadProfile() async {
    if (selectedFile == null) {
      debugPrint("No file selected.");
      return; // Exit the function if no file is selected
    }

    // Check if bytes are available
    if (selectedFile!.bytes == null) {
      // Load the bytes of the selected file manually
      debugPrint("Loading bytes for the selected file...");
      try {
        final file = File(selectedFile!.path!); // Convert PlatformFile to File
        final fileBytes = await file.readAsBytes();

        // If bytes are still null, return early
        if (fileBytes.isEmpty) {
          debugPrint("No bytes available for the selected file.");
          return; // Exit the function if no valid bytes are available
        }

        // Proceed with uploading the file after loading bytes
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        debugPrint('Error reading file: $e');
      }
    } else {
      // If bytes are already available, upload directly
      _uploadFileWithBytes(selectedFile!.bytes!);
    }
  }

  void _uploadFileWithBytes(Uint8List fileBytes) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
      // Compress the image if it's larger than 1MB
      if (fileBytes.length > 1000000) {
        final compressed = await FlutterImageCompress.compressWithList(
          fileBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
          format: CompressFormat.jpeg,
        );
        debugPrint("Compressed from ${fileBytes.length} to ${compressed
            .length} bytes");
        fileBytes = compressed;
      }

      var request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(
          selectedFile!.path ?? '', headerBytes: fileBytes) ??
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

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        ProjectLogoModel profileResponse = ProjectLogoModel.fromJson(
            decodedJson);
        singletonClass.projectsLogoModelList = [profileResponse];
        setState(() => isLoading = false);
        debugPrint("${singletonClass.projectsLogoModelList.first.data!.url}");
      } else {
        debugPrint('Upload failed: ${response.statusCode}');
        setState(() => isLoading = false);
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.errorFetchData,
          type: QuickAlertType.error,
        );
      }
    } catch (e) {
      debugPrint('Error during upload: $e');
      setState(() => isLoading = false);
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: AppLocalizations.of(context)!.errorFetchData,
        type: QuickAlertType.error,
      );
    }
  }
  ///API Calls
  void createProject() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String? empName = singletonClass.getJWTModel()?.userName;
    String? designation = singletonClass.employeeDataList.first.data.first.employeeInfo!.first.designation;
    List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
      return {
        "empId": employee!.empId,
        "name": employee.employeeName,
        "employeeId": employee.employeeId,
        "designation": employee.designation,
        "accessLevels": "read"
      };
    }).toList();

    if (employeeId != null && empName != null) {
      employees.add({
        "empId": employeeId,
        "name": empName,
        "employeeId": employeeId,
        "designation": designation ?? "",
        "accessLevels": "admin"
      });
    }
    String url = '${singletonClass.baseURL}/kanban-project/create';
    Map<String, dynamic> data = {
      "name": _projectName.text,
      "description": _projectDescription.text,
      "teamId": filteredTeams.first.teamId,
      "teamName": _teamName.text,
      "projectMembers": employees,
      "projectLocation": "New York",
      "type": "kanban",
      "logo": singletonClass.projectsLogoModelList.first.data!.url,
      "projectKey": _projectKey.text,
      "adminId": employeeId,
      "columns_status": ["TODO", "InProgress","Completed"],
      "boardConfig": {
        "statuses": [
          {"id": "todo", "name": "To Do", "color": "#0000ff"}
        ],
        "column": [
          {"id": "backlog", "name": "Backlog", "statusId": "todo"}
        ]
      }
    };

    String jsonData = jsonEncode(data);
    log("project json $jsonData");
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );

      if (!mounted) return;

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
          if (!mounted) return;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MainScreen(index: 1 , selectedIndex: 0,showBanner: false)));
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
          title: AppLocalizations.of(context)!.internalServerError,
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
      if (!mounted) return;
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

  ///2ndAPI call
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text;
    if (employeeId.isEmpty) return;

    setState(() {
      isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/search?emp=$employeeId');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResults result = SearchedResults(
        empId: employeeData.data?.employees!.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.employees!.first.firstName,
        employeeId: employeeData.data?.employees!.first.id,
        designation: employeeData.data?.employees!.first.employeeInfo?.first.designation,
      );

      debugPrint(">>>>$result");
      setState(() {
        final exists = _employeeSearchResults.any((e) => e.empId == result.empId);

        if (!exists) {
          _employeeSearchResults.add(result);
        }

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

  ///3rd API Call
  Future<TaskModel?> getTasks() async {
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/kanban-task');
    setState(() {
      isLoading = true;
    });
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log("Task Data Log ${response.body}");
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var taskData = TaskModel.fromJson(responseBody);
      singletonClass.taskModelList.addAll([taskData]);
      return taskData;
    }
    return null ;
  }
}

