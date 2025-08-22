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

import '../request_controller/task_model.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getTasks();
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
                if(singletonClass
                    .getJWTModel()
                    ?.grade == 'L0' || singletonClass
                    .getJWTModel()
                    ?.grade == 'L1')...[
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
                              // Optional padding for better tap target
                              color: Colors.transparent,
                              // Makes the whole area tappable
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
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
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
  ///API CALL
  Future<ProjectsData?> getProjectsData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('${singletonClass
        .baseURL}/kanban-project/getDataByadminId/$employeeId');
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
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'designation': designation,
    };
  }
}