import 'dart:convert';
import 'dart:developer';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/screens/register_biometric_device_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../widgets/loader.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  SingletonClass singletonClass = SingletonClass();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nationalIdController = TextEditingController();
  final iqamaController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final userName = TextEditingController();
  final password = TextEditingController();
  final designation = TextEditingController();
  final degreeName = TextEditingController();
  final degreeType = TextEditingController();
  final basicSalary = TextEditingController();
  final bankName = TextEditingController();
  final accountNox = TextEditingController();
  bool isLoading = false;
  PlatformFile? selectedFile;
  String? profilePicUrl;
  String? selectedTeamId;
  String? selectedCountryName;
  String? selectedFlagEmoji;
  String? nationality;
  String? gender;
  String? religion;
  String? maritalStatus;
  String? hierarchyGroup;
  String? role;
  String? contractType = "Permanent";
  String? currency;
  String? salaryPeriod;
  DateTime? selectedDate;
  DateTime? contractEndDate;

  /// Dropdown values
  String? selectedCompany;
  String? selectedBranch;
  String? selectedDepartment;
  String? selectedSupervisor;
  String? selectedShift;

  /// IDs for API
  String? selectedCompanyId;
  String? selectedBranchId;
  String? selectedDepartmentId;
  String? selectedSupervisorId;
  String? selectedShiftId;
  String? selectedShiftType;
  String? selectedShiftFrom;
  String? selectedShiftTo;

  /// Dynamic dropdown data
  List<Map<String, String>> companies = [];
  List<Map<String, String>> branches = [];
  List<Map<String, String>> departments = [];
  List<Map<String, String>> supervisors = [];
  List<Map<String, String>> shifts = [];

  @override
  void initState() {
    super.initState();
    singletonClass.getBiometricDevices();
    final orgData = singletonClass.organizationModelDataList.first.data;
    if (orgData?.companies != null && orgData!.companies!.isNotEmpty) {
      companies = orgData.companies!
          .map<Map<String, String>>((e) => {
                'id': e.id ?? '',
                'name': e.name ?? '',
              })
          .toList();
    }
    firstNameController.addListener(() {
      userName.text =
          "${firstNameController.text}${lastNameController.text}".trim();
    });

    lastNameController.addListener(() {
      userName.text =
          "${firstNameController.text}${lastNameController.text}".trim();
    });
  }

  void _onCompanySelected(String? val) {
    setState(() {
      selectedCompany = val;
      selectedCompanyId = companies.firstWhere((c) => c['name'] == val)['id'];
      selectedBranch = null;
      selectedBranchId = null;
      selectedDepartment = null;
      selectedDepartmentId = null;
      selectedSupervisor = null;
      selectedSupervisorId = null;
      selectedShift = null;
      selectedShiftId = null;

      branches.clear();
      departments.clear();
      supervisors.clear();
      shifts.clear();

      final orgData = singletonClass.organizationModelDataList.first.data;
      final company = orgData?.companies?.firstWhere(
        (c) => c.name == val,
        orElse: () => orgData.companies!.first,
      );

      if (company != null && company.branches != null) {
        branches = company.branches!
            .map<Map<String, String>>((b) => {
                  'id': b.id ?? '',
                  'name': b.branchName ?? '',
                })
            .toList();
      }
    });
  }

  void _onBranchSelected(String? val) {
    setState(() {
      selectedBranch = val;
      selectedBranchId = branches.firstWhere((b) => b['name'] == val)['id'];
      selectedDepartment = null;
      selectedDepartmentId = null;
      selectedSupervisor = null;
      selectedSupervisorId = null;
      selectedShift = null;
      selectedShiftId = null;

      departments.clear();
      supervisors.clear();
      shifts.clear();

      final orgData = singletonClass.organizationModelDataList.first.data;
      final branch = orgData?.companies
          ?.firstWhere((c) => c.name == selectedCompany)
          .branches
          ?.firstWhere((b) => b.branchName == val);

      if (branch != null) {
        // ✅ Parse departments correctly
        departments = branch.departments
                ?.map<Map<String, String>>((d) => {
                      'id': d.departmentId ?? '',
                      'name': d.departmentName ?? '',
                    })
                .toList() ??
            [];

        // ✅ Parse shifts with all required info
        shifts = branch.shifts
                ?.map<Map<String, String>>((s) => {
                      'id': s.shiftId ?? '',
                      'name': s.shiftName ?? '',
                      'type': s.shiftType ?? '',
                      'timeFrom': s.timeFrom ?? '',
                      'timeTo': s.timeTo ?? '',
                    })
                .toList() ??
            [];
      }
    });
  }

  void _onDepartmentSelected(String? val) {
    setState(() {
      selectedDepartment = val;
      selectedDepartmentId =
          departments.firstWhere((d) => d['name'] == val)['id'];
      selectedSupervisor = null;
      selectedSupervisorId = null;
      supervisors.clear();

      try {
        final orgData = singletonClass.organizationModelDataList.first.data;

        final company = orgData?.companies?.firstWhere(
          (c) => c.name == selectedCompany,
        );
        final branch = company?.branches?.firstWhere(
          (b) => b.branchName == selectedBranch,
        );
        final dept = branch?.departments?.firstWhere(
          (d) => d.departmentName == val,
        );

        if (dept != null &&
            dept.supervisors != null &&
            dept.supervisors!.isNotEmpty) {
          supervisors = dept.supervisors!
              .map<Map<String, String>>((s) => {
                    'id': s['employeeId']?.toString() ?? '',
                    'empId': s['empId']?.toString() ?? '',
                    'teamId': s['teamId']?.toString() ?? '',
                    'name': s['userName']?.toString() ?? '',
                    'designation': s['designation']?.toString() ?? '',
                  })
              .where((s) => s['name']!.isNotEmpty)
              .toList();
        }
      } catch (e, st) {
        debugPrint('Error in _onDepartmentSelected: $e\n$st');
      }
    });
  }

  void _onSupervisorSelected(String? val) {
    setState(() {
      selectedSupervisor = val;
      final selected =
          supervisors.firstWhere((s) => s['name'] == val, orElse: () => {});
      selectedSupervisorId = selected['empId'];
      selectedTeamId = selected['teamId'];
    });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (singletonClass.getJWTModel()?.grade == 'L0' ||
          singletonClass.getJWTModel()?.grade == 'L1' ||
          singletonClass.getJWTModel()?.grade == 'L2') {
        if (selectedCompany == null ||
            selectedBranch == null ||
            selectedDepartment == null ||
            selectedShift == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.pleaseSelectAllFields),
            ),
          );
          return;
        }
      } else {
        if (selectedCompany == null ||
            selectedBranch == null ||
            selectedDepartment == null ||
            selectedSupervisor == null ||
            selectedShift == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.pleaseSelectAllFields),
            ),
          );
          return;
        }
      }
    }

    if (_currentPage == 1) {
      if (firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty ||
          nationality == null ||
          phoneController.text.isEmpty ||
          emailController.text.isEmpty ||
          selectedDate == null ||
          religion == null ||
          maritalStatus == null ||
          userName.text.isEmpty ||
          password.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
          ),
        );
        return;
      }
      String email = emailController.text.trim();
      if (!email.contains('@') || !email.contains('.com')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseEnterValidEmail),
          ),
        );
        return;
      }
    }

    if (_currentPage == 2) {
      if (hierarchyGroup == null ||
          designation.text.isEmpty ||
          role == null ||
          contractType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
          ),
        );
        return;
      }
    }

    if (_currentPage == 3) {
      if (basicSalary.text.isEmpty ||
          currency == null ||
          salaryPeriod == null ||
          bankName.text.isEmpty ||
          accountNox.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseFillAllFields),
          ),
        );
        return;
      }
      createEmployee();
      return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
            child: Stack(children: [
              Column(children: [
                /// Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentPage == 0) {
                          Navigator.pop(context);
                        } else {
                          _previousPage();
                        }
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
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _currentPage == 0
                              ? Icons.close
                              : Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      local.employeeOnboarding,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        if (_currentPage == 0 ||
                            _currentPage == 1 ||
                            _currentPage == 2) {
                          _nextPage();
                        } else {
                          createEmployee();
                        }
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
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _currentPage == 3
                              ? Icons.done
                              : Icons.arrow_forward_ios_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                /// Steps
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(4, (index) {
                      final titles = ["🏢", "🙎🏻‍♂️", "💻", "💰"];
                      final isActive = _currentPage == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  isActive ? Colors.teal : Colors.grey[300],
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                    color:
                                        isActive ? Colors.white : Colors.black),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Text(
                                titles[index],
                                style: GoogleFonts.inter(
                                  color: isActive ? Colors.black : Colors.grey,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                /// PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      /// Page 1
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.companyInfo,
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 20),

                            /// Company Dropdown
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .selectCompany,
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
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              value: selectedCompany,
                              hint: Text(
                                  AppLocalizations.of(context)!.selectCompany),
                              items: companies
                                  .map((e) => DropdownMenuItem(
                                      value: e['name'],
                                      child: Text(e['name']!)))
                                  .toList(),
                              onChanged: _onCompanySelected,
                            ),
                            const SizedBox(height: 16),

                            /// Branch Dropdown
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .selectBranch,
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
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              value: selectedBranch,
                              hint: Text(
                                  AppLocalizations.of(context)!.selectBranch),
                              items: branches
                                  .map((e) => DropdownMenuItem(
                                      value: e['name'],
                                      child: Text(e['name']!)))
                                  .toList(),
                              onChanged: _onBranchSelected,
                            ),
                            const SizedBox(height: 16),

                            /// Department Dropdown
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .selectDepartment,
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
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              value: selectedDepartment,
                              hint: Text(AppLocalizations.of(context)!
                                  .selectDepartment),
                              items: departments
                                  .map((e) => DropdownMenuItem(
                                      value: e['name'],
                                      child: Text(e['name']!)))
                                  .toList(),
                              onChanged: _onDepartmentSelected,
                            ),
                            const SizedBox(height: 16),

                            /// Supervisor Dropdown
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .selectSupervisor,
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
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              value: supervisors.isEmpty
                                  ? null
                                  : selectedSupervisor,
                              hint: Text(
                                supervisors.isEmpty
                                    ? AppLocalizations.of(context)!.noSupervisorFound
                                    : AppLocalizations.of(context)!
                                        .selectSupervisor,
                              ),
                              items: supervisors.isEmpty
                                  ? [
                                       DropdownMenuItem(
                                        value: null,
                                        enabled: false,
                                        child: Text(
                                          AppLocalizations.of(context)!.noSupervisorFound,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    ]
                                  : supervisors
                                      .map((e) => DropdownMenuItem(
                                            value: e['name'],
                                            child: Text(e['name']!),
                                          ))
                                      .toList(),
                              onChanged: supervisors.isEmpty
                                  ? null
                                  : (value) => _onSupervisorSelected(value),
                            ),
                            const SizedBox(height: 16),

                            /// Shift Dropdown
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .selectShift,
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
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.black, width: 1.5),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              value: selectedShift,
                              hint: Text(
                                  AppLocalizations.of(context)!.selectShift),
                              items: shifts
                                  .map((shift) => DropdownMenuItem<String>(
                                        value: shift['name'],
                                        child: Text(shift['name'] ?? ''),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedShift = value;

                                  final selected = shifts
                                      .firstWhere((s) => s['name'] == value);
                                  selectedShiftId = selected['id'];
                                  selectedShiftType = selected['type'];
                                  selectedShiftFrom = selected['timeFrom'];
                                  selectedShiftTo = selected['timeTo'];
                                });
                              },
                            )
                          ],
                        ),
                      ),

                      ///Page 2
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .personalAndEducationalInfo,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 20),

                              /// ===== FIRST NAME =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .firstName,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: firstNameController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterFirstName,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),
                              const SizedBox(height: 12),

                              // ===== LAST NAME =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .lastName,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: lastNameController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterLastName,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              // ===== NATIONALITY =====
                              RichText(
                                text: const TextSpan(
                                  text: "Nationality ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "*",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 55,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CountryCodePicker(
                                        onChanged: (country) {
                                          setState(() {
                                            nationality = country.name;
                                            selectedCountryName = country.name;
                                          });
                                        },
                                        initialSelection: 'SA',
                                        showCountryOnly: true,
                                        showOnlyCountryWhenClosed: true,
                                        alignLeft: true,
                                        showFlag: true,
                                        showFlagDialog: true,
                                        padding: EdgeInsets.zero,
                                        textStyle: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ====Gender ====
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .gender,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                hint: Text(
                                    "-- ${AppLocalizations.of(context)!.gender} --"),
                                value: gender,
                                items: [
                                  AppLocalizations.of(context)!.male,
                                  AppLocalizations.of(context)!.female,
                                  (AppLocalizations.of(context)!.other),
                                ]
                                    .map((val) => DropdownMenuItem(
                                        value: val, child: Text(val)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => gender = val);
                                },
                              ),

                              const SizedBox(height: 12),

                              /// ===== NATIONAL ID =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .nationalId,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: nationalIdController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterNationalId,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              // ===== IQAMA NUMBER =====
                              if(nationality != "العربية السعودية")...[ RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .iqamaNumber,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                                const SizedBox(height: 8),
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    controller: iqamaController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .enterIqamaNumber,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                        const BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                    )),
                                const SizedBox(height: 12),
                              ],
                              // ===== PHONE =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            AppLocalizations.of(context)!.phone,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterPhoneNumber,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              // ===== EMAIL =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .enterEmail,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterEmail,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              // ===== ADDRESS =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .address,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: addressController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterAddress,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              /// ===== DATE OF BIRTH =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .dateOfBirth,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
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
                                              foregroundColor:
                                                  NasColors.darkBlue,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() => selectedDate = picked);
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: selectedDate != null
                                          ? "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}"
                                          : "yyyy/mm/dd",
                                      suffixIcon: Icon(Icons.calendar_today),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ===== RELIGION =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .religion,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                hint: Text(
                                    "-- ${AppLocalizations.of(context)!.selectReligion} --"),
                                value: religion,
                                items: [
                                  (AppLocalizations.of(context)!.islam),
                                  (AppLocalizations.of(context)!.christianity),
                                  (AppLocalizations.of(context)!.hinduism),
                                  (AppLocalizations.of(context)!.other)
                                ]
                                    .map((val) => DropdownMenuItem(
                                        value: val, child: Text(val)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => religion = val);
                                },
                              ),

                              const SizedBox(height: 12),

                              // ===== MARITAL STATUS =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .martialStatus,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                hint: Text(
                                    "-- ${AppLocalizations.of(context)!.selectStatus} --"),
                                value: maritalStatus,
                                items: [
                                  (AppLocalizations.of(context)!.single),
                                  (AppLocalizations.of(context)!.married),
                                  (AppLocalizations.of(context)!.divorced),
                                  (AppLocalizations.of(context)!.widowed)
                                ]
                                    .map((val) => DropdownMenuItem(
                                        value: val, child: Text(val)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => maritalStatus = val);
                                },
                              ),

                              const SizedBox(height: 12),

                              // ===== USERNAME =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .username,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: userName,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enterUsername,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // ===== PASSWORD =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .password,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enterPassword,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),

                              const SizedBox(height: 12),
                              // Degree Name
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .degreeName,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: degreeName,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterDegreeName,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              SizedBox(height: 12),

                              // Degree Type
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .degreeType,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: degreeType,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterDegreeType,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),
                              const SizedBox(height: 20),
                              // ===== PROFILE PICTURE =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .profilePicture,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // 🔹 Show button only when no profile image uploaded
                                  if (profilePicUrl == null ||
                                      profilePicUrl!.isEmpty)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: NasColors.darkBlue,
                                        // 🔹 Button color
                                        foregroundColor: Colors.white,
                                        // 🔹 Text color
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                      ),
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                        );

                                        if (result != null &&
                                            result.files.single.path != null) {
                                          PlatformFile file =
                                              result.files.single;
                                          setState(() {
                                            selectedFile = file;
                                          });

                                          print('Selected file: ${file.name}');
                                          await uploadProfileToS3(file);
                                          setState(
                                              () {}); // refresh to show image preview
                                        } else {
                                          print('File selection canceled.');
                                        }
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .chooseFile),
                                    )
                                  else
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            profilePicUrl!,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    color: Colors.grey),
                                          ),
                                        ),
                                        Positioned(
                                          right: -6,
                                          top: -6,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                profilePicUrl = '';
                                                selectedFile = null;
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(Icons.close,
                                                  color: Colors.white,
                                                  size: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(width: 10),

                                  // 🔹 Show text only when no file chosen
                                  if (profilePicUrl == null ||
                                      profilePicUrl!.isEmpty)
                                    Text(
                                      AppLocalizations.of(context)!
                                          .noFileChosen,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      ///Page 3
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .professionalInformation,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 20),

                              // ===== HIERARCHY GROUP =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .hierarchyGroup,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                hint: Text(AppLocalizations.of(context)!
                                    .selectHierarchyGroup),
                                value: hierarchyGroup,
                                items: ["L1", "L2", "L3", "L4"]
                                    .map((val) => DropdownMenuItem(
                                        value: val, child: Text(val)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => hierarchyGroup = val);
                                },
                              ),

                              const SizedBox(height: 12),

                              // ===== DESIGNATION =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .designation,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: designation,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterDesignation,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              const SizedBox(height: 12),

                              // ===== ROLE =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text:
                                            AppLocalizations.of(context)!.role,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                hint: Text(
                                    AppLocalizations.of(context)!.selectRole),
                                value: role,
                                items: [
                                  (AppLocalizations.of(context)!.junior),
                                  (AppLocalizations.of(context)!.mid),
                                  (AppLocalizations.of(context)!.senior)
                                ]
                                    .map((val) => DropdownMenuItem(
                                        value: val, child: Text(val)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => role = val);
                                },
                              ),

                              const SizedBox(height: 12),

                              // ===== CONTRACT TYPE =====
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .contractType,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    TextSpan(
                                        text: " *",
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Radio(
                                      value: "Permanent",
                                      activeColor: NasColors.darkBlue,
                                      groupValue: contractType,
                                      onChanged: (val) {
                                        setState(() => contractType = val);
                                      }),
                                  Text(AppLocalizations.of(context)!.permanent),
                                  const SizedBox(width: 20),
                                  Radio(
                                      value: "Temporary",
                                      activeColor: NasColors.darkBlue,
                                      groupValue: contractType,
                                      onChanged: (val) {
                                        setState(() => contractType = val);
                                      }),
                                  Text(AppLocalizations.of(context)!.temporary),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ===== END OF CONTRACT =====
                              if (contractType == "Temporary") ...[
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .endOfContract,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      TextSpan(
                                          text: " *",
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: NasColors.darkBlue,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                            dialogBackgroundColor: Colors.white,
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    NasColors.darkBlue,
                                              ),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() => contractEndDate = picked);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: contractEndDate != null
                                            ? "${contractEndDate!.day}/${contractEndDate!.month}/${contractEndDate!.year}"
                                            : "dd/mm/yyyy",
                                        suffixIcon: Icon(Icons.calendar_today),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.grey),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.5),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      ///page 4
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.salaryInformation,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),

                              SizedBox(height: 20),

                              // Basic Salary
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .basicSalary,
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
                              const SizedBox(height: 8),
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: basicSalary,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterBasicSalary,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              SizedBox(height: 12),

                              // Currency
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .currency,
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
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                value: currency,
                                items: ["USD", "PKR", "SAR", "EUR"]
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => currency = val);
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .selectCategory,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),

                              SizedBox(height: 12),

                              // Salary Period
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .salaryPeriod,
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
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                value: salaryPeriod,
                                items: ["Daily", "Weekly", "Monthly", "Hourly"]
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => salaryPeriod = val);
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .selectSalaryPeriod,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),

                              SizedBox(height: 12),

                              // Bank Name
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .bankName,
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
                              const SizedBox(height: 8),
                              TextField(
                                  controller: bankName,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterBankName,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),

                              SizedBox(height: 12),

                              // Account No
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .accountNo,
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
                              const SizedBox(height: 8),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: accountNox,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .enterAccountNo,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              if (isLoading) Loader(),
            ])));
  }

  ///S3 Bucket Call Method
  Future<String?> uploadProfileToS3(PlatformFile file) async {
    try {
      setState(() => isLoading = true);

      // ✅ Convert file to bytes (if not already)
      Uint8List fileBytes = file.bytes ?? await File(file.path!).readAsBytes();

      // ✅ Compress if size > 1MB
      if (fileBytes.length > 1000000) {
        fileBytes = await FlutterImageCompress.compressWithList(
          fileBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
          format: CompressFormat.jpeg,
        );
      }

      // ✅ Prepare request
      var uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      var request = http.MultipartRequest('POST', uri);
      final mimeType =
          lookupMimeType(file.path ?? '', headerBytes: fileBytes) ??
              'application/octet-stream';

      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      // ✅ Send request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('📤 Upload Response: $responseBody');

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final jsonRes = json.decode(responseBody);
        profilePicUrl = jsonRes['data']?['url'] ?? jsonRes['url'] ?? '';
        print('✅ Profile Picture URL: $profilePicUrl');
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Upload error: $e');
      setState(() => isLoading = false);
      return null;
    }
    return null;
  }

  ///API CALL METHOD
  Future<void> createEmployee() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    String? organizationID = singletonClass.getJWTModel()?.organizationId;
    final Map<String, dynamic> data = {
      "userName": userName.text,
      "password": password.text,
      "email": [
        {
          "personalEmail": emailController.text,
          "workEmail": emailController.text,
        }
      ],
      "firstName": firstNameController.text,
      "middleName": '',
      "lastName": lastNameController.text,
      "branchId": selectedBranchId,
      "martialStatus": maritalStatus.toString(),
      "religion": religion.toString(),
      "address": {
        "streetAddress": addressController.text,
        "city": '',
        "country": ''
      },
      "NIC": nationalIdController.text,
      "iqamaNumber": {
        "id": iqamaController.text,
        "issueDate": '',
        "expiryDate": ''
      },
      "passport": {"id": '', "issueDate": '', "expiryDate": ''},
      "imigrationSatus": "foreigner",
      "DOB": selectedDate.toString(),
      "age": _calculateAge(selectedDate.toString()),
      "phoneNumber": [
        {
          "mobileNumber": phoneController.text,
          "landlineNumber": phoneController.text,
        }
      ],
      "gender": gender.toString(),
      "role": role.toString(),
      "profession": "",
      "nationality": nationality.toString(),
      "profilePic": profilePicUrl,
      "familyInfo": {
        "fatherName": '',
        "motherName": '',
        "familyAddress": {"streetAddress": '', "city": '', "country": ''},
        "familyContactNumber": '',
        "emergencyContactInfo": [
          {
            "relationName": '',
            "relationType": '',
            "relationContactNumber": '',
            "relationAddress": ''
          }
        ]
      },
      "educationInfo": [
        {
          "degreeName": degreeName.text,
          "degreeType": degreeType.text,
          "fieldofStudy": '',
          "institute": '',
          "from": '',
          "to": '',
          "results": ''
        }
      ],
      "experienceBackground": [],
      "bankingInfo": [
        {
          "title": bankName.text,
          "accountNumber": accountNox.text,
          "branchCode": '',
          "accountType": '',
          "country": '',
          "empSwiftCode": '',
          "bankName": '',
        }
      ],
      "employeeInfo": [
        {
          "depId": selectedDepartmentId,
          "depName": selectedDepartment,
          "jobTitle": "",
          "jobDescription": '',
          "reportingManager": selectedSupervisorId,
          "jobRank": '',
          "designation": designation.text,
          "grade": hierarchyGroup.toString(),
          "workDomain": '',
          "location": '',
          "employeeStatus": "Active",
          "employeeType": '',
          "employeeShift": selectedShiftId,
          "joiningDate": today,
          "leavingDate": '',
          "hiringDate": today,
          "noticePeriod": '',
          "empSignature": ''
        }
      ],
      "salaryInfo": {
        "baseSalary": basicSalary.text,
        "currency": currency.toString(),
        "timeCycle_Period": salaryPeriod.toString(),
        "allowance_Benefits": [],
        "deductions": [],
        "taxInfo": {
          "taxPercentage": '',
          "deductableAmount": '',
          "timeCycle": ''
        },
        "allowanceContribution": '',
        "netSalary": ''
      },
      "shiftInfo": {
        "shiftId": selectedShiftId.toString(),
        "shiftType": selectedShiftType.toString(),
        "shiftName": selectedShift.toString(),
        "timeFrom": selectedShiftFrom.toString(),
        "timeTo": selectedShiftTo.toString(),
      },
      "socialLinks": [],
      "loanInfo": [],
      "assetsInfo": [],
      "remoteLocation": {
        "isRemoteAttendance": '',
        "remoteAttendanceLoc": '',
        "lastLocation": '',
        "lastLocationUpdatedAt": ''
      },
      "contractInfo": [
        {
          "contractId": '',
          "contractStatus": '',
          "contractType": contractType.toString(),
          "contractStartDate": today,
          "contractExpiry": contractEndDate.toString(),
          "probabtionStartDate": '',
          "probationPeriod": '',
          "probationstatus": ''
        }
      ],
      "documentsInfo": [],
      "createdBy": singletonClass.getJWTModel()?.empId ?? '',
    };

    String body = json.encode(data);

    final uri = Uri.parse(
        "${singletonClass.baseURL}/employee/create?branchId=$selectedBranchId&departmentId=$selectedDepartmentId&organizationId=$organizationID&teamId=$selectedTeamId");
    try {
      setState(() => isLoading = true);
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      log("++++++${response.body}");
      if (response.statusCode == 200) {
        setState(() => isLoading = false);
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['statusCode'] == 200) {
          final newEmployee = decodedResponse['data']['newEmployee'];
          final employeeInfo = newEmployee['employeeInfo'][0];
          final empId = employeeInfo['empId'];
          final firstName = newEmployee['firstName'];
          final lastName = newEmployee['lastName'];
          final userName = newEmployee['userName'];
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.success,
            type: QuickAlertType.success,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterBiometricDeviceScreen(
                empId: empId,
                firstName: firstName,
                lastName: lastName,
                userName: userName,
              ),
            ),
          );
        } else if (decodedResponse['statusCode'] == 400) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.internalServerError,
            type: QuickAlertType.error,
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 500) {
        setState(() => isLoading = false);
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.errorFetchData,
          type: QuickAlertType.error,
        );
      } else {
        print('Error: ${response.statusCode}');
        setState(() => isLoading = false);
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: 'Error: ${response.statusCode}',
          type: QuickAlertType.error,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error: $e");
    }
  }

// helper method
  int _calculateAge(String? birthDateString) {
    if (birthDateString == null || birthDateString.isEmpty) return 0;
    final birthDate = DateTime.tryParse(birthDateString);
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
