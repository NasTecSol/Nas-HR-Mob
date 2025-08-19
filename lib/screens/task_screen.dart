import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/request_controller/task_model.dart';
import 'package:nashr/screens/create_task_screen.dart';
import 'package:nashr/screens/task_detail_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/projects_data_model.dart';

class TaskScreen extends StatefulWidget {
  final Data? projectData;
  const TaskScreen({super.key, this.projectData});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  SingletonClass singletonClass = SingletonClass();
  List<Dattaa> filteredTaskList = [];
  final List<String> imagePaths = [
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
    'images/DP.png',
  ];
  @override
  void initState(){
    super.initState();
    setState(() {
      filterTasks();
    });
    setState(() {

    });
  }
  void filterTasks() {
    if (filteredTaskList.isNotEmpty) {
      if (kDebugMode) {
        print('Filtered tasks already populated');
      }
      return;
    }

    List<Dattaa> newFilteredTaskList = [];

    // Loop through TaskModel list
    for (TaskModel taskModel in singletonClass.taskModelList) {
      // Check if the taskModel has data
      if (taskModel.data != null) {
        // Loop through the task data inside each taskModel
        for (var task in taskModel.data!) {
          // Compare the projectId from the task with the projectId from widget.projectData
          if (task.projectId == widget.projectData?.id) {
            // If task is not already in the newFilteredTaskList, add it
            if (!newFilteredTaskList.any((existingTask) => existingTask.id == task.id)) {
              newFilteredTaskList.add(task);
            }
          }
        }
      }
    }

    // Only update filteredTaskList if new tasks were found
    if (newFilteredTaskList.isNotEmpty) {
      setState(() {
        filteredTaskList = newFilteredTaskList;
      });
      if (kDebugMode) {
        print('Filtered tasks: ${filteredTaskList.length}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    /// Filter tasks by status
    List<Dattaa> toDoTasks = filteredTaskList.where((task) => task.status == "TODO").toList();
    List<Dattaa> inProgressTask = filteredTaskList.where((task) => task.status == "InProgress").toList();
    List<Dattaa> completedTask = filteredTaskList.where((task) => task.status == "completed").toList();

    /// Get the total number of tasks for each status
    int totalToDoTasks = toDoTasks.length;
    int totalInProgressTasks = inProgressTask.length;
    int totalCompletedTasks = completedTask.length;
    int totalToDoAssignees = 0;
    int totalInProgressAssignees = 0;
    int totalCompletedAssignees = 0;
    String toDoTags = "";
    String inProgressTags = "";
    String completedTags = "";

    for (var task in toDoTasks) {
      totalToDoAssignees += task.assignTo!.length;
      if (task.tag != null) {
        toDoTags += ("${task.tag!}, ");
      }
    }

    if (toDoTags.isNotEmpty) {
      toDoTags = toDoTags.substring(0, toDoTags.length - 2);
    }
    for (var task in inProgressTask) {
      totalInProgressAssignees += task.assignTo!.length;
      if (task.tag != null) {
        inProgressTags += ("${task.tag!}, ");
      }
    }
    if (inProgressTags.isNotEmpty) {
      inProgressTags = inProgressTags.substring(0, inProgressTags.length - 2);
    }
    for (var task in completedTask) {
      totalCompletedAssignees += task.assignTo!.length;
      if (task.tag != null) {
        completedTags += ("${task.tag!}, ");
      }
    }
    if (completedTags.isNotEmpty) {
      completedTags = completedTags.substring(0, completedTags.length - 2);
    }
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [ Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      AppLocalizations.of(context)!.tasks,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  const Spacer(),
                  if (singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1' || singletonClass.getJWTModel()?.grade == 'L2' || singletonClass.getJWTModel()?.grade == 'L3')
                   TextButton(
                      child: Text(AppLocalizations.of(context)!.createAnIssue,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateTaskScreen(projectData: widget.projectData,)));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 520,
                      width: 20, // Adjusted the width for visibility
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        color: NasColors.darkBlue,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                          color: Colors.grey[200],
                        ),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                          child: Column(
                            children: [
                              //To Do Code
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailScreen(toDoTasks: toDoTasks,projectData: widget.projectData,)));
                                },
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: NasColors.pending,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(AppLocalizations.of(context)!.tdo,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text("$totalToDoAssignees ${AppLocalizations.of(context)!.assignee}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.task_outlined, size: 25),
                                          Text("${AppLocalizations.of(context)!.tasks}: $totalToDoTasks",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              ...List.generate(
                                                totalToDoAssignees > 3 ? 3 : totalToDoAssignees,
                                                    (index) => Transform.translate(
                                                  offset: Offset(index * -15.0, 0), // Adjust overlap distance
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 1),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        imagePaths[index], // Replace with your imagePaths list
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (totalToDoAssignees > 3)
                                                Transform.translate(
                                                  offset: const Offset(-30.0, 0), // Adjust overlap for "+n"
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.grey[300],
                                                      border: Border.all(color: Colors.white, width: 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${totalToDoAssignees - 3}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),


                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.tag, size: 25),
                                          SizedBox(
                                            width: 250,
                                            child: Text("${AppLocalizations.of(context)!.tag}: $toDoTags",
                                              maxLines: 5,
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text('*'),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Calculate the number of dots based on available width
                                                int dotCount = (constraints.maxWidth / 10).floor();
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: List.generate(dotCount, (_) => const Text('.')),
                                                );
                                              },
                                            ),
                                          ),
                                          const Text('*'),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                              //In Progress Code
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailScreen(inProgressTasks: inProgressTask,projectData: widget.projectData,)));
                                },
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: NasColors.onTime,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(AppLocalizations.of(context)!.inProgress,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text("$totalInProgressAssignees ${AppLocalizations.of(context)!.assignee}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.task_outlined,
                                            size: 25,
                                          ),
                                          Text("${AppLocalizations.of(context)!.tasks}: $totalInProgressTasks",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              ...List.generate(
                                                totalInProgressAssignees > 3 ? 3 : totalInProgressAssignees,
                                                    (index) => Transform.translate(
                                                  offset: Offset(index * -15.0, 0), // Adjust overlap distance
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 1),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        imagePaths[index], // Replace with your imagePaths list
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (totalInProgressAssignees > 3)
                                                Transform.translate(
                                                  offset: const Offset(-30.0, 0), // Adjust overlap for "+n"
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.grey[300],
                                                      border: Border.all(color: Colors.white, width: 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${totalInProgressAssignees - 3}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.tag,
                                            size: 25,),
                                          Text(AppLocalizations.of(context)!.tag,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(inProgressTags,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text('*'),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Calculate the number of dots based on available width
                                                int dotCount = (constraints.maxWidth / 10).floor();
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: List.generate(dotCount, (_) => const Text('.')),
                                                );
                                              },
                                            ),
                                          ),
                                          const Text('*'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Completed Code
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailScreen(completedTask: completedTask,projectData: widget.projectData,)));
                                },
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: NasColors.completed,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(AppLocalizations.of(context)!.completed,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text("$totalCompletedAssignees ${AppLocalizations.of(context)!.assignee}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.task_outlined,
                                            size: 25,
                                          ),
                                          Text("${AppLocalizations.of(context)!.tasks}: $totalCompletedTasks",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              ...List.generate(
                                                totalCompletedAssignees > 3 ? 3 : totalCompletedAssignees,
                                                    (index) => Transform.translate(
                                                  offset: Offset(index * -15.0, 0), // Adjust overlap distance
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.white, width: 1),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        imagePaths[index], // Replace with your imagePaths list
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (totalCompletedAssignees > 3)
                                                Transform.translate(
                                                  offset: const Offset(-30.0, 0), // Adjust overlap for "+n"
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.grey[300],
                                                      border: Border.all(color: Colors.white, width: 2),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${totalCompletedAssignees - 3}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.tag,
                                            size: 25,),
                                          Text(AppLocalizations.of(context)!.tag,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(completedTags,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              ,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text('*'),
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                // Calculate the number of dots based on available width
                                                int dotCount = (constraints.maxWidth / 10).floor();
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: List.generate(dotCount, (_) => const Text('.')),
                                                );
                                              },
                                            ),
                                          ),
                                          const Text('*'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
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
    );
  }
}
