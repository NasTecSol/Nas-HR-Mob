import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:developer';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../request_controller/search_employee_model.dart';

class CreateHrLetterScreen extends StatefulWidget {
  const CreateHrLetterScreen({super.key});

  @override
  State<CreateHrLetterScreen> createState() => _CreateHrLetterScreenState();
}

class _CreateHrLetterScreenState extends State<CreateHrLetterScreen> {
  SingletonClass singletonClass = SingletonClass();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _letterSubject = TextEditingController();
  final TextEditingController _letterBody = TextEditingController();
  bool _showSearchResult = false;
  final List<SearchedResultForLetter> _employeeSearchResults = [];
  final List<SearchedResultForLetter?> _selectedEmployees = [];
  String? templateDocUrl;
  String parsedTemplateText = '';
  bool _isLoading = false;
  bool _isTemplateGenerated = false;
  Uint8List? _generatedDocxBytes;

  @override
  void initState(){
    super.initState();
    getTemplate();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Column(
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
                  AppLocalizations.of(context)!.createLetter,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.searchEmployee,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_selectedEmployees.isNotEmpty) ...[
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedEmployees.length,
                  itemBuilder: (context, index) {
                    var employee = _selectedEmployees[index];
                    return Stack(
                      children: [
                        // Main container for the employee tile
                        Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.all(
                                Radius.circular(15)),
                            color: NasColors.lightBlue,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          width: 150,
                          // Set a fixed width for each employee tile
                          child: Row(
                            children: [
                              Container(
                                height: 30,
                                width: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "images/DP.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    employee!.employeeName ??
                                        "Unknown",
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Optional: Handle long text
                                  ),
                                  Text(
                                    employee.empId ?? "Unknown",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Small remove button on top-right
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmployees
                                    .remove(employee);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              padding:
                              const EdgeInsets.all(4.0),
                              // Adjust padding for icon size
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16, // Adjust icon size
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            Row(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    cursorColor: Colors.grey,
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                      '${AppLocalizations.of(context)!.search}...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      getSearchEmployeeData();
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    size: 25,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            if (_showSearchResult == true) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _employeeSearchResults.clear();
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.clearAll,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      )),
                ],
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _employeeSearchResults.length,
                    itemBuilder: (context, index) {
                      var employee = _employeeSearchResults[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image:
                                  AssetImage("images/DP.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.employeeName ??
                                      "Unknown",
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue),
                                ),
                                Text(
                                  employee.empId ?? "Unknown",
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedEmployees.contains(employee)) {
                                _selectedEmployees.remove(employee);
                              } else {
                                _selectedEmployees.add(employee);
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            // Space around the icon
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.subject,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    cursorColor: Colors.grey,
                    controller: _letterSubject,
                    decoration: InputDecoration(
                      hintText:
                      'Enter letter subject here...!',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "letter body",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    cursorColor: Colors.grey,
                    controller: _letterBody,
                    decoration: InputDecoration(
                      hintText:
                      'Enter letter body here...!',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await downloadAndSaveDocx(templateDocUrl!);
                if (_generatedDocxBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Document is not ready.")),
                  );
                  return;
                }

                final tempDir = await getTemporaryDirectory();
                final filePath = '${tempDir.path}/generated_hr_letter.docx';
                final file = File(filePath);
                await file.writeAsBytes(_generatedDocxBytes!);

                print("File path to open: $filePath");

                // Ensure the file exists before trying to open
                if (await file.exists()) {
                  final result = await OpenFile.open(filePath);
                  print("OpenFile result: ${result.message}");
                } else {
                  print("File does not exist: $filePath");
                }
              },
              child: const Text("Preview Letter"),
            ),


          ],
        ),
      ),
    );
  }
  //Search Call
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text.trim();
    if (employeeId.isEmpty) return;

    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResultForLetter result = SearchedResultForLetter(
        empId: employeeData.data?.first.employeeInfo?.first.empId,
        employeeName: employeeData.data?.first.firstName,
        department: employeeData.data?.first.employeeInfo!.first.depName,
        designation: employeeData.data?.first.employeeInfo!.first.designation,
      );

      print(">>>>$result");
      setState(() {
        // Remove existing entry with the same empId first
        _employeeSearchResults.removeWhere((e) => e.empId == result.empId);

        // Then add the new result
        _employeeSearchResults.add(result);

        _showSearchResult = true;
      });
      print("???$_employeeSearchResults");
    } else {
      setState(() {
        _showSearchResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.employeeNotFound)),
      );
    }
  }

  //API CALL
  Future<void> getTemplate() async {
    final response = await http.get(Uri.parse('${singletonClass.baseURL}/documents'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final templates = jsonData['data']?['data'] as List<dynamic>?;

      final defaultTemplate = templates?.firstWhere(
            (template) =>
        template is Map<String, dynamic> &&
            template['templateType']?.toString() == 'Doc_Shared_Templates' &&
            template['default'] == true,
        orElse: () => null,
      );

      if (defaultTemplate != null) {
        final fileUrl = defaultTemplate['objectDetails']?['parameters']?['documentUrl'];
        if (fileUrl != null) {
          templateDocUrl = fileUrl;
        }
      }
    }
  }

  Future<void> downloadAndSaveDocx(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/hr_letter_template.docx';
      final file = File(filePath);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        await parseDocxTemplate();
        return;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
      } else {
        log("Failed to download template file.");
      }
    } catch (e) {
      log("Error downloading/saving template: $e");
    }
  }

  Future<void> parseDocxTemplate() async {
    try {
      if (templateDocUrl == null) return;

      final uri = Uri.parse(templateDocUrl!);
      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final bytes = response.bodyBytes;
      final archive = ZipDecoder().decodeBytes(bytes);

      final documentFile = archive.files.firstWhere(
            (file) => file.name == 'word/document.xml',
        orElse: () => throw Exception("DOCX content not found"),
      );

      String xmlContent = utf8.decode(documentFile.content as List<int>);

      // Build replacement map
      final emp = _selectedEmployees.first;
      final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final replacements = {
        'currentDate': now,
        'employeeName': emp?.employeeName ?? 'N/A',
        'employeeDesignation': emp?.designation ?? 'N/A',
        'employeeDepartment': emp?.department ?? 'N/A',
        'letterSubject': _letterSubject.text,
        'letterBody': _letterBody.text,
        'senderName': singletonClass.employeeDataList.first.data!.firstName ?? 'HR Team',
        'senderDesignation': singletonClass.employeeDataList.first.data!.employeeInfo!.first.designation ?? 'Manager',
        'senderDepartment': singletonClass.employeeDataList.first.data!.employeeInfo!.first.depName ?? 'HR Department',
        'Signature': 'AN',
      };

      log('Replacements: $replacements');

      // Safely replace placeholders within <w:t> tags only
      xmlContent = xmlContent.replaceAllMapped(
        RegExp(r'(<w:t[^>]*>)(.*?)(</w:t>)', dotAll: true),
            (match) {
          String text = match.group(2)!;
          replacements.forEach((key, value) {
            text = text.replaceAll('{$key}', value);
          });
          return '${match.group(1)}$text${match.group(3)}';
        },
      );

      // Build the new archive
      final updatedArchive = Archive();
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          updatedArchive.addFile(
            ArchiveFile.noCompress(file.name, xmlContent.length, utf8.encode(xmlContent)),
          );
        } else {
          updatedArchive.addFile(file);
        }
      }

      final newDocxBytes = ZipEncoder().encode(updatedArchive);
      _generatedDocxBytes = Uint8List.fromList(newDocxBytes!);

      print("✅ Template parsed and document generated successfully.");
    } catch (e, stack) {
      print("❌ DocxTemplate parsing error: $e");
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error parsing template: ${e.toString()}")),
      );
    }
  }





}


//DUMMY MODEL
class SearchedResultForLetter {
  dynamic empId;
  dynamic designation;
  dynamic department;
  dynamic employeeName;
  dynamic severity;

  SearchedResultForLetter({
    this.empId,
    this.designation,
    this.department,
    this.employeeName,
    this.severity,
  });

  @override
  String toString() {
    return 'SearchedResultData: {empId:$empId , employeeName: $employeeName , severity:$severity}';
  }

  // Convert CashData to JSON
  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'employeeName': employeeName,
      'severity': severity,
    };
  }
}