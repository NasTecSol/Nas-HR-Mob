import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/task_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/branch_model.dart';
import '../request_controller/project_logo_model.dart';
import '../request_controller/search_employee_model.dart';
import '../request_controller/task_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
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
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    List<BranchData> branchDataList = singletonClass.branchDataList;
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);
    filteredTeams = filteredData['ownTeams']!;
  }

  Map<String, List<Teams>> getFilteredTeams(List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> ownTeams = [];
    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data?.branch!.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
            for (var team in department.teams ?? []) {
              bool isUserInTeam = team.teamData?.any((member) => member.empId == reportingManagerId) ?? false;
              if (isUserInTeam) {
                print('Adding under team: ${team.teamId}');
                ownTeams.addAll([team]); // Add to underTeams if the user is part of the team
              }
            }
        }
      }
    }
    return {
      'ownTeams': ownTeams,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15.0),
                  child: Text(
                    AppLocalizations.of(context)!.project,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                if(singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1')...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: NasColors.darkBlue,
                        size: 30,
                      ),
                      onPressed: () {
                        _showRequestBottomSheet(context);
                      },
                    ),
                  ),
                ]

              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: getProjectsData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset('images/loader.json'),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    // Check if the projectsDataList or its data is empty
                    if (singletonClass.projectsDataList.isEmpty ||
                        singletonClass.projectsDataList.first.data == null ||
                        singletonClass.projectsDataList.first.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Lottie.asset('images/empty.json'),
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.noData,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Render the ListView when data is available
                    return ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: singletonClass.projectsDataList.first.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final project = singletonClass.projectsDataList.first.data![index];
                        return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskScreen(projectData: project),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8), // Optional padding for better tap target
                                  color: Colors.transparent, // Makes the whole area tappable
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Image.network(
                                          project.logo ?? '',
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'images/DP.png',
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            project.name ?? '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            project.projectKey ?? '',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/empty.json'),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.noData,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetBottomSheetData() {
    setState(() {
      _teamName.clear();
      _projectKey.clear();
      _searchController.clear();
      _projectDescription.clear();
      _projectName.clear();
      singletonClass.projectsLogoModelList.clear();
      selectedFile = null;
      _employeeSearchResults.clear();
      _selectedEmployees.clear();
      _showSearchResult = false;
    });
  }
  //BottomSheet Code
  void _showRequestBottomSheet(BuildContext context) {

    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _resetBottomSheetData(); // Reset all data on close
            return true;
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child:
                        Stack(
                          children: [ ListView(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _resetBottomSheetData();
                                  },
                                  icon: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.createAProject,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
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
                                                color:
                                                Colors.grey.withOpacity(0.3),
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
                                          setState((){
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
                              AppLocalizations.of(context)!.projectName,
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
                                  return "Please Enter Project name";
                                }
                                return null;
                              },
                              controller: _projectName,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                hintText: AppLocalizations.of(context)!.typeYourProjectNameHere,
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
                              AppLocalizations.of(context)!.description,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              maxLength: 300,
                              maxLines: 5,
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                hintText: AppLocalizations.of(context)!.typeYourProjectDescriptionHere,
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
                              AppLocalizations.of(context)!.projectKey,
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
                                  return "Please Enter Project Key";
                                }
                                return null;
                              },
                              controller: _projectKey,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                hintText: AppLocalizations.of(context)!.typeYourProjectKeyHere,
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
                              AppLocalizations.of(context)!.teamName,
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
                                  return "Please Enter your team name";
                                }
                                return null;
                              },
                              controller: _teamName,
                              cursorColor: Colors.black,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                hintText: AppLocalizations.of(context)!.typeYourTeamNameHere,
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
                              AppLocalizations.of(context)!.logo,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType
                                      .image,
                                );

                                if (result != null &&
                                    result.files.single.path != null) {
                                  PlatformFile file = result.files.single;
                                  setState(() {
                                    selectedFile = file;
                                  });

                                  print('Selected file: ${file.name}');
                                  _showConfirmationDialog(
                                      file);
                                } else {
                                  print('File selection canceled.');
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.link,
                                  size: 30,
                                  color: NasColors.darkBlue,),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppLocalizations.of(context)!.addLogo,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (selectedFile != null &&
                                      selectedFile!.path != null &&
                                      selectedFile!.path!.isNotEmpty) ...[
                                    Stack(
                                      children: [ GestureDetector(
                                        onTap: () async {
                                          await OpenFile.open(selectedFile!.path);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: () {
                                            final extension = selectedFile!.path!.split('.').last.toLowerCase();

                                            if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(extension)) {
                                              return Image.file(
                                                File("${selectedFile!.path}"),
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(Icons.broken_image, size: 30);
                                                },
                                              );
                                            } else if (extension == 'pdf') {
                                              return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30);
                                            } else if (extension == 'docx' || extension == 'doc') {
                                              return const Icon(Icons.description, color: Colors.blue, size: 30);
                                            } else {
                                              return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 30);
                                            }
                                          }(),
                                        ),
                                      ),
                                        Positioned(
                                          top: -16,
                                          right: -16,
                                          child: IconButton(
                                            icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                selectedFile = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0, right: 50),
                              child: GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    if( selectedFile == null) {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: AppLocalizations.of(context)!.pleaseAttachDocument,
                                        autoCloseDuration:
                                        const Duration(seconds: 5),
                                        showCancelBtn: false,
                                        showConfirmBtn: false,
                                      );
                                    } else if (_selectedEmployees.isEmpty){
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: AppLocalizations.of(context)!.selectAssignee,
                                        autoCloseDuration:
                                        const Duration(seconds: 5),
                                        showCancelBtn: false,
                                        showConfirmBtn: false,
                                      );
                                    }else{
                                      createProject();
                                      Navigator.pop(context);
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
            },
          ),
        );
      },
    ).whenComplete(() {
      _resetBottomSheetData(); // Also reset data when sheet is closed
    });
  }
  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title:  Text(AppLocalizations.of(context)!.confirmUpload,
            style: GoogleFonts.inter(
                color: Colors.black
            ),),
          content:
          Text('${AppLocalizations.of(context)!.areYouSureYouWantToUploadThisFile} ${file.name}?',
            style: GoogleFonts.inter(
                color: Colors.black
            ),),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel,
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
              child:  Text(AppLocalizations.of(context)!.yes,
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
      print("No file selected.");
      return; // Exit the function if no file is selected
    }

    // Check if bytes are available
    if (selectedFile!.bytes == null) {
      // Load the bytes of the selected file manually
      print("Loading bytes for the selected file...");
      try {
        final file = File(selectedFile!.path!); // Convert PlatformFile to File
        final fileBytes = await file.readAsBytes();

        // If bytes are still null, return early
        if (fileBytes.isEmpty) {
          print("No bytes available for the selected file.");
          return; // Exit the function if no valid bytes are available
        }

        // Proceed with uploading the file after loading bytes
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        print('Error reading file: $e');
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
        print("Compressed from ${fileBytes.length} to ${compressed.length} bytes");
        fileBytes = compressed;
      }

      var request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(selectedFile!.path ?? '', headerBytes: fileBytes) ??
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
      print("API Response Body: $responseBody");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        ProjectLogoModel profileResponse = ProjectLogoModel.fromJson(decodedJson);
        singletonClass.projectsLogoModelList = [profileResponse];
        setState(() => isLoading = false);
        print("${singletonClass.projectsLogoModelList.first.data!.url}");

      } else {
        print('Upload failed: ${response.statusCode}');
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
      print('Error during upload: $e');
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

  //API CALL
  Future<ProjectsData?> getProjectsData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/kanban-project/getDataByadminId/$employeeId');
    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var projectsData = ProjectsData.fromJson(responseBody);
      if (projectsData.data != null && projectsData.data!.isNotEmpty) {
        singletonClass.projectsDataList.clear(); // Clear previous data if needed
        singletonClass.projectsDataList.add(projectsData);
      }
      return projectsData;
    }
    return null;
  }
  //Project Post Screen
  void createProject() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    List<Map<String, dynamic>> employees = _selectedEmployees.map((employee) {
      return {
        "empId": employee!.empId,
        "name": employee.employeeName,
        "employeeId": employee.employeeId,
        "designation": employee.designation,
        "accessLevels": "read"
      };
    }).toList();
    String url = '${singletonClass.baseURL}/kanban-project/create';
    Map<String, dynamic> data = {
      "name": _projectName.text,
      "description": _projectDescription.text,
      "teamId": filteredTeams.first.teamId,
      "teamName": _teamName.text,
      "projectMembers": employees,
      "projectLocation": "New York",
      "type": "kanban",
      "logo":  singletonClass.projectsLogoModelList.first.data!.url,
      "projectKey": _projectKey.text,
      "adminId": employeeId,
      "columns_status": [
        "TODO",
        "InProgress"
      ],
      "boardConfig": {
        "statuses": [
          {
            "id": "todo",
            "name": "To Do",
            "color": "#0000ff"
          }
        ],
        "column": [
          {
            "id": "backlog",
            "name": "Backlog",
            "statusId": "todo"
          }
        ]
      }
    };
    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    // print(data);
    log(jsonData);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
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
          Navigator.push(context, MaterialPageRoute(builder: (context)=> MainScreen()));
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
  //2ndAPI call
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
      SearchedResults result = SearchedResults(
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

  //3rd API Call
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
    return null ; // Print the response body
  }
}




class SearchedResults {
  dynamic empId;
  dynamic employeeId;
  dynamic employeeName;
  dynamic designation;

  SearchedResults({
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