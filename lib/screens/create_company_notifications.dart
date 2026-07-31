import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/requests/request_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../request_controller/attachment_response_model.dart';
import '../request_controller/company_details_document_notification_model.dart';
import '../request_controller/search_employee_model.dart';
import '../widgets/loader.dart';

class CreateCompanyNotifications extends StatefulWidget {
  const CreateCompanyNotifications({super.key});

  @override
  State<CreateCompanyNotifications> createState() =>
      _CreateCompanyNotificationsState();
}

class _CreateCompanyNotificationsState
    extends State<CreateCompanyNotifications> {
  String? documentType;
  String? selectedCompanyID;
  String? selectedAssetID;
  String? selectedCompanyName;
  String? selectedAssetName;
  String? selectedBranchName;
  String? selectedBranchID;
  final documentName = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  PlatformFile? selectedFile;
  final expiryDateController = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  final List<SearchedResult> _employeeSearchResults = [];
  final List<SearchedResult?> _selectedEmployees = [];
  bool _showSearchResult = false;
  bool isLoadingBranches = false;
  bool isAssetLoading = false;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final assets = singletonClass.companyDetailDocumentNotificationDataList
            .isNotEmpty
        ? singletonClass.companyDetailDocumentNotificationDataList.first.data ?? []
        : [];

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              /// Curved Header (NO icon in header text)
              _buildHeader(context, local),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Document Type Dropdown
                        _buildFieldLabel(
                          "${local.documents} ${local.type}",
                          icon: Icons.description_rounded,
                        ),
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          value: documentType,
                          items: [
                            "Company Documents",
                            "Employee Documents",
                            "Assets Documents"
                          ]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => documentType = val);
                          },
                          decoration: _buildInputDecoration(
                            hintText:
                                "${local.select} ${local.documents} ${local.type}",
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Employee Documents Selection
                        if (documentType == "Employee Documents") ...[
                          if (_selectedEmployees.isNotEmpty) ...[
                            SizedBox(
                              height: 64,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedEmployees.length,
                                itemBuilder: (context, index) {
                                  var employee = _selectedEmployees[index];
                                  return Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            right: 8, top: 4, bottom: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          color: NasColors.darkBlue.withOpacity(0.08),
                                          border: Border.all(
                                              color: NasColors.darkBlue.withOpacity(0.2)),
                                        ),
                                        width: 160,
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 32,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                color: NasColors.darkBlue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    employee!.employeeName ??
                                                        "Unknown",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    employee.empId ?? "Unknown",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 4,
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
                                            padding: const EdgeInsets.all(3.0),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          _buildFieldLabel(local.searchEmployee,
                              icon: Icons.search_rounded),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _searchController,
                                  decoration: _buildInputDecoration(
                                    hintText: "${local.search}...",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    getSearchEmployeeData();
                                  });
                                },
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: NasColors.darkBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
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
                                      _showSearchResult = false;
                                    });
                                  },
                                  child: Text(
                                    local.clearAll,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListView.builder(
                                itemCount: _employeeSearchResults.length,
                                itemBuilder: (context, index) {
                                  var employee = _employeeSearchResults[index];
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 38,
                                          width: 38,
                                          decoration: BoxDecoration(
                                            color: NasColors.darkBlue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: NasColors.darkBlue,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              employee.employeeName ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue),
                                            ),
                                            Text(
                                              employee.empId ?? "Unknown",
                                              style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade600),
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
                                        padding: const EdgeInsets.all(6.0),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],

                        /// Company Documents Selection
                        if (documentType == "Company Documents") ...[
                          _buildFieldLabel(local.selectCompany,
                              icon: Icons.domain_rounded),
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration(
                              hintText: selectedCompanyName?.isNotEmpty == true
                                  ? selectedCompanyName!
                                  : local.select,
                            ),
                            value: (() {
                              final uiModules = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data!
                                  .uiSettings!
                                  .uiModules!;

                              final dashboardModule = uiModules.firstWhere(
                                (e) =>
                                    (e.title == "Dashboard" ||
                                        e.name == "Dashboard") &&
                                    e.hidden == false,
                              );

                              final companies =
                                  dashboardModule.accessLevel?.companies ?? [];

                              return companies.any(
                                      (c) => c.companyId == selectedCompanyID)
                                  ? selectedCompanyID
                                  : null;
                            })(),
                            items: (() {
                              final uiModules = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data!
                                  .uiSettings!
                                  .uiModules!;

                              final dashboardModule = uiModules.firstWhere(
                                (e) =>
                                    (e.title == "Dashboard" ||
                                        e.name == "Dashboard") &&
                                    e.hidden == false,
                              );

                              final companiesMap = {
                                for (var c
                                    in dashboardModule.accessLevel?.companies ??
                                        [])
                                  c.companyId: c
                              };

                              return companiesMap.values.map((company) {
                                return DropdownMenuItem<String>(
                                  value: company.companyId,
                                  child: Text(company.companyName ?? '---'),
                                );
                              }).toList();
                            })(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                selectedCompanyID = value;
                                selectedBranchID = null;
                                selectedBranchName = null;

                                final uiModules = singletonClass
                                    .roleAndAccessModelDataList
                                    .first
                                    .data!
                                    .uiSettings!
                                    .uiModules!;

                                final dashboardModule = uiModules.firstWhere(
                                  (e) =>
                                      (e.title == "Dashboard" ||
                                          e.name == "Dashboard") &&
                                      e.hidden == false,
                                );

                                final companies =
                                    dashboardModule.accessLevel?.companies ?? [];

                                final selectedCompany = companies
                                    .firstWhere((c) => c.companyId == value);

                                selectedCompanyName =
                                    selectedCompany.companyName ?? '';
                                singletonClass.availableBranches =
                                    selectedCompany.branches ?? [];
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel(local.selectBranch,
                              icon: Icons.location_city_rounded),
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration(
                              hintText: isLoadingBranches
                                  ? local.loading
                                  : (selectedBranchName == null ||
                                          selectedBranchName!.isEmpty)
                                      ? local.selectBranch
                                      : selectedBranchName!,
                            ),
                            value: singletonClass.availableBranches
                                    .any((b) => b.branchId == selectedBranchID)
                                ? selectedBranchID
                                : null,
                            items: {
                              for (var b in singletonClass.availableBranches)
                                b.branchId: b
                            }.values.map((branch) {
                              return DropdownMenuItem<String>(
                                value: branch.branchId,
                                child: Text(branch.branchName ?? '---'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                selectedBranchID = value;
                                final selectedBranch =
                                    singletonClass.availableBranches.firstWhere(
                                  (b) => b.branchId == value,
                                );
                                selectedBranchName =
                                    selectedBranch.branchName ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        /// Assets Documents Selection
                        if (documentType == "Assets Documents") ...[
                          _buildFieldLabel(local.selectCompany,
                              icon: Icons.domain_rounded),
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration(
                              hintText: selectedCompanyName?.isNotEmpty == true
                                  ? selectedCompanyName!
                                  : local.select,
                            ),
                            value: (() {
                              final uiModules = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data!
                                  .uiSettings!
                                  .uiModules!;

                              final dashboardModule = uiModules.firstWhere(
                                (e) =>
                                    (e.title == "Dashboard" ||
                                        e.name == "Dashboard") &&
                                    e.hidden == false,
                              );

                              final companies =
                                  dashboardModule.accessLevel?.companies ?? [];

                              return companies.any(
                                      (c) => c.companyId == selectedCompanyID)
                                  ? selectedCompanyID
                                  : null;
                            })(),
                            items: (() {
                              final uiModules = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data!
                                  .uiSettings!
                                  .uiModules!;

                              final dashboardModule = uiModules.firstWhere(
                                (e) =>
                                    (e.title == "Dashboard" ||
                                        e.name == "Dashboard") &&
                                    e.hidden == false,
                              );
                              final companiesMap = {
                                for (var c
                                    in dashboardModule.accessLevel?.companies ??
                                        [])
                                  c.companyId: c
                              };

                              return companiesMap.values.map((company) {
                                return DropdownMenuItem<String>(
                                  value: company.companyId,
                                  child: Text(company.companyName ?? '---'),
                                );
                              }).toList();
                            })(),
                            onChanged: (value) async {
                              if (value == null) return;
                              setState(() {
                                selectedCompanyID = value;
                                selectedBranchID = null;
                                selectedBranchName = null;
                                selectedAssetID = null;
                                selectedAssetName = null;
                                isAssetLoading = true;
                              });

                              final uiModules = singletonClass
                                  .roleAndAccessModelDataList
                                  .first
                                  .data!
                                  .uiSettings!
                                  .uiModules!;

                              final dashboardModule = uiModules.firstWhere(
                                (e) =>
                                    (e.title == "Dashboard" ||
                                        e.name == "Dashboard") &&
                                    e.hidden == false,
                              );

                              final selectedCompany = dashboardModule
                                  .accessLevel!.companies!
                                  .firstWhere((c) => c.companyId == value);

                              singletonClass.availableBranches =
                                  selectedCompany.branches ?? [];

                              await getCompanyData();

                              setState(() {
                                isAssetLoading = false;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildFieldLabel("${local.select} ${local.assets}",
                              icon: Icons.devices_rounded),
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: _buildInputDecoration(
                              hintText: isAssetLoading
                                  ? local.loading
                                  : local.select,
                            ),
                            value: selectedAssetID,
                            items: assets.map((asset) {
                              return DropdownMenuItem<String>(
                                value: asset.id,
                                child: Text(
                                  "${asset.objectDetails?.objectName ?? ''}  ${asset.objectDetails?.parameters?['رقم اللوحة'] ?? '---'}",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (isAssetLoading || assets.isEmpty)
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() {
                                      selectedAssetID = value;
                                      selectedAssetName = assets
                                              .firstWhere((a) => a.id == value)
                                              .objectDetails
                                              ?.objectName ??
                                          '';
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                        ],

                        /// Document Name
                        _buildFieldLabel(local.documentName,
                            icon: Icons.text_snippet_rounded),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: documentName,
                          decoration: _buildInputDecoration(
                            hintText: local.documentName,
                          ),
                        ),
                        const SizedBox(height: 16),

                        /// Expiry Date
                        _buildFieldLabel(local.expiryDate,
                            icon: Icons.calendar_month_rounded),
                        TextFormField(
                          controller: expiryDateController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hintText: local.selectDate,
                            suffixIcon: Icon(Icons.calendar_month_rounded,
                                color: NasColors.darkBlue),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.tryParse(expiryDateController.text) ??
                                      DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
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
                            if (picked != null) {
                              expiryDateController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            }
                          },
                        ),
                        const SizedBox(height: 18),

                        /// Attach Document Section
                        _buildFieldLabel(local.attachDocuments,
                            isRequired: false, icon: Icons.attach_file_rounded),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NasColors.darkBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform
                                    .pickFiles(type: FileType.any);
                                if (result != null &&
                                    result.files.single.path != null) {
                                  final PlatformFile file = result.files.single;
                                  setState(() => selectedFile = file);

                                  final results = await uploadDocuments(file);
                                  final bool success =
                                      results["success"] as bool;
                                  final String message =
                                      results["message"] as String;

                                  if (!success && context.mounted) {
                                    setState(() => selectedFile = null);
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text(local.uploadFailedTitle),
                                        content: Text(message),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: Text(
                                              local.ok,
                                              style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
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
                              icon: const Icon(Icons.cloud_upload_rounded,
                                  size: 18),
                              label: Text(local.attachDocuments),
                            ),
                            const SizedBox(width: 12),
                            if (selectedFile != null)
                              Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topRight,
                                children: [
                                  ClipOval(
                                    child: Image.file(
                                      File(selectedFile!.path!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 50,
                                        height: 50,
                                        color: NasColors.darkBlue.withOpacity(0.1),
                                        child: Icon(Icons.insert_drive_file_rounded,
                                            color: NasColors.darkBlue),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => selectedFile = null),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close_rounded,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom Action Button
              _buildBottomNavigation(context, local),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  // ── Header (Gradient with Back button, NO decorative logo icon) ──────────
  Widget _buildHeader(BuildContext context, AppLocalizations local) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 20,
      ),
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
            color: NasColors.darkBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "${local.create} ${local.notifications}",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Label Helper ────────────────────────────────────────────────
  Widget _buildFieldLabel(String labelText, {bool isRequired = true, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NasColors.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: NasColors.darkBlue),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: labelText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: " *",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Decoration Helper ───────────────────────────────────────────
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────
  Widget _buildBottomNavigation(BuildContext context, AppLocalizations local) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                createDocument();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NasColors.darkBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                local.create,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// API Methods
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

      final mimeType =
          lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
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
        return {
          "success": false,
          "message": "Upload failed: ${response.statusCode}\n\n$responseBody"
        };
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// Company data
  Future<CompanyDetailsDocumentNotificationModel?> getCompanyData() async {
    String? companyId =
        (selectedCompanyID != null && selectedCompanyID!.isNotEmpty)
            ? selectedCompanyID
            : singletonClass.getJWTModel()?.companyId;

    var client = http.Client();
    var uri = Uri.parse(
        '${singletonClass.baseURL}/company/getCompanyAssets/$companyId');

    setState(() {
      isLoading = true;
    });
    try {
      var response =
          await client.get(uri, headers: singletonClass.getHeaders());
      log("📥 Company Response: ${response.statusCode} || ${response.body}");

      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var companyData =
            CompanyDetailsDocumentNotificationModel.fromJson(responseBody);
        singletonClass.companyDetailDocumentNotificationDataList
            .addAll([companyData]);
        return companyData;
      } else {
        log("❌ Failed to fetch company data. Status: ${response.statusCode}");
      }
    } catch (e) {
      log("❗ Exception while calling company API: $e");
    }

    return null;
  }

  /// Search API method
  Future<void> getSearchEmployeeData() async {
    String employeeId = _searchController.text;
    if (employeeId.isEmpty) return;
    setState(() {
      isLoading = true;
      _showSearchResult = false;
    });
    var client = http.Client();
    var uri =
        Uri.parse('${singletonClass.baseURL}/employee/search?emp=$employeeId');

    var response = await client.get(uri, headers: singletonClass.getHeaders());
    setState(() => isLoading = false);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = SearchEmployeeData.fromJson(responseBody);

      SearchedResult result = SearchedResult(
        empId: employeeData.data?.employees!.first.id,
        employeeName: employeeData.data?.employees!.first.firstName,
      );

      print(">>>>$result");
      setState(() {
        _employeeSearchResults.removeWhere((e) => e.empId == result.empId);
        _employeeSearchResults.add(result);
        _showSearchResult = true;
      });
      print("???$_employeeSearchResults");
    } else {
      setState(() {
        _showSearchResult = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.employeeNotFound)),
      );
    }
  }

  /// Create Method
  Future<void> createDocument() async {
    try {
      final Map<String, dynamic> data = {
        "companyId": documentType == "Employee Documents"
            ? singletonClass.getJWTModel()?.companyId
            : documentType == "Company Documents"
                ? selectedCompanyID
                : selectedCompanyID,
        "branchId": documentType == "Employee Documents"
            ? singletonClass.getJWTModel()?.branchId
            : documentType == "Company Documents"
                ? selectedBranchID
                : singletonClass.getJWTModel()?.branchId,
        "attachmentName": documentName.text.trim(),
        "attachmentURL":
            singletonClass.attachmentResponseDataList.first.data!.url,
        "expiryDate": expiryDateController.text.trim(),
        "objectType": documentType == "Employee Documents"
            ? "employee"
            : documentType == "Company Documents"
                ? "company"
                : "asset",
        "objectId": documentType == "Employee Documents"
            ? _selectedEmployees.first!.empId
            : documentType == "Company Documents"
                ? selectedCompanyID
                : selectedAssetID,
        "status": "active",
      };

      if (kDebugMode) print("REQUEST JSON POST: ${jsonEncode(data)}");

      if (mounted) setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse("${singletonClass.baseURL}/doc-notifications/create"),
        headers: singletonClass.getHeaders(),
        body: json.encode(data),
      );

      if (mounted) setState(() => isLoading = false);

      final decodedResponse = json.decode(response.body);
      if (kDebugMode) print("REQUEST RESPONSE: $decodedResponse");

      final int statusCode =
          (decodedResponse['statusCode'] ?? response.statusCode) as int;

      if (statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ?? "Created successfully",
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
            MaterialPageRoute(
                builder: (context) => MainScreen(
                    index: 0, selectedIndex: 0, showBanner: false)),
          );
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: decodedResponse['errorMessage'] ??
              AppLocalizations.of(context)!.unexpectedError,
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
