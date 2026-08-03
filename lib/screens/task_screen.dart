import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/request_controller/task_model.dart';
import 'package:nashr/screens/create_task_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/screens/task_detail_screen_details.dart';
import 'package:nashr/widgets/loader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskScreen extends StatefulWidget {
  final Data? projectData;
  const TaskScreen({super.key, this.projectData});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  SingletonClass singletonClass = SingletonClass();
  List<Dattaa> filteredTaskList = [];
  bool _isLoading = false;
  final List<String> imagePaths = [
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await getTasks();
      filterTasks();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching tasks: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<TaskModel?> getTasks() async {
    var client = http.Client();
    var uri = Uri.parse('${singletonClass.baseURL}/kanban-task');
    var response = await client.get(uri, headers: singletonClass.getHeaders());
    if (kDebugMode) {
      print("Task Data Log ${response.body}");
    }
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var taskData = TaskModel.fromJson(responseBody);
      singletonClass.taskModelList.clear();
      singletonClass.taskModelList.add(taskData);
      return taskData;
    }
    return null;
  }

  Future<void> updateTaskStatusInBackend(Dattaa task, String newStatus) async {
    String url = '${singletonClass.baseURL}/kanban-task/${task.id}';
    
    Map<String, dynamic> data = task.toJson();
    data["status"] = newStatus;
    
    String jsonData = jsonEncode(data);
    final response = await http.patch(
      Uri.parse(url),
      headers: singletonClass.getHeaders(),
      body: jsonData,
    );
    
    if (kDebugMode) {
      print("PATCH Task Response: ${response.body}");
    }
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['statusCode'] == 200) {
        // Success
      } else {
        throw Exception(decoded['statusMessage'] ?? "Failed to update status");
      }
    } else {
      throw Exception("HTTP Error: ${response.statusCode}");
    }
  }
  void filterTasks() {
    List<Dattaa> newFilteredTaskList = [];
    for (TaskModel taskModel in singletonClass.taskModelList) {
      if (taskModel.data != null) {
        for (var task in taskModel.data!) {
          if (task.projectId == widget.projectData?.id) {
            if (!newFilteredTaskList.any((existingTask) => existingTask.id == task.id)) {
              newFilteredTaskList.add(task);
            }
          }
        }
      }
    }

    setState(() {
      filteredTaskList = newFilteredTaskList;
    });
    if (kDebugMode) {
      print('Filtered tasks: ${filteredTaskList.length}');
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<String> columns = widget.projectData?.columnsStatus ?? ["TODO", "InProgress", "Completed"];

    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
        .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
        [])
        : [];
    final canCreateTask = uiSettings.any((e) {
      if (e.title == "Teams" && e.hidden == false) {
        return e.subMenu?.any((sub) =>
        (sub.title == "Manage Tasks" || sub.title == "Manage Tasks") &&
            sub.accessType!.write == true) ??
            false;
      }
      return false;
    });

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          /// Curved Gradient Header (NO icon in title text)
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  NasColors.darkBlue,
                  NasColors.lightBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: NasColors.darkBlue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.18),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.3)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.projectData?.name ??
                            AppLocalizations.of(context)!.tasks,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AppLocalizations.of(context)!.tasks,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCreateTask)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTaskScreen(
                            projectData: widget.projectData,
                          ),
                        ),
                      );
                      _fetchTasks();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.createAnIssue,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                    ? Center(child: Loader())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                             ...columns.map((colStatus) {
                              final colTasks = filteredTaskList.where((task) {
                                final tStatus = task.status?.toLowerCase().replaceAll(' ', '') ?? '';
                                final cStatus = colStatus.toLowerCase().replaceAll(' ', '');
                                return tStatus == cStatus;
                              }).toList();
                              return _buildKanbanColumn(colStatus, colTasks);
                            }),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String status, List<Dattaa> tasks) {
    Color headerColor;
    String statusTitle;
    
    if (status == "TODO" || status.toLowerCase() == "todo") {
      headerColor = NasColors.pending;
      statusTitle = AppLocalizations.of(context)!.tdo;
    } else if (status == "InProgress" || status.toLowerCase() == "inprogress" || status.toLowerCase() == "in progress") {
      headerColor = NasColors.onTime;
      statusTitle = AppLocalizations.of(context)!.inProgress;
    } else if (status == "Completed" || status.toLowerCase() == "completed" || status.toLowerCase() == "done") {
      headerColor = NasColors.completed;
      statusTitle = AppLocalizations.of(context)!.completed;
    } else {
      headerColor = NasColors.darkBlue;
      statusTitle = status;
    }

    return DragTarget<Dattaa>(
      onAcceptWithDetails: (details) async {
        final Dattaa task = details.data;
        if (task.status == status) return;

        final oldStatus = task.status;
        setState(() {
          task.status = status;
          filterTasks();
        });

        try {
          await updateTaskStatusInBackend(task, status);
        } catch (e) {
          if (kDebugMode) print("Failed status update: $e");
          setState(() {
            task.status = oldStatus;
            filterTasks();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update task status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return Container(
          width: MediaQuery.of(context).size.width * 0.82,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOver ? Colors.grey.shade300 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isOver ? headerColor.withOpacity(0.5) : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.12),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: headerColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusTitle,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: headerColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Draggable<Dattaa>(
                            data: task,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.78,
                                child: _buildTaskCard(task, isDragging: true),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.4,
                              child: _buildTaskCard(task),
                            ),
                            child: _buildTaskCard(task),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Dattaa task, {bool isDragging = false}) {
    final hasPriority = task.type == "Bug";
    
    return GestureDetector(
      onTap: () async {
        final String statusLower = task.status?.toLowerCase().replaceAll(' ', '') ?? '';
        if (statusLower == "todo") {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreenDetails(
                toDoTasks: [task],
                projectData: widget.projectData,
              ),
            ),
          );
        } else if (statusLower == "inprogress") {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreenDetails(
                inProgressTasks: [task],
                projectData: widget.projectData,
              ),
            ),
          );
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreenDetails(
                completedTask: [task],
                projectData: widget.projectData,
              ),
            ),
          );
        }
        _fetchTasks();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasPriority ? Icons.bug_report_rounded : Icons.assignment_rounded,
                          color: hasPriority ? Colors.red.shade400 : NasColors.darkBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            task.taskId ?? 'NO-KEY',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (task.estimatedDuration != null && task.estimatedDuration!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Text(
                            task.estimatedDuration!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.subject ?? '---',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              if (task.tag != null && task.tag!.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: task.tag!.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NasColors.darkBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.type ?? 'Task',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasPriority ? Colors.red.shade400 : Colors.blue.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildAssigneesRow(task.assignTo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssigneesRow(List<AssignTo>? assignTo) {
    if (assignTo == null || assignTo.isEmpty) return const SizedBox.shrink();
    
    final int count = assignTo.length;
    final int maxDisplay = 3;
    final displayList = assignTo.take(maxDisplay).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(displayList.length, (index) {
          final assignee = displayList[index];
          final String name = assignee.userName ?? '';
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

          return Transform.translate(
            offset: Offset(index * -8.0, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
        if (count > maxDisplay)
          Transform.translate(
            offset: Offset(maxDisplay * -8.0, 0),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '+${count - maxDisplay}',
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
