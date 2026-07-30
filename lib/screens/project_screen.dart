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
  bool isLoading = true;
  int _selectedOptionIndex = 0;
  List<Data> _allProjectsList = [];
  List<Data> _myProjectsList = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      await getTasks();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    }

    final String? grade = singletonClass.getJWTModel()?.grade;
    if (grade == "L0" || grade == "L1") {
      try {
        final allRes = await getAllProjects();
        if (allRes != null && allRes.data != null) {
          _allProjectsList = allRes.data!;
        }
      } catch (e) {
        debugPrint("Error fetching all projects: $e");
      }
    }

    try {
      final myRes = await getProjectsData();
      if (myRes != null && myRes.data != null) {
        _myProjectsList = myRes.data!;
      }
    } catch (e) {
      debugPrint("Error fetching my projects: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchLatestProjectData() async {
    await _loadAllData();
  }

  Widget _buildHeader(BuildContext context, bool canCreateProject) {
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
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.project,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (canCreateProject)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
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
      body: Column(
        children: [
          _buildHeader(context, canCreateProject),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                color: NasColors.darkBlue,
                backgroundColor: Colors.white,
                onRefresh: fetchLatestProjectData,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isLoading) ...[
                const Expanded(
                  child: Center(
                    child: Loader(),
                  ),
                ),
              ] else ...[
                if (singletonClass.getJWTModel()?.grade == "L0" ||
                    singletonClass.getJWTModel()?.grade == "L1") ...[
                  SizedBox(
                    height: 54,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        _FilterChip(
                          label: AppLocalizations.of(context)!.all,
                          count: _allProjectsList.length,
                          selected: _selectedOptionIndex == 0,
                          accentColor: NasColors.darkBlue,
                          onTap: () {
                            setState(() {
                              _selectedOptionIndex = 0;
                            });
                          },
                        ),
                        _FilterChip(
                          label: AppLocalizations.of(context)!.myProjects,
                          count: _myProjectsList.length,
                          selected: _selectedOptionIndex == 1,
                          accentColor: NasColors.onTime,
                          onTap: () {
                            setState(() {
                              _selectedOptionIndex = 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildProjectsList(
                      _selectedOptionIndex == 0 ? _allProjectsList : _myProjectsList,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: _buildProjectsList(_myProjectsList),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ),
  ],
),
);
  }

  Widget _buildProjectsList(List<Data> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('images/empty.json'),
              ),
              const SizedBox(height: 10),
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
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildProjectCard(list[index]);
      },
    );
  }

  Widget _buildProjectCard(Data project) {
    final taskCount = getTaskCountForProject("${project.id}");
    final isAdmin = project.adminId == singletonClass.getJWTModel()?.employeeId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskScreen(projectData: project),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: project.logo == null || project.logo!.isEmpty
                      ? _getThemeColorForProject(project.name ?? '')
                      : Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: project.logo != null && project.logo!.isNotEmpty
                      ? Image.network(
                          project.logo!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultProjectIcon(project.name ?? ''),
                        )
                      : _buildDefaultProjectIcon(project.name ?? ''),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name ?? '---',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            project.projectKey ?? '---',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isAdmin 
                                ? NasColors.pending.withOpacity(0.12) 
                                : NasColors.darkBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAdmin 
                                ? "${AppLocalizations.of(context)!.admin} ★" 
                                : AppLocalizations.of(context)!.member,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: isAdmin ? NasColors.pending : NasColors.darkBlue,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (taskCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: NasColors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_rounded,
                        size: 14,
                        color: NasColors.rose,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$taskCount',
                        style: GoogleFonts.inter(
                          color: NasColors.brightRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  int getTaskCountForProject(String projectId) {
    int count = 0;

    for (final taskModel in singletonClass.taskModelList) {
      final tasks = taskModel.data;
      if (tasks == null) continue;

      count += tasks.where((task) => task.projectId == projectId).length;
    }

    return count;
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

  Widget _buildDefaultProjectIcon(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getThemeColorForProject(String name) {
    final int hash = name.hashCode.abs();
    final List<Color> colors = [
      Colors.blue.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.amber.shade700,
    ];
    return colors[hash % colors.length];
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

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: accentColor.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            else
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}