import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../../request_controller/company_model.dart';
import '../../singleton_class.dart';
import '../../widgets/loader.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/attachment_response_model.dart';
import '../main_screen.dart';


class ResignationRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const ResignationRequestScreen({super.key, this.selectedRequest});

  @override
  State<ResignationRequestScreen> createState() => _ResignationRequestScreenState();
}

class _ResignationRequestScreenState extends State<ResignationRequestScreen> {
  bool isLoading = false;
  SingletonClass singletonClass = SingletonClass();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _reason = TextEditingController();
  DateTime? startDate;
  PlatformFile? selectedFile;

  Widget _buildHeader(BuildContext context) {
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
              offset: const Offset(0, 6))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Text(AppLocalizations.of(context)!.applyRequests,
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Row(children: [
                  Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.event_note_rounded,
                          color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Resignation',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.75))),
                        Text('Resignation Request',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ])),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.lastWorkingDay,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NasColors.darkBlue)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: NasColors.darkBlue,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: NasColors.darkBlue,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setState(() {
                                  startDate = date;
                                });
                              }
                            },
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    startDate == null
                                        ? "DD/MM/YYYY"
                                        : DateFormat('yyyy-MM-dd').format(startDate!),
                                    style: GoogleFonts.inter(
                                        fontSize: 15, color: Colors.black87),
                                  ),
                                  const Icon(Icons.calendar_today_outlined,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(AppLocalizations.of(context)!.reason,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NasColors.darkBlue)),
                          const SizedBox(height: 6),
                          TextFormField(
                            cursorColor: Colors.grey,
                            controller: _reason,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(context)!
                                    .enterNotesValidation;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.typeYourDescription,
                              hintStyle: GoogleFonts.inter(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (widget.selectedRequest != null &&
                              widget.selectedRequest!.docRequired == true) ...[
                            TextButton(
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
                                if (result != null && result.files.single.path != null) {
                                  final PlatformFile file = result.files.single;
                                  setState(() => selectedFile = file);

                                  final results = await uploadDocuments(file);
                                  final bool success = results["success"] as bool;
                                  final String message = results["message"] as String;

                                  if (!success && context.mounted) {
                                    setState(() => selectedFile = null);
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(AppLocalizations.of(context)!.uploadFailedTitle),
                                        content: Text(message),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text(
                                              AppLocalizations.of(context)!.ok,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  if (kDebugMode) print('File selection canceled.');
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.add, color: Colors.black, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppLocalizations.of(context)!.attachDocuments,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                                  ),
                                  const SizedBox(width: 10),
                                  if (selectedFile != null)
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipOval(
                                          child: Image.file(
                                            File(selectedFile!.path!),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedFile = null),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  NasColors.darkBlue,
                                  NasColors.lightBlue
                                ]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    postRequest();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                child: Text(
                                    AppLocalizations.of(context)!.requests,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  ///API's Method
  Future<Map<String, dynamic>> uploadDocuments(PlatformFile file) async {
    try {
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }

      setState(() => isLoading = true);

      final uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        final attachmentResponse = AttachmentResponse.fromJson(decodedJson);
        singletonClass.attachmentResponseDataList.clear();
        singletonClass.attachmentResponseDataList = [attachmentResponse];
        return {"success": true, "message": ""};
      } else {
        return {"success": false, "message": "Upload failed: ${response.statusCode}\n\n$responseBody"};
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<void> postRequest() async {
    try {
      final jwtModel = singletonClass.getJWTModel();

      final String? employeeId = jwtModel?.employeeId;
      final String? empId = jwtModel?.empId;
      final String? companyId = jwtModel?.companyId;
      final String? branchId = jwtModel?.branchId;

      if (singletonClass.employeeDataList.isEmpty || singletonClass.companyDataList.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.employeeOrCompanyMissing,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final String? firstName = singletonClass.employeeDataList.first.data.first.firstName;
      final String? middleName = singletonClass.employeeDataList.first.data.first.middleName;
      final String? lastName = singletonClass.employeeDataList.first.data.first.lastName;

      final String employeeName = [firstName, middleName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

      final String? policyId = singletonClass.companyDataList.first.data?.policies?.first.policyId;

      final String? selectedRequestType = widget.selectedRequest?.requestType;

      if (startDate == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.selectDate,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final String formattedLastDate = DateFormat('yyyy-MM-dd').format(startDate!);

      final List<Map<String, dynamic>> attachments = [];
      if (selectedFile != null) {
        if (singletonClass.attachmentResponseDataList.isNotEmpty && singletonClass.attachmentResponseDataList.first.data != null) {
          attachments.add({
            "type": singletonClass.attachmentResponseDataList.first.data!
                .attachmentType,
            "url": singletonClass.attachmentResponseDataList.first.data!.url,
          });
        }
      }

      final Map<String, dynamic> data = {
        "empId": empId,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "companyId": companyId,
        "policyId": policyId,
        "branchId": branchId,
        "requestType": selectedRequestType,
        "subType": "resignationRequest",
        "requestData": [
          {
            "date": formattedLastDate,
            "reason": _reason.text
          }
        ],
        "approvers": [],
        "reason": _reason.text,
        "attachments": attachments,
      };

      if (kDebugMode) print("REQUEST JSON POST: ${jsonEncode(data)}");

      if (mounted) setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse("${singletonClass.baseURL}/request/create"),
        headers: singletonClass.getHeaders(),
        body: json.encode(data),
      );

      if (mounted) setState(() => isLoading = false);

      final decodedResponse = json.decode(response.body);
      if (kDebugMode) print("REQUEST RESPONSE: $decodedResponse");

      final int statusCode = (decodedResponse['statusCode'] ?? response.statusCode) as int;

      if (statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ?? "Request completed successfully",
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );

        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(index: 2, selectedIndex: 0 , showBanner: false)),
          );
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: decodedResponse['errorMessage'] ?? AppLocalizations.of(context)!.unexpectedError,
          autoCloseDuration: const Duration(seconds: 4),
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      if (kDebugMode) print("ERROR: $e");

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: AppLocalizations.of(context)!.somethingWentWrong,
        autoCloseDuration: const Duration(seconds: 4),
        showConfirmBtn: false,
      );
    }
  }
}
