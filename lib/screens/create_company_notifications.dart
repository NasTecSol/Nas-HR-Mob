import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/requests/request_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
    final assets = singletonClass.companyDetailDocumentNotificationDataList
        .isNotEmpty
        ? singletonClass.companyDetailDocumentNotificationDataList.first.data ?? []
        : [];

    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: Padding(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Stack(children: [
            ListView(padding: EdgeInsets.zero, children: [
              Column(
                children: [
                  ///Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_outlined),
                        ),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.create} ${AppLocalizations.of(context)!.notifications}",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  ///Content
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${AppLocalizations.of(context)!.documents} ${AppLocalizations.of(context)!.type}",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: " *",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                    decoration: InputDecoration(
                      hintText:
                          "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.documents} ${AppLocalizations.of(context)!.type}",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (documentType == "Employee Documents") ...[
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: NasColors.lightBlue,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.grey.withValues(alpha: 0.3),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                // Small remove button on top-right
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!
                                    .searchEmployee,
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text: " *",
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                        height: 200, // Adjust as needed
                        child: ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                  ],
                  if (documentType == "Company Documents") ...[
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.selectCompany,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          isExpanded: true,
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
                          hint: Row(
                            children: [
                              Image.asset('images/site.png',
                                  width: 15, height: 15),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCompanyName?.isNotEmpty == true
                                      ? selectedCompanyName!
                                      : AppLocalizations.of(context)!.select,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
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

                            // REMOVE DUPLICATES BY ID
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.selectBranch,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          value: singletonClass.availableBranches
                                  .any((b) => b.branchId == selectedBranchID)
                              ? selectedBranchID
                              : null,
                          hint: Text(
                            isLoadingBranches
                                ? AppLocalizations.of(context)!.loading
                                : (selectedBranchName == null ||
                                        selectedBranchName!.isEmpty)
                                    ? AppLocalizations.of(context)!.selectBranch
                                    : selectedBranchName!,
                          ),
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
                      ),
                    ),
                  ],
                  if (documentType == "Assets Documents") ...[
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    AppLocalizations.of(context)!.selectCompany,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          isExpanded: true,
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
                          hint: Row(
                            children: [
                              Image.asset('images/site.png',
                                  width: 15, height: 15),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedCompanyName?.isNotEmpty == true
                                      ? selectedCompanyName!
                                      : AppLocalizations.of(context)!.select,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
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

                            await getCompanyData(); // asset API

                            setState(() {
                              isAssetLoading = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.assets}",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child:DropdownButton<String>(
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          value: selectedAssetID,
                          hint: Text(
                            isAssetLoading
                                ? AppLocalizations.of(context)!.loading
                                : AppLocalizations.of(context)!.select,
                          ),
                          items: assets.map((asset) {
                            return DropdownMenuItem<String>(
                              value: asset.id,
                              child: Text(
                                "${asset.objectDetails?.objectName ?? ''} " " ${asset.objectDetails?.parameters?['رقم اللوحة'] ?? '---'}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.black,
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
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.documentName,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: " *",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                      keyboardType: TextInputType.text,
                      controller: documentName,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.documentName,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      )),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.expiryDate,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: " *",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: expiryDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.calendar_month),
                      filled: true,
                      hintText: AppLocalizations.of(context)!.selectDate,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
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
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.any);
                      if (result != null && result.files.single.path != null) {
                        final PlatformFile file = result.files.single;
                        setState(() => selectedFile = file);

                        final results = await uploadDocuments(file);
                        final bool success = results["success"] as bool;
                        final String message = results["message"] as String;

                        if (!success && context.mounted) {
                          setState(() => selectedFile = null);
                          // keep behavior same but show AlertDialog as in original
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(AppLocalizations.of(context)!
                                  .uploadFailedTitle),
                              content: Text(message),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    AppLocalizations.of(context)!.ok,
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
                        // keep original behaviour of printing cancellation
                        if (kDebugMode) print('File selection canceled.');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.link_outlined,
                            color: Colors.black, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.attachDocuments,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15),
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
                                  onTap: () =>
                                      setState(() => selectedFile = null),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
            if (isLoading) Loader(),
          ]),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  createDocument();
                },
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF47734D),
                        Color(0xFF5B9362),
                        Color(0xFF66A56E),
                        Color(0xFF76BE7F),
                        Color(0xFF86D991),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.create,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  ///API Methods
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

  ///Company data
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

  ///Search API method
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

      // Create a SearchedResult instance
      SearchedResult result = SearchedResult(
        empId: employeeData.data?.employees!.first.id,
        employeeName: employeeData.data?.employees!.first.firstName,
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

  ///Create Method
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
                builder: (context) => MainScreen(index: 0, selectedIndex: 0 , showBanner: false)),
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
