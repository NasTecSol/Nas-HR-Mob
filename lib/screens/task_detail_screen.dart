import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/task_detail_screen_details.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_model.dart';


class TaskDetailScreen extends StatefulWidget {
  final List<Dattaa>? toDoTasks;
  final List<Dattaa>? inProgressTasks;
  final List<Dattaa>? completedTask;
  final Data? projectData;
  const TaskDetailScreen({super.key,  this.toDoTasks, this.projectData, this.inProgressTasks, this.completedTask});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
   setState(() {

   });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(
          children: [ Column(
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
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    widget.toDoTasks?.isNotEmpty == true
                        ? (widget.toDoTasks!.first.status == "TODO" ?  AppLocalizations.of(context)!.tdo : AppLocalizations.of(context)!.tdo)
                        : widget.inProgressTasks?.isNotEmpty == true
                        ? (widget.inProgressTasks!.first.status == "InProgress" ?  AppLocalizations.of(context)!.inProgress : AppLocalizations.of(context)!.inProgress)
                        : widget.completedTask?.isNotEmpty == true
                        ? (widget.completedTask!.first.status == "Completed" ?  AppLocalizations.of(context)!.completed : AppLocalizations.of(context)!.completed)
                        : "____",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: NasColors.darkBlue,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              if (widget.toDoTasks != null &&
                  widget.toDoTasks!.isNotEmpty &&
                  widget.toDoTasks!.first.status == "TODO")...[
                Expanded(
                    child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.toDoTasks!.length,
                    itemBuilder: (BuildContext context, int index){
                      final toDoTasks = widget.toDoTasks![index];
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskDetailScreenDetails(toDoTasks: [toDoTasks],projectData: widget.projectData, )));
                        },
                        child: Container(
                          height: 100,
                          width: 400,
                          margin: const EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("${toDoTasks.subject}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.bug_report_outlined,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      Text("${toDoTasks.taskId}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.pending,
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials("${toDoTasks.assignTo!.first.userName}"),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
              ],
              if (widget.inProgressTasks != null &&
                  widget.inProgressTasks!.isNotEmpty &&
                  widget.inProgressTasks!.first.status == "InProgress")...[
                Expanded(child:
                ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.inProgressTasks!.length,
                    itemBuilder: (BuildContext context, int index){
                      final inProgressTasks = widget.inProgressTasks![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskDetailScreenDetails(inProgressTasks: [inProgressTasks],projectData: widget.projectData, )));
                        },
                        child: Container(
                          height: 100,
                          width: 400,
                          margin: const EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("${inProgressTasks.subject}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.bug_report_outlined,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      Text("${inProgressTasks.taskId}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.onTime,
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials("${inProgressTasks.assignTo!.first.userName}"),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
              ],
              if (widget.completedTask != null &&
                  widget.completedTask!.isNotEmpty &&
                  widget.completedTask!.first.status == "Completed")...[
                Expanded(child:
                ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.completedTask!.length,
                    itemBuilder: (BuildContext context, int index){
                      final completed = widget.completedTask![index];
                      return GestureDetector(
                        onTap:  () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskDetailScreenDetails(completedTask: [completed],projectData: widget.projectData, )));
                        },
                        child: Container(
                          height:100,
                          width: 400,
                          margin: const EdgeInsets.only(top: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("${completed.subject}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.bug_report_outlined,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      Text("${completed.taskId}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.pending,
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials("${completed.assignTo!.first.userName}"),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
              ] 
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
    );
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return "${nameParts.first[0]}${nameParts.last[0]}".toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return "---";
  }

}
