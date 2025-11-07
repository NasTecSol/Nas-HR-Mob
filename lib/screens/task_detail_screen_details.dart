import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_model.dart';
import 'package:nashr/l10n/app_localizations.dart';

import '../widgets/loader.dart';
import 'main_screen.dart';

class TaskDetailScreenDetails extends StatefulWidget {
  final List<Dattaa>? toDoTasks;
  final List<Dattaa>? inProgressTasks;
  final List<Dattaa>? completedTask;
  final Data? projectData;

  const TaskDetailScreenDetails({super.key,
    this.toDoTasks,
    this.inProgressTasks,
    this.completedTask,
    this.projectData,});

  @override
  State<TaskDetailScreenDetails> createState() => _TaskDetailScreenDetailsState();
}

class _TaskDetailScreenDetailsState extends State<TaskDetailScreenDetails> {
  SingletonClass singletonClass = SingletonClass();
  final TextEditingController comment = TextEditingController();
  String? _selectedOption;
  bool isLoading = false;
  List<String>? _options;

  @override
  void initState() {
    super.initState();
    _options = widget.projectData!.columnsStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
            children: [
              Column(
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
                      AppLocalizations.of(context)!.taskDetails,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                if (widget.toDoTasks != null &&
                    widget.toDoTasks!.isNotEmpty &&
                    widget.toDoTasks!.first.status == "TODO")...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                          width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                          color: NasColors.pending,
                        ),
                        child: DropdownButton<String?>(
                          elevation: 8,
                          items: _options!.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  _selectedOption == null ?
                                  Text(
                                    option,
                                    style: GoogleFonts.inter(color: Colors.black),
                                  ) : Text(
                                    _selectedOption.toString(),
                                    style: GoogleFonts.inter(color: Colors.white),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                            });
                            if (_selectedOption != null) {
                              final date = DateTime.now();
                              final commentToSend = comment.text.trim().isEmpty
                                  ? widget.toDoTasks!.first.comments!.first.comments
                                  : comment.text.trim();
                              final commentBy = comment.text.trim().isEmpty
                                  ? widget.toDoTasks!.first.comments!.first.commentedBy
                                  : singletonClass.getJWTModel()?.userName;
                              final commentedAt= comment.text.trim().isEmpty
                                  ? widget.toDoTasks!.first.comments!.first.commentedAt
                                  : date;
                              final selectOption = _selectedOption == null
                                  ? widget.toDoTasks!.first.status
                                  : _selectedOption.toString();
                              updateTask(
                                "TODO",
                                widget.toDoTasks!.first.taskId,
                                widget.toDoTasks!.first.id,
                                widget.toDoTasks!.first.projectId,
                                widget.toDoTasks!.first.subject,
                                widget.toDoTasks!.first.description,
                                widget.toDoTasks!.first.attachments,
                                selectOption.toString(),
                                widget.toDoTasks!.first.estimatedDuration,
                                widget.toDoTasks!.first.type,
                                widget.toDoTasks!.first.tag,
                                widget.toDoTasks!.first.assignTo,
                                widget.toDoTasks!.first.reportedTo!.first.manager,
                                widget.toDoTasks!.first.logDuration!.first.date,
                                widget.toDoTasks!.first.logDuration!.first.hours,
                                widget.toDoTasks!.first.logDuration!.first.loggedBy,
                                widget.toDoTasks!.first.subTask,
                                commentToSend,
                                commentBy,
                                commentedAt.toString(),
                              );
                            }
                          },
                          hint: Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.toDoTasks!.first.status}",
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ],
                          ),
                          value: _selectedOption,
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          icon: SizedBox(),
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor:
                          Colors.white, // Background color of the dropdown
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 80,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${widget.toDoTasks!.first.subject}",
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'images/DP.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.assignedTo,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${widget.toDoTasks!.first.assignTo!.first.userName}",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                      Text(
                        singletonClass.formatDate2(
                            widget.toDoTasks!.first.logDuration!.first.date! , context),
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.project,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          "${widget.projectData!.logo}",
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "${widget.projectData!.name}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        child: Text(
                          "${widget.toDoTasks!.first.description}",
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.attachment,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 200,
                        child: GestureDetector(
                          onTap: () async {
                            String url = "${widget.toDoTasks!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Image.network(
                                        "${widget.toDoTasks!.first.attachments}",
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (url.endsWith(".pdf") || (url.endsWith(".doc") || url.endsWith(".docx"))) {
                              final Uri uri = Uri.parse("${widget.toDoTasks!.first.attachments}");
                              if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Unsupported file type")),
                              );
                            }
                          },
                          child: (() {
                            String url = "${widget.toDoTasks!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              return Image.network(
                                "${widget.toDoTasks!.first.attachments}",
                                fit: BoxFit.cover,
                              );
                            } else if (url.endsWith(".pdf")) {
                              return const Icon(Icons.picture_as_pdf,
                                  size: 50, color: Colors.red);
                            } else if (url.endsWith(".doc") || url.endsWith(".docx")) {
                              return const Icon(Icons.description,
                                  size: 50, color: Colors.blue);
                            } else {
                              return const Icon(Icons.attach_file,
                                  size: 50, color: Colors.grey);
                            }
                          })(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.comments,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.toDoTasks != null && widget.toDoTasks!.first.comments != null)
                        ...widget.toDoTasks!.first.comments!.map((c) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.comments ?? "---",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${c.commentedBy ?? '---'} • ${singletonClass.formatDate2(c.commentedAt.toString(), context)}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Text(
                          "---",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ],
                if (widget.inProgressTasks != null &&
                    widget.inProgressTasks!.isNotEmpty &&
                    widget.inProgressTasks!.first.status == "InProgress")...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                          color:  widget.inProgressTasks!.first.status == 'InProgress' ? NasColors.onTime : NasColors.pending,
                        ),
                        child: DropdownButton<String?>(
                          elevation: 8,
                          items: _options!.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  _selectedOption == null ?
                                  Text(
                                    option,
                                    style: GoogleFonts.inter(color: Colors.black),
                                  ) : Text(
                                    _selectedOption.toString(),
                                    style: GoogleFonts.inter(color: Colors.white),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                            });
                            if (_selectedOption != null) {
                              final date = DateTime.now();
                              final commentBy = comment.text.trim().isEmpty
                                  ? widget.inProgressTasks!.first.comments!.first.commentedBy
                                  : singletonClass.getJWTModel()?.userName;
                              final commentedAt= comment.text.trim().isEmpty
                                  ? widget.inProgressTasks!.first.comments!.first.commentedAt
                                  : date;
                              final commentToSend = comment.text.trim().isEmpty
                                  ? widget.inProgressTasks!.first.comments!.first.comments
                                  : comment.text.trim();
                              final selectOption = _selectedOption == null
                                  ? widget.inProgressTasks!.first.status
                                  : _selectedOption.toString();
                              updateTask(
                                "InProgress",
                                  widget.inProgressTasks!.first.taskId,
                                  widget.inProgressTasks!.first.id,
                                  widget.inProgressTasks!.first.projectId,
                                  widget.inProgressTasks!.first.subject,
                                  widget.inProgressTasks!.first.description,
                                  widget.inProgressTasks!.first.attachments,
                                  selectOption.toString(),
                            widget.inProgressTasks!.first.estimatedDuration,
                            widget.inProgressTasks!.first.type,
                            widget.inProgressTasks!.first.tag,
                            widget.inProgressTasks!.first.assignTo,
                            widget.inProgressTasks!.first.reportedTo!.first.manager,
                            widget.inProgressTasks!.first.logDuration!.first.date,
                            widget.inProgressTasks!.first.logDuration!.first.hours,
                            widget.inProgressTasks!.first.logDuration!.first.loggedBy,
                            widget.inProgressTasks!.first.subTask,
                            commentToSend,
                            commentBy,
                            commentedAt.toString());
                            }
                          },
                          hint: Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.inProgressTasks!.first.status}",
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ],
                          ),
                          value: _selectedOption,
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          icon: SizedBox(),
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor:
                          Colors.white, // Background color of the dropdown
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            maxLines: 5,
                              "${widget.inProgressTasks!.first.subject}",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'images/DP.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.assignedTo,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${widget.inProgressTasks!.first.assignTo!.first.userName}",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                      Text(
                        singletonClass.formatDate2(
                            widget.inProgressTasks!.first.logDuration!.first.date! , context),
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.project,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          "${widget.projectData!.logo}",
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "${widget.projectData!.name}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        child: Text(
                          "${widget.inProgressTasks!.first.description}",
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.attachment,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 200,
                        child: GestureDetector(
                          onTap: () async {
                            String url = "${widget.inProgressTasks!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Image.network(
                                        "${widget.inProgressTasks!.first.attachments}",
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (url.endsWith(".pdf") || (url.endsWith(".doc") || url.endsWith(".docx"))) {
                              final Uri uri = Uri.parse("${widget.inProgressTasks!.first.attachments}");
                              if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Unsupported file type")),
                              );
                            }
                          },
                          child: (() {
                            String url = "${widget.inProgressTasks!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              return Image.network(
                                "${widget.inProgressTasks!.first.attachments}",
                                fit: BoxFit.cover,
                              );
                            } else if (url.endsWith(".pdf")) {
                              return const Icon(Icons.picture_as_pdf,
                                  size: 50, color: Colors.red);
                            } else if (url.endsWith(".doc") || url.endsWith(".docx")) {
                              return const Icon(Icons.description,
                                  size: 50, color: Colors.blue);
                            } else {
                              return const Icon(Icons.attach_file,
                                  size: 50, color: Colors.grey);
                            }
                          })(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.comments,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.inProgressTasks != null && widget.inProgressTasks!.first.comments != null)
                        ...widget.inProgressTasks!.first.comments!.map((c) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.comments ?? "---",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${c.commentedBy ?? '---'} • ${singletonClass.formatDate2(c.commentedAt.toString(), context)}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Text(
                          "---",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ],
                if (widget.completedTask != null &&
                    widget.completedTask!.isNotEmpty &&
                    widget.completedTask!.first.status == "Completed")...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40,
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                          color: widget.completedTask!.first.status == 'Completed' ? NasColors.completed : NasColors.pending,
                        ),
                        child: DropdownButton<String?>(
                          elevation: 8,
                          items: _options!.map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  _selectedOption == null ?
                                  Text(
                                    option,
                                    style: GoogleFonts.inter(color: Colors.black),
                                  ) : Text(
                                    _selectedOption.toString(),
                                    style: GoogleFonts.inter(color: Colors.white),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value;
                            });
                            if (_selectedOption != null) {
                              final date = DateTime.now();
                              final commentBy = comment.text.trim().isEmpty
                                  ? widget.completedTask!.first.comments!.first.commentedBy
                                  : singletonClass.getJWTModel()?.userName;
                              final commentedAt= comment.text.trim().isEmpty
                                  ? widget.completedTask!.first.comments!.first.commentedAt
                                  : date;
                              final commentToSend = comment.text.trim().isEmpty
                                  ? widget.completedTask!.first.comments!.first.comments
                                  : comment.text.trim();
                              final selectOption = _selectedOption == null
                                  ? widget.completedTask!.first.status
                                  : _selectedOption.toString();
                              updateTask(
                                "Completed",
                                widget.completedTask!.first.taskId,
                                widget.completedTask!.first.id,
                                widget.completedTask!.first.projectId,
                                widget.completedTask!.first.subject,
                                widget.completedTask!.first.description,
                                widget.completedTask!.first.attachments,
                                selectOption.toString(),
                                widget.completedTask!.first.estimatedDuration,
                                widget.completedTask!.first.type,
                                widget.completedTask!.first.tag,
                                widget.completedTask!.first.assignTo,
                                widget.completedTask!.first.reportedTo!.first.manager,
                                widget.completedTask!.first.logDuration!.first.date,
                                widget.completedTask!.first.logDuration!.first.hours,
                                widget.completedTask!.first.logDuration!.first.loggedBy,
                                widget.completedTask!.first.subTask,
                                commentToSend,
                                commentBy,
                                commentedAt.toString(),);
                            }
                          },
                          hint: Row(
                            children: [
                              Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "${widget.completedTask!.first.status}",
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ],
                          ),
                          value: _selectedOption,
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          icon: SizedBox(),
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor:
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child:  Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "${widget.completedTask!.first.subject}",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                        ),
                        ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'images/DP.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.assignedTo,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                             "${widget.completedTask!.first.assignTo!.first.userName}",
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                      Text(
                        singletonClass.formatDate2(
                            widget.completedTask!.first.logDuration!.first.date! , context),
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.project,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          "${widget.projectData!.logo}",
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "${widget.projectData!.name}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        child: Text(
                          "${widget.completedTask!.first.description}",
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.attachment,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 200,
                        child: GestureDetector(
                          onTap: () async {
                            String url = "${widget.completedTask!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Image.network(
                                        "${widget.completedTask!.first.attachments}",
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.error),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (url.endsWith(".pdf") || (url.endsWith(".doc") || url.endsWith(".docx"))) {
                              final Uri uri = Uri.parse("${widget.completedTask!.first.attachments}");
                              if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Unsupported file type")),
                              );
                            }
                          },
                          child: (() {
                            String url = "${widget.completedTask!.first.attachments}".toLowerCase();
                            if (url.endsWith(".png") ||
                                url.endsWith(".jpg") ||
                                url.endsWith(".jpeg")) {
                              return Image.network(
                                "${widget.completedTask!.first.attachments}",
                                fit: BoxFit.cover,
                              );
                            } else if (url.endsWith(".pdf")) {
                              return const Icon(Icons.picture_as_pdf,
                                  size: 50, color: Colors.red);
                            } else if (url.endsWith(".doc") || url.endsWith(".docx")) {
                              return const Icon(Icons.description,
                                  size: 50, color: Colors.blue);
                            } else {
                              return const Icon(Icons.attach_file,
                                  size: 50, color: Colors.grey);
                            }
                          })(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.comments,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (widget.completedTask != null && widget.completedTask!.first.comments != null)
                        ...widget.completedTask!.first.comments!.map((c) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.comments ?? "---",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${c.commentedBy ?? '---'} • ${singletonClass.formatDate2(c.commentedAt.toString(), context)}",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Text(
                          "---",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ],

              ],
            ),
            ]
          ),
            if (isLoading)
        Loader(),
          ]
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Row(
              children: [
                Container(
                  height: 150,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EBF0),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: comment,
                      maxLength: 300,
                      maxLines: 5,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.comment,
                          hintStyle: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Image.asset(
                              'images/send.png',
                              height: 24,
                              width: 24,
                              color: NasColors.onTime,
                            ),
                            onPressed: () {
                              final date = DateTime.now();
                              Dattaa? task;
                              if (widget.toDoTasks!.isNotEmpty && widget.toDoTasks!.first.status == 'TODO') {
                                task = widget.toDoTasks!.first;
                              } else if (widget.inProgressTasks!.isNotEmpty && widget.inProgressTasks!.first.status == 'InProgress') {
                                task = widget.inProgressTasks!.first;
                              } else if (widget.completedTask!.isNotEmpty && widget.completedTask!.first.status == 'Completed') {
                                task = widget.completedTask!.first;
                              }
                              final commentToSend = comment.text.trim().isEmpty
                                  ? task!.comments!.first.comments
                                  : comment.text.trim();
                              final commentBy = comment.text.trim().isEmpty
                                  ? task!.comments!.first.commentedBy
                                  : singletonClass.getJWTModel()?.userName;
                              final commentedAt= comment.text.trim().isEmpty
                                  ? task!.comments!.first.commentedAt
                                  : date;
                              final selectOption = _selectedOption == null
                                  ? task!.status
                                  : _selectedOption.toString();
                              if (task != null) {
                                updateTask(
                                  task.status,
                                  task.taskId,
                                  task.id,
                                  task.projectId,
                                  task.subject,
                                  task.description,
                                  task.attachments,
                                  selectOption.toString(),
                                  task.estimatedDuration,
                                  task.type,
                                  task.tag,
                                  task.assignTo,
                                  task.reportedTo!.first.manager,
                                  task.logDuration!.first.date,
                                  task.logDuration!.first.hours,
                                  task.logDuration!.first.loggedBy,
                                  task.subTask,
                                  commentToSend,
                                  commentBy,
                                  commentedAt.toString(),
                                );
                              }

                            },
                          )),
                    ),
                  ),
                )
              ],
            )

      ),
    );
  }

  ///API calls
  void updateTask(
      String? taskNameFlag,
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
      List<AssignTo>? assignTo,
      String? reportedTo,
      String? date,
      String? hours,
      String? loggedBy,
      List<String>? subTask,
      String? comments,
      String? commentsBy,
      String? commentAt,
      ) async {
    // Prepare existing comments
    List<Map<String, dynamic>> existingComments = [];

    if (taskNameFlag == "TODO") {
      existingComments = List<Map<String, dynamic>>.from(
        widget.toDoTasks!.first.comments!.map((c) => {
          "comments": c.comments,
          "commentedBy": c.commentedBy,
          "commentedAt": c.commentedAt,
        }),
      );
    }

    if (taskNameFlag == "InProgress") {
      existingComments = List<Map<String, dynamic>>.from(
        widget.inProgressTasks!.first.comments!.map((c) => {
          "comments": c.comments,
          "commentedBy": c.commentedBy,
          "commentedAt": c.commentedAt,
        }),
      );
    }

    if (taskNameFlag == "Completed") {
      existingComments = List<Map<String, dynamic>>.from(
        widget.completedTask!.first.comments!.map((c) => {
          "comments": c.comments,
          "commentedBy": c.commentedBy,
          "commentedAt": c.commentedAt,
        }),
      );
    }

    if (comments != null && comments.isNotEmpty) {
      bool alreadyExists = existingComments.any((c) =>
      c["comments"].toString().trim().toLowerCase() ==
          comments.trim().toLowerCase() &&
          c["commentedBy"] == commentsBy);

      if (!alreadyExists) {
        existingComments.add({
          "comments": comments,
          "commentedBy": commentsBy,
          "commentedAt": commentAt,
        });
      }
    }

    String url = '${singletonClass.baseURL}/kanban-task/$id';

    Map<String, dynamic> data = {
      "projectId": projectId,
      "taskId": taskId,
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
      "comments": existingComments,
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const MainScreen(index: 1)));
          singletonClass.taskModelList.clear();
          singletonClass.taskAttachmentDataList.clear();
        } else {
          String errorMessage = decodedResponse['data']?['message'] ?? 'Unknown error';
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
