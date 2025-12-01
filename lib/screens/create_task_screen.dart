import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:open_file/open_file.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_attachment_model.dart';
import 'package:nashr/l10n/app_localizations.dart';

import '../widgets/loader.dart';

class CreateTaskScreen extends StatefulWidget {
  final Data? projectData;

  const CreateTaskScreen({super.key, this.projectData});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _description = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  final GlobalKey<FormState> _formKey = GlobalKey();
  PlatformFile? selectedFile;
  List<ProjectMembers>? _options;
  DateTime? fromDate;
  DateTime? toDate;
  int? totalDays;
  final List<String> _typeList = [
    'BUG',
    'FEATURE',
    'IMPROVEMENT',
    'TASK',
    'EPIC',
    'STORY',
    'SUBTASK',
    'SPIKE',
    'RESEARCH',
    'TEST',
    'OTHER'
  ];
  String? _selectedType;
  ProjectMembers? _selectedOption;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _options = widget.projectData?.projectMembers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(
          children: [ Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                          ]),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.createAnIssue,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.create,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        if( fromDate == null || toDate == null) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: AppLocalizations.of(context)!
                                .enterToAndFromDate,
                            autoCloseDuration:
                            const Duration(seconds: 5),
                            showCancelBtn: false,
                            showConfirmBtn: false,
                          );
                        } else if(_selectedType == null || _selectedOption == null){
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            title: AppLocalizations.of(context)!.selectAssignee,
                            autoCloseDuration:
                            const Duration(seconds: 5),
                            showCancelBtn: false,
                            showConfirmBtn: false,
                          );
                        } else {
                          createTask();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [ Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.subject,
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
                              return AppLocalizations.of(context)!.typeTaskNameHere;
                            }
                            return null;
                          },
                          controller: _subject,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            hintText: AppLocalizations.of(context)!.typeYourSubject,
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.typeYourDescription;
                            }
                            return null;
                          },
                          controller: _description,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            hintText: AppLocalizations.of(context)!.typeYourDescription,
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
                        const SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(context)!.selectAssignee,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<ProjectMembers?>(
                            elevation: 8,
                            items: _options!.map((option) {
                              return DropdownMenuItem<ProjectMembers>(
                                value: option, // Pass the entire object as the value
                                child: Text(
                                  option.name ?? 'N/A', // Display the employee name
                                  style: const TextStyle(
                                      color: Colors.black), // Adjust text style
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                            hint:  Text( AppLocalizations.of(context)!.selectAssignee,
                              style: TextStyle(color: Colors.grey),
                            ),
                            value: _selectedOption,
                            isExpanded: true,
                            iconEnabledColor: Colors.black,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.selectType,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            elevation: 8,
                            items: _typeList.map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType =
                                    value;
                              });
                            },
                            hint:  Text(
                              AppLocalizations.of(context)!.selectType,
                              style: TextStyle(color: Colors.grey),
                            ),
                            value: _selectedType,
                            isExpanded: true,
                            iconEnabledColor: Colors.black,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(15),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.selectDuration,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    fromDate = date;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.calendar_month_outlined,
                                size: 30,
                                color: NasColors.darkBlue,
                              ),
                              label: Text(
                                fromDate == null
                                    ? AppLocalizations.of(context)!.fromDate
                                    : DateFormat('yyyy-MM-dd')
                                    .format(fromDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                  builder: (BuildContext context,
                                      Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: NasColors.lightBlue,
                                          primary: Colors.white,
                                          onPrimary: Colors.black,
                                          onSurface: Colors.white,
                                        ),
                                        textButtonTheme:
                                        TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (date != null) {
                                  setState(() {
                                    toDate = date;
                                    if (fromDate != null) {
                                      totalDays = toDate!
                                          .difference(fromDate!)
                                          .inDays +
                                          1; // Calculate totalDays
                                    } else {
                                      totalDays =
                                      null; // Handle case where fromDate is null
                                    }
                                  });
                                }
                              },
                              icon:  Icon(
                                Icons.calendar_month_outlined,
                                size: 30,
                                color: NasColors.darkBlue,
                              ),
                              label: Text(
                                toDate == null
                                    ? AppLocalizations.of(context)!.toDate
                                    : DateFormat('yyyy-MM-dd')
                                    .format(toDate!),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!.days,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          totalDays == null ? "0" : "$totalDays",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              if (kDebugMode) {
                                print('Selected file: ${file.name}');
                              }
                              _showConfirmationDialog(
                                  file);
                            } else {
                              if (kDebugMode) {
                                print('File selection canceled.');
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 30,
                                color: NasColors.darkBlue,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context)!.addAttachments,
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
                                  children: [GestureDetector(
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
                      ],
                    ),
                  ),
                    ]
                ),
              )
            ],
          ),
            if (isLoading)
             Loader()
          ]
        ),
      ),
    );
  }

  //API CALLS
  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(AppLocalizations.of(context)!.confirmUpload),
          content:
              Text('${AppLocalizations.of(context)!.areYouSureYouWantToUploadThisFile}: ${file.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel,style: GoogleFonts.inter(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await uploadProfile();
              },
              child:  Text(AppLocalizations.of(context)!.yes,style: GoogleFonts.inter(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadProfile() async {
    if (selectedFile == null) {
      print("No file selected.");
      return;
    }

    if (selectedFile!.bytes == null) {
      print("Loading bytes for the selected file...");
      try {
        final file = File(selectedFile!.path!);
        final fileBytes = await file.readAsBytes();
        if (fileBytes.isEmpty) {
          print("No bytes available for the selected file.");
          return;
        }
        _uploadFileWithBytes(fileBytes);
      } catch (e) {
        print('Error reading file: $e');
      }
    } else {
      _uploadFileWithBytes(selectedFile!.bytes!);
    }
  }

  void _uploadFileWithBytes(Uint8List fileBytes) async {
    var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', uri);

      // Safely get the mime type (fall back to 'application/octet-stream' if mime type is not found)
      final mimeType = lookupMimeType(selectedFile!.path ?? '') ??
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
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        TaskAttachmentModel attachmentResponse =
            TaskAttachmentModel.fromJson(decodedJson);
        singletonClass.taskAttachmentDataList = [attachmentResponse];
        setState(() {});
      } else {
        print('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  String generateTaskId(String projectKey, int number) {
    return "$projectKey-${number.toString().padLeft(2, '0')}";
  }

  void createTask() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String url = '${singletonClass.baseURL}/kanban-task/create';
    Map<String, dynamic> data = {
      "projectId": widget.projectData!.id,
      "taskId": generateTaskId("${widget.projectData!.projectKey}", 1),
      "subject": _subject.text,
      "description": _description.text,
      "attachments": singletonClass.taskAttachmentDataList.isNotEmpty
          ? singletonClass.taskAttachmentDataList.first.data!.url
          : "",
      "status": "TODO",
      "estimatedDuration": totalDays.toString(),
      "type": _selectedType,
      "tag": "urgent",
      "assignTo":  [
        {
          "userId": _selectedOption!.empId,
          "userName": _selectedOption!.name,
        }
      ],
      "reportedTo": {"manager": employeeId},
      "logDuration": [
        {
          "date": fromDate?.toIso8601String(),
          "hours": totalDays.toString(),
          "description": _description.text,
          "loggedBy": singletonClass.getJWTModel()?.userName,
        }
      ],
      "subTask": [""],
      "comments": []
    };
    String jsonData = jsonEncode(data);
    log(jsonData);
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );
      print(response.body);
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

          Navigator.push(context, MaterialPageRoute(builder: (context)=>const MainScreen(index: 1,selectedIndex: 0,)));
          singletonClass.taskModelList.clear();
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
}
