import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_model.dart';
import 'package:http/http.dart' as http;


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
  String? _selectedOption;
  int? _expandedIndex;
  bool isLoading = false;
  List<String>? _options;
  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _options = widget.projectData!.columnsStatus;
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
                        onTap: () => _toggleExpand(index),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          height: _expandedIndex == index ? 490 : 100,
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
                                      Text("${widget.projectData!.projectKey}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.pending,
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials(toDoTasks.assignTo!.first),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_expandedIndex == index) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.description,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          toDoTasks.description?.isNotEmpty == true ? toDoTasks.description! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.assignedTo,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          toDoTasks.assignTo?.isNotEmpty == true ? toDoTasks.assignTo!.first : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.type,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          toDoTasks.type?.isNotEmpty == true ? toDoTasks.type! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.duration,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          toDoTasks.estimatedDuration != null && toDoTasks.estimatedDuration!.isNotEmpty
                                              ? "${toDoTasks.estimatedDuration} ${AppLocalizations.of(context)!.days}"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.tag,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${toDoTasks.tag?.isNotEmpty == true ? toDoTasks.tag! : "---"}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.comments,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          toDoTasks.comments?.isNotEmpty == true
                                              ? toDoTasks.comments!.first.comments?.isNotEmpty == true
                                              ? toDoTasks.comments!.first.comments!
                                              : "---"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButton<String?>(
                                        elevation: 8,
                                        items: _options!.map((option) {
                                          return DropdownMenuItem<String>(
                                            value: option, // Pass the entire object as the value
                                            child: Text(
                                              option, // Display the employee name
                                              style: const TextStyle(
                                                  color: Colors.black), // Adjust text style
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState((){
                                            _selectedOption = value;
                                          });
                                          if (_selectedOption != null) {
                                            updateTask(
                                              toDoTasks.taskId,
                                              toDoTasks.id,
                                              toDoTasks.projectId,
                                              toDoTasks.subject,
                                              toDoTasks.description,
                                              toDoTasks.attachments,
                                              _selectedOption.toString(),
                                              toDoTasks.estimatedDuration,
                                              toDoTasks.type,
                                              toDoTasks.tag,
                                              toDoTasks.assignTo,
                                              toDoTasks.reportedTo!.first.manager,
                                              toDoTasks.logDuration!.first.date,
                                              toDoTasks.logDuration!.first.hours,
                                              toDoTasks.logDuration!.first.loggedBy,
                                              toDoTasks.subTask,
                                              toDoTasks.comments!.first.comments,
                                              toDoTasks.comments!.first.commentedBy,
                                              toDoTasks.comments!.first.commentedAt,
                                            ); // Update task with the selected status
                                          }
                                        },
                                        hint:  Text(
                                          AppLocalizations.of(context)!.selectStatus, // Hint text when no option is selected
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        value: _selectedOption,
                                        // Display the current selected value
                                        isExpanded: true,
                                        iconEnabledColor: Colors.black,
                                        // Icon color
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                        borderRadius: BorderRadius.circular(15),
                                        dropdownColor: Colors.white, // Background color of the dropdown
                                      ),
                                    ),
                                  ]

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
                        onTap: () => _toggleExpand(index),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          height: _expandedIndex == index ? 490 : 100,
                          // Adjust height based on expanded state
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
                                      Text("${widget.projectData!.projectKey}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.onTime, // Background color for initials
                                          height: 40, // Adjust the size of the oval
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials(inProgressTasks.assignTo!.first),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_expandedIndex == index) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.description,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          inProgressTasks.description?.isNotEmpty == true ? inProgressTasks.description! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.assignedTo,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          inProgressTasks.assignTo?.isNotEmpty == true ? inProgressTasks.assignTo!.first : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.type,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          inProgressTasks.type?.isNotEmpty == true ? inProgressTasks.type! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.duration,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          inProgressTasks.estimatedDuration != null && inProgressTasks.estimatedDuration!.isNotEmpty
                                              ? "${inProgressTasks.estimatedDuration} ${AppLocalizations.of(context)!.days}"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.tag,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${inProgressTasks.tag?.isNotEmpty == true ? inProgressTasks.tag! : "---"}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.comments,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          inProgressTasks.comments?.isNotEmpty == true
                                              ? inProgressTasks.comments!.first.comments?.isNotEmpty == true
                                              ? inProgressTasks.comments!.first.comments!
                                              : "---"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButton<String?>(
                                        elevation: 8,
                                        items: _options!.map((option) {
                                          return DropdownMenuItem<String>(
                                            value: option, // Pass the entire object as the value
                                            child: Text(
                                              option, // Display the employee name
                                              style: const TextStyle(
                                                  color: Colors.black), // Adjust text style
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption =
                                                value; // Update the selected option with the whole object
                                          });
                                          if (_selectedOption != null) {
                                            updateTask(
                                              inProgressTasks.taskId,
                                              inProgressTasks.id,
                                              inProgressTasks.projectId,
                                              inProgressTasks.subject,
                                              inProgressTasks.description,
                                              inProgressTasks.attachments,
                                              _selectedOption.toString(),
                                              inProgressTasks.estimatedDuration,
                                              inProgressTasks.type,
                                              inProgressTasks.tag,
                                              inProgressTasks.assignTo,
                                              inProgressTasks.reportedTo!.first.manager,
                                              inProgressTasks.logDuration!.first.date,
                                              inProgressTasks.logDuration!.first.hours,
                                              inProgressTasks.logDuration!.first.loggedBy,
                                              inProgressTasks.subTask,
                                              inProgressTasks.comments!.first.comments,
                                              inProgressTasks.comments!.first.commentedBy,
                                              inProgressTasks.comments!.first.commentedAt,
                                            ); // Update task with the selected status
                                          }
                                        },
                                        hint:  Text(
                                          AppLocalizations.of(context)!.selectStatus, // Hint text when no option is selected
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        value: _selectedOption,
                                        // Display the current selected value
                                        isExpanded: true,
                                        iconEnabledColor: Colors.black,
                                        // Icon color
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                        borderRadius: BorderRadius.circular(15),
                                        dropdownColor: Colors.white, // Background color of the dropdown
                                      ),
                                    ),
                                  ]
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
                        onTap:  () => _toggleExpand(index),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 300),
                          height: _expandedIndex == index ? 490 : 100,
                          // Adjust height based on expanded state
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
                                      Text("${widget.projectData!.projectKey}"),
                                      const Spacer(),
                                      ClipOval(
                                        child: Container(
                                          color: NasColors.pending, // Background color for initials
                                          height: 40, // Adjust the size of the oval
                                          width: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getInitials(completed.assignTo!.first),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_expandedIndex == index) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.description,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          completed.description?.isNotEmpty == true ? completed.description! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.assignedTo,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          completed.assignTo?.isNotEmpty == true ? completed.assignTo!.first : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.type,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          completed.type?.isNotEmpty == true ? completed.type! : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.duration,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          completed.estimatedDuration != null && completed.estimatedDuration!.isNotEmpty
                                              ? "${completed.estimatedDuration} ${AppLocalizations.of(context)!.days}"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.tag,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${completed.tag?.isNotEmpty == true ? completed.tag! : "---"}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.comments,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          completed.comments?.isNotEmpty == true
                                              ? completed.comments!.first.comments?.isNotEmpty == true
                                              ? completed.comments!.first.comments!
                                              : "---"
                                              : "---",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButton<String?>(
                                        elevation: 8,
                                        items: _options!.map((option) {
                                          return DropdownMenuItem<String>(
                                            value: option, // Pass the entire object as the value
                                            child: Text(
                                              option, // Display the employee name
                                              style: const TextStyle(
                                                  color: Colors.black), // Adjust text style
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption =
                                                value; // Update the selected option with the whole object
                                          });
                                          if (_selectedOption != null) {
                                            updateTask(
                                              completed.taskId,
                                              completed.id,
                                              completed.projectId,
                                              completed.subject,
                                              completed.description,
                                              completed.attachments,
                                              _selectedOption.toString(),
                                              completed.estimatedDuration,
                                              completed.type,
                                              completed.tag,
                                              completed.assignTo,
                                              completed.reportedTo!.first.manager,
                                              completed.logDuration!.first.date,
                                              completed.logDuration!.first.hours,
                                              completed.logDuration!.first.loggedBy,
                                              completed.subTask,
                                              completed.comments!.first.comments,
                                              completed.comments!.first.commentedBy,
                                              completed.comments!.first.commentedAt,
                                            ); // Update task with the selected status
                                          }
                                        },
                                        hint:  Text(
                                            AppLocalizations.of(context)!.selectStatus, // Hint text when no option is selected
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        value: _selectedOption,
                                        // Display the current selected value
                                        isExpanded: true,
                                        iconEnabledColor: Colors.black,
                                        // Icon color
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                        borderRadius: BorderRadius.circular(15),
                                        dropdownColor: Colors.white, // Background color of the dropdown
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }))
              ],

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
    return "N/A"; // Default for missing names
  }

  void updateTask(
      String? taskId,
      String? id,
      String? projectId,
      String? subject,
      String? description,
      String? attachments,
      String? status,
      String? estimatedDuration,
      String? type,
  List<String>? tag,
      List<String>? assignTo,
      String? reportedTo,
      String? date,
      String? hours,
      String? loggedBy,
      List<String>? subTask,
      String? comments,
      String? commentsBy,
      String? commentAt,
      ) async {
    String url = '${singletonClass.baseURL}/kanban-task/$id'; // Adjust the endpoint as needed
    Map<String, dynamic> data = {
      "projectId": projectId,
      "taskId": taskId, // Use the provided taskId
      "subject": subject,
      "description": description,
      "attachments": attachments,
      "status": status,
      "estimatedDuration": estimatedDuration,
      "type": type,
      "tag": tag,
      "assignTo": assignTo,
      "reportedTo": {"manager": reportedTo},
      "logDuration": [
        {
          "date": date,
          "hours": hours,
          "description": description,
          "loggedBy": loggedBy,
        }
      ],
      "subTask": subTask,
      "comments": [
        {
          "comments": comments,
          "commentedBy": commentsBy,
          "commentedAt": commentAt
        }
      ]
    };
    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    log(jsonData);
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      log("PATCH CALL RESPONSE ${response.body}");
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
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const MainScreen()));
          singletonClass.taskModelList.clear();
        } else if (decodedResponse['statusCode'] == 400 || decodedResponse['statusCode'] == 500) {
          // Check for null before accessing the error message
          String errorMessage = decodedResponse['data'] != null && decodedResponse['data']['message'] != null
              ? decodedResponse['data']['message']
              : 'Unknown error';
          log('Error: $errorMessage');
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: errorMessage,
            type: QuickAlertType.error,
          );
        }
      } else {
        // Handle response errors outside the 200 range
        String errorResponse = response.body;
        log('API Response Error: $errorResponse');
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
      // Log error if the request fails
      log('Exception: $error');
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: 'Failed to update task. Error: $error',
        type: QuickAlertType.error,
      );
    }
  }

}
