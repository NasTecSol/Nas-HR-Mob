import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/projects_data_model.dart';
import '../request_controller/task_attachment_model.dart';
import 'package:nashr/l10n/app_localizations.dart';

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
        child: Column(
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
                  "Create an issue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
                TextButton(
                  child: Text("Create",
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
                          title: "Select Assignee and type",
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
                        const SnackBar(
                          content: Text("Please fill all fields"),
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
                        "Subject",
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
                            return "Please Enter subject";
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
                          hintText: "Type subject here!",
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
                        "Description",
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
                            return "Please Enter your description";
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
                          hintText: "Type your description here!",
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
                        "Select Assignee",
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
                              _selectedOption =
                                  value; // Update the selected option with the whole object
                            });
                          },
                          hint: const Text(
                            'Select Assignee', // Hint text when no option is selected
                            style: TextStyle(color: Colors.grey),
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
                      const SizedBox(height: 10),
                      Text(
                        "Select Type",
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
                          items: _typeList
                              ?.map((type) => DropdownMenuItem<String>(
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
                                  value; // Update the selected option with the whole object
                            });
                          },
                          hint: const Text(
                            'Select Type', // Hint text when no option is selected
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: _selectedType,
                          // Display the current selected value
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          // Icon color
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          borderRadius: BorderRadius.circular(15),
                          dropdownColor: Colors.white, // Background color of the dropdown
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Select Duration",
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
                          TextButton(
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
                            child: Text(
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
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: NasColors.darkBlue,
                          ),
                          TextButton(
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
                            child: Text(
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
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 30,
                            color: NasColors.darkBlue,
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
                            type: FileType.any, // Ensures only image files are allowed
                          );

                          if (result != null && result.files.single.path != null) {
                            PlatformFile file = result.files.single;

                            // Save the file data for sending in the API call
                            setState(() {
                              selectedFile = file;
                            });

                            print('Selected file: ${file.name}');

                            // Show confirmation dialog before uploading
                            _showConfirmationDialog(
                                file); // Upload the selected file to the API
                          } else {
                            // User canceled the file picker
                            print('File selection canceled.');
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
                              "Add Attachments",
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (selectedFile != null &&
                                selectedFile!.path!.isNotEmpty &&
                                selectedFile!.path!.isNotEmpty == true) ...[
                              Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                    File(selectedFile!.path!),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )),
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
      ),
    );
  }

  //API CALLS
  void _showConfirmationDialog(PlatformFile file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Upload'),
          content:
              Text('Are you sure you want to upload this file: ${file.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog and do nothing
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Trigger the API call to upload the file
                await uploadProfile();
              },
              child: const Text('Yes'),
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
      isLoading = true; // Corrected to set isLoading to true
    });

    try {
      var request = http.MultipartRequest('POST', uri);

      // Safely get the mime type (fall back to 'application/octet-stream' if mime type is not found)
      final mimeType = lookupMimeType(selectedFile!.path ?? '') ??
          'application/octet-stream';

      // Add the file to the request as bytes
      request.files.add(http.MultipartFile(
        'file', // Field name in the API
        http.ByteStream.fromBytes(fileBytes), // Convert bytes to ByteStream
        fileBytes.length, // File size (in bytes)
        filename: selectedFile!.name, // Filename
        contentType: MediaType.parse(mimeType), // MIME type
      ));

      // Add additional fields to the request if necessary
      request.fields['attachmentName'] =
          selectedFile!.name; // Safe unwrapping of nullable name
      request.fields['attachmentType'] = selectedFile!.extension ??
          ''; // Safe unwrapping of nullable extension

      // Send the request
      var response = await request.send();

      final responseBody = await response.stream.bytesToString();

      // Log the response body for debugging
      print("API Response Body: $responseBody");
      setState(() {
        isLoading = false; // Corrected to set isLoading to true
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

  void createTask() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    String url = '${singletonClass.baseURL}/kanban-task/create';
    Map<String, dynamic> data = {
      "projectId": widget.projectData!.id,
      "taskId": "task001",
      "subject": _subject.text,
      "description": _description.text,
      "attachments": singletonClass.taskAttachmentDataList.isNotEmpty
          ? singletonClass.taskAttachmentDataList.first.data!.url
          : "",
      "status": "TODO",
      "estimatedDuration": totalDays.toString(),
      "type": _selectedType,
      "tag": "urgent",
      "assignTo": [_selectedOption!.empId],
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
      "comments": [
        {
          "comments": "",
          "commentedBy": "",
          "commentedAt": ""
        }
      ]
    };
    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    // print(data);
    log(jsonData);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      print(response.body);
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

          Navigator.push(context, MaterialPageRoute(builder: (context)=>const MainScreen()));
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
