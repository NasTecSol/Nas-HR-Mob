import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/screens/create_project_screen.dart';
import 'package:nashr/screens/task_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/widgets/loader.dart';
import '../request_controller/task_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  int _selectedOptionIndex = 0;

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  Future<void> fetchLatestProjectData() async {
    try {
      getAllProjects();
      getTasks();
      getProjectsData();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
        .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
        [])
        : [];

    final canCreateProject = uiSettings.any((e) {
      if (e.title == "Teams" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
        (sub.title == "Task Board" || sub.title == "Task Board") &&
            sub.accessType!.write == true) ??
            false;
      }
      return false;
    });
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: RefreshIndicator(
          color: NasColors.darkBlue,
          backgroundColor: Colors.white,
          onRefresh: fetchLatestProjectData,
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
                  if (canCreateProject)
                      Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: NasColors.darkBlue,
                          size: 30,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateProjectScreen()));
                        },
                      ),
                    ),
                  ],
              ),
              const SizedBox(height: 20),
              if(singletonClass.getJWTModel()?.grade == "L0" || singletonClass.getJWTModel()?.grade == "L1" )...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildOptionsCard(0, AppLocalizations.of(context)!.all),
                    buildOptionsCard(1, AppLocalizations.of(context)!.myProjects),
                  ],
                ),
                if(_selectedOptionIndex == 0)...[
                  Expanded(
                    child: FutureBuilder(
                      future: getAllProjects(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Loader();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/error.json'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
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
                          return ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: singletonClass.projectsDataList.first.data!
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              final project = singletonClass.projectsDataList.first
                                  .data![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TaskScreen(projectData: project),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            project.logo ?? '',
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (context, error,
                                                stackTrace) {
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
                                              project.name ?? '---',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              project.projectKey ?? '---',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 10),
                                        if(project.adminId == singletonClass.getJWTModel()?.employeeId)...[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.admin} ☆",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                            ],
                                          ),
                                        ]else...[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.member} ",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                            ],
                                          ),
                                        ]
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
                if(_selectedOptionIndex == 1)...[
                  Expanded(
                    child: FutureBuilder(
                      future: getProjectsData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Loader();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/error.json'),
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
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
                          return ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: singletonClass.projectsDataList.first.data!
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              final project = singletonClass.projectsDataList.first
                                  .data![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TaskScreen(projectData: project),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Image.network(
                                            project.logo ?? '',
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            errorBuilder: (context, error,
                                                stackTrace) {
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
                                              project.name ?? '---',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              project.projectKey ?? '---',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        if(project.adminId == singletonClass.getJWTModel()?.employeeId)...[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.admin} ☆",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                            ],
                                          ),
                                        ]else...[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.member} ",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              SizedBox(height: 25),
                                            ],
                                          ),
                                        ]
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
              ],
              if(singletonClass.getJWTModel()?.grade == "L2" || singletonClass.getJWTModel()?.grade == "L3" || singletonClass.getJWTModel()?.grade == "L4"  )...[
                Expanded(
                  child: FutureBuilder(
                    future: getProjectsData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loader();
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/error.json'),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
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
                        return ListView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: singletonClass.projectsDataList.first.data!
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            final project = singletonClass.projectsDataList.first
                                .data![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskScreen(projectData: project),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          project.logo ?? '',
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          errorBuilder: (context, error,
                                              stackTrace) {
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
                                            project.name ?? '---',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            project.projectKey ?? '---',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      if(project.adminId == singletonClass.getJWTModel()?.employeeId)...[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${AppLocalizations.of(context)!.admin} ☆",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 25),
                                          ],
                                        ),
                                      ]else...[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${AppLocalizations.of(context)!.member} ",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 25),
                                          ],
                                        ),
                                      ]
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
              ]
            ],
          ),
        ),
      ),
    );
  }

  ///method
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 140,
        child: Card(
              color: _selectedOptionIndex == index
                  ? NasColors.darkBlue
                  : Colors.white,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : Colors.white,
                  width: 0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _selectedOptionIndex == index
                          ? Colors.white
                          : NasColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
  ///API CALL
  Future<ProjectsData?> getProjectsData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/kanban-project/getDataByemployeeId/$employeeId');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var projectsData = ProjectsData.fromJson(responseBody);
      if (projectsData.data != null && projectsData.data!.isNotEmpty) {
        singletonClass.projectsDataList.clear();
        singletonClass.projectsDataList.add(projectsData);
      }
      return projectsData;
    }
    return null;
  }

  ///Admin project data all projects
  Future<ProjectsData?> getAllProjects() async {
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/kanban-project');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var allProjectsData = ProjectsData.fromJson(responseBody);
      if (allProjectsData.data != null && allProjectsData.data!.isNotEmpty) {
        singletonClass.projectsDataList.clear();
        singletonClass.projectsDataList.add(allProjectsData);
      }
      return allProjectsData;
    }
    return null;
  }
  ///Task Api call
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
      singletonClass.taskModelList.clear();
      singletonClass.taskModelList.add(taskData);
      return taskData;
    }
    return null ;
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
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'designation': designation,
    };
  }
}