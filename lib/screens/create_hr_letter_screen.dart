import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml.dart' as xml;
import '../request_controller/search_employee_model.dart';
import '../widgets/loader.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../request_controller/attachment_response_model.dart';

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
  Uint8List? _generatedDocxBytes;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    getTemplate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: Stack(
              children: [
            ListView(
              padding: EdgeInsets.zero,
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
                                      const BorderRadius.all(Radius.circular(15)),
                                  color: NasColors.lightBlue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.3),
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
                                          image: AssetImage("images/DP.png"),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          employee!.employeeName ?? "Unknown",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Optional: Handle long text
                                        ),
                                        Text(
                                          employee.empId ?? "Unknown",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedEmployees.remove(employee);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
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
                          color: Colors.transparent,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextFormField(
                          cursorColor: Colors.grey,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '${AppLocalizations.of(context)!.search}...',
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
                                _showSearchResult = false;
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
                                      image: AssetImage("images/DP.png"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employee.employeeName ?? "Unknown",
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
                            trailing: (_selectedEmployees.contains(employee) && _employeeSearchResults.contains(employee)) ? GestureDetector(
                              onTap: () {
                                setState((){
                                  if (_selectedEmployees.contains(employee)) {
                                    _selectedEmployees.remove(employee);
                                  }
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                            ) : GestureDetector(
                              onTap: () {
                                setState((){
                                  _selectedEmployees.add(employee);
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
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterLetterSubject;
                      }
                      return null;
                    },
                    cursorColor: Colors.grey,
                    controller: _letterSubject,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterLetterSubjectHere,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.letterBody,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterLetterBody;
                      }
                      return null;
                    },
                    cursorColor: Colors.grey,
                    controller: _letterBody,
                    maxLength: 300,
                    maxLines: 5,
                    onChanged: (text) {
                      setState(() {
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterLetterBodyHere,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NasColors.lightBlue, // background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        // rounded corners
                        side: BorderSide(
                            color: Colors.transparent,
                            width: 2), // border color and width
                      ),
                    ),
                    onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        if(_selectedEmployees.isNotEmpty){
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
                          print(templateDocUrl);

                          // Ensure the file exists before trying to open
                          if (await file.exists()) {
                            final result = await OpenFile.open(filePath);
                            print("OpenFile result: ${result.message}");
                          } else {
                            print("File does not exist: $filePath");
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.selectAssignee),
                              duration: Duration(seconds: 4),
                            ),
                          );
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
                    child: Text(
                      AppLocalizations.of(context)!.previewLetter,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),]
            ),
                if(_isLoading == true)...[
                  Loader()
                ]
          ]),
        ),
      ),
    );
  }

  /// Call for search
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text.trim().toUpperCase();
    if (employeeId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });
    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/employee/getDataByEMPId/$employeeId');

    var response = await client.get(uri,headers: singletonClass.getHeaders());
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      // Create a SearchedResult instance
      SearchedResultForLetter result = SearchedResultForLetter(
        empId: employeeData.data?.first.employeeInfo!.first.empId,
        employeeId: employeeData.data?.first.id,
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

  ///API CALL
  Future<void> getTemplate() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get(Uri.parse('${singletonClass.baseURL}/documents'),headers: singletonClass.getHeaders());
    log(response.body);
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final templates = jsonData['data']?['data'] as List<dynamic>?;
      final locale = WidgetsBinding.instance.window.locale.languageCode;
      if (locale == "ar"){
        final defaultTemplate = templates?.firstWhere(
              (template) =>
          template is Map<String, dynamic> &&
              template['templateType']?.toString() == 'Doc_Shared_Template' &&
              template['default'] == true && template['lang'] == 'ar',
          orElse: () => null,
        );
        if (defaultTemplate != null) {
          final fileUrl =
          defaultTemplate['objectDetails']?['parameters']?['documentUrl'];
          if (fileUrl != null) {
            templateDocUrl = fileUrl;
          }
        }
      } else {
        final defaultTemplate = templates?.firstWhere(
              (template) =>
          template is Map<String, dynamic> &&
              template['templateType']?.toString() == 'Doc_Shared_Template' &&
              template['default'] == true && template['lang'] == 'en',
          orElse: () => null,
        );
        if (defaultTemplate != null) {
          final fileUrl =
          defaultTemplate['objectDetails']?['parameters']?['documentUrl'];
          if (fileUrl != null) {
            templateDocUrl = fileUrl;
          }
        }
      }
    }
  }

  Future<void> downloadAndSaveDocx(String url) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/hr_letter_template.docx';
      final file = File(filePath);

      if (await file.exists()) {
        await parseDocxTemplate();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _isLoading = false;
        });
      } else {
        log("Failed to download template file.");
      }
    } catch (e) {
      log("Error downloading/saving template: $e");
    }
  }

  Future<Map<String, dynamic>> uploadFileToS3FromPath(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return {"success": false, "message": "File not found at: $filePath"};
      }

      final fileBytes = await file.readAsBytes();
      final fileName = file.uri.pathSegments.last;
      final fileExtension = fileName.split('.').last;

      setState(() => _isLoading = true);

      final uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

      request.headers.addAll(singletonClass.getHeaders());

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      request.fields['attachmentName'] = fileName;
      request.fields['attachmentType'] = fileExtension;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) setState(() => _isLoading = false);

      log("HR S3 Response ${responseBody}");
      if (response.statusCode == 200) {
        singletonClass.attachmentResponseDataList.clear();
        final decodedJson = jsonDecode(responseBody);
        final attachmentResponse = AttachmentResponse.fromJson(decodedJson);

        singletonClass.attachmentResponseDataList
          ..clear()
          ..add(attachmentResponse);
        uploadHRLetter();

        return {"success": true, "message": "Upload Success"};
      } else {
        return {
          "success": false,
          "message": "Upload failed: ${response.statusCode}\n$responseBody"
        };
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<void> parseDocxTemplate() async {
    try {
      if (templateDocUrl == null) return;

      final uri = Uri.parse(templateDocUrl!);
      final response = await http.get(uri);
      if (response.statusCode != 200) return;

      final bytes = response.bodyBytes;
      final originalArchive = ZipDecoder().decodeBytes(bytes);

      // Find document.xml inside the archive
      final documentFile = originalArchive.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => throw Exception("DOCX content not found"),
      );

      // Parse the document.xml file
      String xmlContent = utf8.decode(documentFile.content!);
      final documentXml = xml.XmlDocument.parse(xmlContent);

      // Fetch employee and sender data
      final emp = _selectedEmployees.first;
      final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final senderInfo =
          singletonClass.employeeDataList.first.data!.employeeInfo!.first;

      final replacements = {
        'currentDate': now,
        'employeeName': emp?.employeeName ?? 'N/A',
        'employeeDesignation': emp?.designation ?? 'N/A',
        'employeeDepartment': emp?.department ?? 'N/A',
        'letterSubject': _letterSubject.text,
        'senderName':
            singletonClass.employeeDataList.first.data!.userName ?? 'HR Team',
        'senderDepartment': senderInfo.depName ?? 'HR Department',
      };

      // --- Replace placeholders across paragraphs ---
      for (final node in documentXml.findAllElements('w:t')) {
        for (var entry in replacements.entries) {
          String text = node.innerText;
          if (text.contains('{${entry.key}}')) {
            text = text.replaceAll('{${entry.key}}', entry.value);
            node.innerText = text;
          }
        }
      }
      for (final paragraph in documentXml.findAllElements('w:p')) {
        final texts = paragraph.findAllElements('w:t');
        if (texts.isEmpty) continue;
        String fullText = texts.map((node) => node.innerText).join('');
        if (fullText.contains('{senderDesignation}')) {
          fullText = fullText.replaceAll(
              '{senderDesignation}', senderInfo.designation);
          for (final node in texts) {
            node.innerText = '';
          }
          texts.first.innerText = fullText;
        }
      }
      for (final paragraph in documentXml.findAllElements('w:p')) {
        final texts = paragraph.findAllElements('w:t');
        if (texts.isEmpty) continue;
        String fullText = texts.map((node) => node.innerText).join();
        if (fullText.contains('{letterBody}')) {
          fullText = fullText.replaceAll('{letterBody}', _letterBody.text);
          for (final node in texts) {
            node.innerText = '';
          }
          texts.first.innerText = fullText;
        }
      }

      // --- Handle Signature Insertion ---
      final signatureUrl = senderInfo.empSignature;
      if (signatureUrl != null && signatureUrl.isNotEmpty) {
        final imageResponse = await http.get(Uri.parse(signatureUrl));

        if (imageResponse.statusCode == 200) {
          final imageBytes = imageResponse.bodyBytes;

          if (imageBytes.isNotEmpty) {
            const imageFileName = 'signature.png';
            const mediaPath = 'word/media/$imageFileName';
            originalArchive
                .addFile(ArchiveFile(mediaPath, imageBytes.length, imageBytes));
            final relationshipsEntry = originalArchive.files.firstWhere(
              (file) => file.name == 'word/_rels/document.xml.rels',
            );
            final relationshipsXml =
                xml.XmlDocument.parse(utf8.decode(relationshipsEntry.content));
            const imageRelId = 'rId123';
            relationshipsXml.rootElement.children.add(
              xml.XmlElement(
                xml.XmlName('Relationship'),
                [
                  xml.XmlAttribute(xml.XmlName('Id'), imageRelId),
                  xml.XmlAttribute(xml.XmlName('Type'),
                      'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image'),
                  xml.XmlAttribute(
                      xml.XmlName('Target'), 'media/$imageFileName'),
                ],
              ),
            );
            originalArchive.addFile(ArchiveFile(
                'word/_rels/document.xml.rels',
                relationshipsXml.toXmlString(pretty: true).length,
                utf8.encode(relationshipsXml.toXmlString(pretty: true))));
            for (final paragraph in documentXml.findAllElements('w:p')) {
              final texts = paragraph.findAllElements('w:t');
              if (texts.isEmpty) continue;
              String fullText = texts.map((node) => node.innerText).join();
              if (fullText.contains('{Signature}')) {
                for (final node in texts) {
                  node.innerText = '';
                }
                final imageXml = '''
<w:r>
  <w:drawing>
    <wp:inline>
      <wp:extent cx="1900000" cy="600000"/>
      <wp:docPr id="1" name="Picture 1"/>
      <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
        <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:nvPicPr>
              <pic:cNvPr id="0" name="Signature"/>
              <pic:cNvPicPr/>
            </pic:nvPicPr>
            <pic:blipFill>
              <a:blip r:embed="$imageRelId" cstate="none"/>
              <a:stretch>
                <a:fillRect/>
              </a:stretch>
            </pic:blipFill>
            <pic:spPr>
              <a:xfrm>
                <a:off x="0" y="0"/>
                <a:ext cx="1900000" cy="600000"/>
              </a:xfrm>
              <a:prstGeom prst="rect">
                <a:avLst/>
              </a:prstGeom>
            </pic:spPr>
          </pic:pic>
        </a:graphicData>
      </a:graphic>
    </wp:inline>
  </w:drawing>
</w:r>
''';

                final newDrawingNode =
                    xml.XmlDocument.parse(imageXml).rootElement;
                paragraph.children.add(newDrawingNode.copy());
                if (kDebugMode) {
                  print('Signature image URL: $signatureUrl');
                }
              }
            }
            if (mounted) {
              setState(() {});
            }
          }
        } else {
          if (kDebugMode) {
            print("❌ Failed to fetch signature image from: $signatureUrl");
          }
        }
      }

      // --- Save updated document ---
      final updatedXml = utf8.encode(documentXml.toXmlString());
      final updatedArchive = Archive();
      for (final file in originalArchive) {
        if (file.name == 'word/document.xml') {
          updatedArchive.addFile(ArchiveFile.noCompress(
              'word/document.xml', updatedXml.length, updatedXml));
        } else {
          updatedArchive.addFile(file);
        }
      }

      // Rebuild the final DOCX file bytes
      final newDocxBytes = ZipEncoder().encode(updatedArchive);
      _generatedDocxBytes = Uint8List.fromList(newDocxBytes!);
      if (_generatedDocxBytes == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/generated_hr_letter.docx';

      final file = File(filePath);
      await file.writeAsBytes(_generatedDocxBytes!);

      print("📄 Saved Generated DOCX at: $filePath");

      // Upload using your existing method
      final result = await uploadFileToS3FromPath(filePath);

      print("📤 Upload Result: $result");


      if (kDebugMode) {
        print("✅ Template parsed and document generated successfully.");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Error parsing DOCX: $e");
        print(stack);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error parsing template: ${e.toString()}")),
        );
      }
    }
  }

  ///POST CALL FOR DOCUMENT
  Future<void> uploadHRLetter() async {
    String? employeeID = singletonClass.getJWTModel()?.employeeId;
    String? companyID = singletonClass.getJWTModel()?.companyId;
    List<String> employees = _selectedEmployees
        .map((employee) => employee!.employeeId.toString())
        .toList();
    Map data = {
    "templateType": "Doc_editor_shared",
    "objectDetails": {
    "Type": "shared",
    "objectName": _letterSubject.text,
    "objectIcon": "edit",
    "parameters": {
         "documentUrl": singletonClass.attachmentResponseDataList.first.data!.url,
         "employees": employees
     },
      "createdBy": employeeID,
      },
    };
    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/documents/create/$companyID/documents/$employeeID');
    log("$uri");
    log(body);
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      print("POST CALL ${response.body}");
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else if (response.statusCode == 405 || response.statusCode == 502) {
        setState(() {
          _isLoading = false;
        });
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          text: AppLocalizations.of(context)!.tryAgain,
          type: QuickAlertType.error,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          text: AppLocalizations.of(context)!.tryAgain,
          type: QuickAlertType.error,
        );
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: AppLocalizations.of(context)!.internalServerError,
        text: AppLocalizations.of(context)!.tryAgain,
        type: QuickAlertType.error,
      );
    }
  }
}

//DUMMY MODEL
class SearchedResultForLetter {
  dynamic empId;
  dynamic employeeId;
  dynamic designation;
  dynamic department;
  dynamic employeeName;
  dynamic severity;

  SearchedResultForLetter({
    this.empId,
    this.employeeId,
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
      'employeeId': employeeId,
      'designation': designation,
      'department': department,
      'employeeName': employeeName,
      'severity': severity,
    };
  }
}
