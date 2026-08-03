import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../l10n/app_localizations.dart';
import '../screens/register_biometric_device_screen.dart';
import '../singleton_class.dart';
import '../widgets/colors.dart';
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
  final accountNo = TextEditingController();
  final allowancePercentage = TextEditingController();
  final deductionPercentage = TextEditingController();
  final allowanceAmount = TextEditingController();
  final deductionAmount = TextEditingController();
  final allowanceName = TextEditingController();
  final deductionName = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
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
  String? deductionType;
  String? basedOn;
  String? allowanceType;
  String? deductionBasedOn;
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
  bool salaryExpanded = false;
  bool allowanceExpanded = false;
  bool deductionExpanded = false;
  List<AllowanceFormModel> allowances = [AllowanceFormModel()];
  List<DeductionFormModel> deductions = [DeductionFormModel()];

  @override
  void initState() {
    super.initState();
    singletonClass.getBiometricDevices();
    setState(() {
      selectedCountryName = 'العربية السعودية';
      nationality = 'العربية السعودية';
    });
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
        departments = branch.departments
                ?.map<Map<String, String>>((d) => {
                      'id': d.departmentId ?? '',
                      'name': d.departmentName ?? '',
                    })
                .toList() ??
            [];

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
      if (password.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordMustBeSixDigit),
          ),
        );
        return;
      }
      if (phoneController.text.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .phoneNumberMustBeAtLeastTenDigits),
          ),
        );
        return;
      }
      if (iqamaController.text.isNotEmpty) {
        if (iqamaController.text.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .iqamaNumberMustBeAtLeastTenDigits),
            ),
          );
          return;
        }
      }
      if (nationalIdController.text.isNotEmpty) {
        if (nationalIdController.text.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .nationalIDNumberMustBeAtLeastTenDigits),
            ),
          );
          return;
        }
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
          accountNo.text.isEmpty) {
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
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context, local),
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildPage1(context, local),
                    _buildPage2(context, local),
                    _buildPage3(context, local),
                    _buildPage4(context, local),
                  ],
                ),
              ),
              _buildBottomNavigation(context, local),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  // ── Header (Gradient with title & action buttons, NO decorative logo icon) ──
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
            onTap: () {
              if (_currentPage == 0) {
                Navigator.pop(context);
              } else {
                _previousPage();
              }
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.18),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(
                _currentPage == 0
                    ? Icons.close_rounded
                    : Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              local.employeeOnboarding,
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

  // ── Modern Stepper Indicator ──────────────────────────────────────────
  Widget _buildStepIndicator() {
    final stepIcons = [
      Icons.business_rounded,
      Icons.person_rounded,
      Icons.work_rounded,
      Icons.payments_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = _currentPage == index;
          final isCompleted = _currentPage > index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (index < _currentPage) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? NasColors.darkBlue
                                : (isCompleted
                                    ? NasColors.darkBlue.withOpacity(0.15)
                                    : Colors.grey.shade100),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: NasColors.darkBlue.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_rounded : stepIcons[index],
                            size: 18,
                            color: isActive
                                ? Colors.white
                                : (isCompleted
                                    ? NasColors.darkBlue
                                    : Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Step ${index + 1}",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive
                                ? NasColors.darkBlue
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < 3)
                  Container(
                    width: 16,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 14),
                    color: isCompleted
                        ? NasColors.darkBlue
                        : Colors.grey.shade200,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Field Label with Friendly Icon ─────────────────────────────────────
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
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: prefixIcon,
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

  // ── Section Card Container Helper ──────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NasColors.darkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: NasColors.darkBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── PAGE 1: Company Information ────────────────────────────────────────
  Widget _buildPage1(BuildContext context, AppLocalizations local) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildSectionCard(
        title: local.companyInfo,
        icon: Icons.business_rounded,
        children: [
          /// Company Dropdown
          _buildFieldLabel(local.selectCompany, icon: Icons.domain_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: local.selectCompany,
            ),
            value: selectedCompany,
            hint: Text(local.selectCompany),
            items: companies
                .map((e) => DropdownMenuItem(
                    value: e['name'], child: Text(e['name']!)))
                .toList(),
            onChanged: _onCompanySelected,
          ),
          const SizedBox(height: 16),

          /// Branch Dropdown
          _buildFieldLabel(local.selectBranch, icon: Icons.location_city_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: local.selectBranch,
            ),
            value: selectedBranch,
            hint: Text(local.selectBranch),
            items: branches
                .map((e) => DropdownMenuItem(
                    value: e['name'], child: Text(e['name']!)))
                .toList(),
            onChanged: _onBranchSelected,
          ),
          const SizedBox(height: 16),

          /// Department Dropdown
          _buildFieldLabel(local.selectDepartment, icon: Icons.account_tree_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: local.selectDepartment,
            ),
            value: selectedDepartment,
            hint: Text(local.selectDepartment),
            items: departments
                .map((e) => DropdownMenuItem(
                    value: e['name'], child: Text(e['name']!)))
                .toList(),
            onChanged: _onDepartmentSelected,
          ),
          const SizedBox(height: 16),

          /// Supervisor Dropdown
          _buildFieldLabel(local.selectSupervisor, icon: Icons.supervisor_account_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: supervisors.isEmpty
                  ? local.noSupervisorFound
                  : local.selectSupervisor,
            ),
            value: supervisors.isEmpty ? null : selectedSupervisor,
            hint: Text(
              supervisors.isEmpty
                  ? local.noSupervisorFound
                  : local.selectSupervisor,
            ),
            items: supervisors.isEmpty
                ? [
                    DropdownMenuItem(
                      value: null,
                      enabled: false,
                      child: Text(
                        local.noSupervisorFound,
                        style: const TextStyle(color: Colors.grey),
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
          _buildFieldLabel(local.selectShift, icon: Icons.access_time_filled_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            isExpanded: true,
            decoration: _buildInputDecoration(
              hintText: local.selectShift,
            ),
            value: selectedShift,
            hint: Text(local.selectShift),
            items: shifts
                .map((shift) => DropdownMenuItem<String>(
                      value: shift['name'],
                      child: Text(shift['name'] ?? ''),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedShift = value;
                final selected = shifts.firstWhere((s) => s['name'] == value);
                selectedShiftId = selected['id'];
                selectedShiftType = selected['type'];
                selectedShiftFrom = selected['timeFrom'];
                selectedShiftTo = selected['timeTo'];
              });
            },
          ),
        ],
      ),
    );
  }

  // ── PAGE 2: Personal & Educational Information ─────────────────────────
  Widget _buildPage2(BuildContext context, AppLocalizations local) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildSectionCard(
        title: local.personalAndEducationalInfo,
        icon: Icons.person_rounded,
        children: [
          /// First Name
          _buildFieldLabel(local.firstName, icon: Icons.badge_rounded),
          TextField(
            controller: firstNameController,
            decoration: _buildInputDecoration(
              hintText: local.enterFirstName,
            ),
          ),
          const SizedBox(height: 14),

          /// Last Name
          _buildFieldLabel(local.lastName, icon: Icons.badge_outlined),
          TextField(
            controller: lastNameController,
            decoration: _buildInputDecoration(
              hintText: local.enterLastName,
            ),
          ),
          const SizedBox(height: 14),

          /// Nationality
          _buildFieldLabel(local.nationality, icon: Icons.flag_rounded),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
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
                    textStyle: GoogleFonts.inter(
                        fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          /// Gender
          _buildFieldLabel(local.gender, icon: Icons.people_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: "-- ${local.gender} --",
            ),
            value: gender,
            hint: Text("-- ${local.gender} --"),
            items: [local.male, local.female, local.other]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              setState(() => gender = val);
            },
          ),
          const SizedBox(height: 14),

          /// National ID (Saudi Arabia)
          if (nationality == "العربية السعودية") ...[
            _buildFieldLabel(local.nationalId, isRequired: false, icon: Icons.credit_card_rounded),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: nationalIdController,
              decoration: _buildInputDecoration(
                hintText: local.enterNationalId,
              ),
            ),
            const SizedBox(height: 14),
          ],

          /// Iqama Number (Other nationalities)
          if (nationality != "العربية السعودية") ...[
            _buildFieldLabel(local.iqamaNumber, isRequired: false, icon: Icons.card_membership_rounded),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: iqamaController,
              decoration: _buildInputDecoration(
                hintText: local.enterIqamaNumber,
              ),
            ),
            const SizedBox(height: 14),
          ],

          /// Phone Number
          _buildFieldLabel(local.phone, icon: Icons.phone_rounded),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: phoneController,
            decoration: _buildInputDecoration(
              hintText: local.enterPhoneNumber,
            ),
          ),
          const SizedBox(height: 14),

          /// Email Address
          _buildFieldLabel(local.enterEmail, icon: Icons.email_rounded),
          TextFormField(
            controller: emailController,
            decoration: _buildInputDecoration(
              hintText: local.enterEmail,
            ),
          ),
          const SizedBox(height: 14),

          /// Address
          _buildFieldLabel(local.address, isRequired: false, icon: Icons.home_rounded),
          TextField(
            controller: addressController,
            decoration: _buildInputDecoration(
              hintText: local.enterAddress,
            ),
          ),
          const SizedBox(height: 14),

          /// Date of Birth
          _buildFieldLabel(local.dateOfBirth, icon: Icons.cake_rounded),
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
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
                final now = DateTime.now();
                if (picked.isAfter(now)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Date of birth cannot be in the future")),
                  );
                  return;
                }
                final minAdultDate = DateTime(
                  now.year - 18,
                  now.month,
                  now.day,
                );

                if (picked.isAfter(minAdultDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.ageMustBeAtLeastEighteenYearsOld)),
                  );
                  selectedDate = null;
                  return;
                }
                setState(() => selectedDate = picked);
              }
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: _buildInputDecoration(
                  hintText: selectedDate != null
                      ? "${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}"
                      : "yyyy/mm/dd",
                  suffixIcon: Icon(Icons.calendar_today_rounded, color: NasColors.darkBlue),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          /// Religion
          _buildFieldLabel(local.religion, icon: Icons.auto_awesome_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: "-- ${local.selectReligion} --",
            ),
            value: religion,
            hint: Text("-- ${local.selectReligion} --"),
            items: [local.islam, local.christianity, local.hinduism, local.other]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              setState(() => religion = val);
            },
          ),
          const SizedBox(height: 14),

          /// Marital Status
          _buildFieldLabel(local.martialStatus, icon: Icons.family_restroom_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: "-- ${local.selectStatus} --",
            ),
            value: maritalStatus,
            hint: Text("-- ${local.selectStatus} --"),
            items: [local.single, local.married, local.divorced, local.widowed]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              setState(() => maritalStatus = val);
            },
          ),
          const SizedBox(height: 14),

          /// Username (Auto generated from first + last name)
          _buildFieldLabel(local.username, icon: Icons.alternate_email_rounded),
          TextField(
            controller: userName,
            readOnly: true,
            decoration: _buildInputDecoration(
              hintText: local.enterUsername,
            ),
          ),
          const SizedBox(height: 14),

          /// Password
          _buildFieldLabel(local.password, icon: Icons.lock_rounded),
          TextField(
            controller: password,
            obscureText: _obscurePassword,
            decoration: _buildInputDecoration(
              hintText: local.password,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: NasColors.icons,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          /// Degree Name
          _buildFieldLabel(local.degreeName, isRequired: false, icon: Icons.school_rounded),
          TextField(
            controller: degreeName,
            decoration: _buildInputDecoration(
              hintText: local.enterDegreeName,
            ),
          ),
          const SizedBox(height: 14),

          /// Degree Type
          _buildFieldLabel(local.degreeType, isRequired: false, icon: Icons.workspace_premium_rounded),
          TextField(
            controller: degreeType,
            decoration: _buildInputDecoration(
              hintText: local.enterDegreeType,
            ),
          ),
          const SizedBox(height: 18),

          /// Profile Picture Upload
          _buildFieldLabel(local.profilePicture, isRequired: false, icon: Icons.add_a_photo_rounded),
          Row(
            children: [
              if (profilePicUrl == null || profilePicUrl!.isEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NasColors.darkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );

                    if (result != null && result.files.single.path != null) {
                      PlatformFile file = result.files.single;
                      setState(() {
                        selectedFile = file;
                      });

                      await uploadProfileToS3(file);
                      setState(() {});
                    }
                  },
                  label: Text(local.chooseFile),
                )
              else
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        profilePicUrl!,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
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
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 12),
              if (profilePicUrl == null || profilePicUrl!.isEmpty)
                Expanded(
                  child: Text(
                    local.noFileChosen,
                    style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PAGE 3: Professional Information ──────────────────────────────────
  Widget _buildPage3(BuildContext context, AppLocalizations local) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildSectionCard(
        title: local.professionalInformation,
        icon: Icons.work_rounded,
        children: [
          /// Hierarchy Group
          _buildFieldLabel(local.hierarchyGroup, icon: Icons.admin_panel_settings_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: local.selectHierarchyGroup,
            ),
            value: hierarchyGroup,
            items: ["Admin", "Manager", "Supervisor", "Employee"]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              setState(() => hierarchyGroup = val);
            },
          ),
          const SizedBox(height: 16),

          /// Designation
          _buildFieldLabel(local.designation, icon: Icons.work_outline_rounded),
          TextField(
            controller: designation,
            decoration: _buildInputDecoration(
              hintText: local.enterDesignation,
            ),
          ),
          const SizedBox(height: 16),

          /// Role
          _buildFieldLabel(local.role, icon: Icons.badge_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: _buildInputDecoration(
              hintText: local.selectRole,
            ),
            value: role,
            items: [local.junior, local.mid, local.senior]
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
            onChanged: (val) {
              setState(() => role = val);
            },
          ),
          const SizedBox(height: 16),

          /// Contract Type
          _buildFieldLabel(local.contractType, icon: Icons.description_rounded),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: "Permanent",
                  activeColor: NasColors.darkBlue,
                  groupValue: contractType,
                  onChanged: (val) {
                    setState(() => contractType = val);
                  },
                ),
                Text(
                  local.permanent,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 24),
                Radio<String>(
                  value: "Temporary",
                  activeColor: NasColors.darkBlue,
                  groupValue: contractType,
                  onChanged: (val) {
                    setState(() => contractType = val);
                  },
                ),
                Text(
                  local.temporary,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          /// End of Contract (if Temporary)
          if (contractType == "Temporary") ...[
            _buildFieldLabel(local.endOfContract, icon: Icons.event_busy_rounded),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
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
                  setState(() => contractEndDate = picked);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: _buildInputDecoration(
                    hintText: contractEndDate != null
                        ? "${contractEndDate!.day}/${contractEndDate!.month}/${contractEndDate!.year}"
                        : "dd/mm/yyyy",
                    suffixIcon: Icon(Icons.calendar_today_rounded, color: NasColors.darkBlue),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── PAGE 4: Salary & Financial Information ─────────────────────────────
  Widget _buildPage4(BuildContext context, AppLocalizations local) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: _buildSectionCard(
        title: local.salaryInformation,
        icon: Icons.payments_rounded,
        children: [
          /// Basic Salary
          _buildFieldLabel(local.basicSalary, icon: Icons.attach_money_rounded),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: basicSalary,
            decoration: _buildInputDecoration(
              hintText: local.enterBasicSalary,
            ),
          ),
          const SizedBox(height: 14),

          /// Currency
          _buildFieldLabel(local.currency, icon: Icons.currency_exchange_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: currency,
            items: ["USD", "PKR", "SAR", "EUR"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() => currency = val);
            },
            decoration: _buildInputDecoration(
              hintText: local.selectCategory,
            ),
          ),
          const SizedBox(height: 14),

          /// Salary Period
          _buildFieldLabel(local.salaryPeriod, icon: Icons.calendar_month_rounded),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: salaryPeriod,
            items: ["Daily", "Weekly", "Monthly", "Hourly"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() => salaryPeriod = val);
            },
            decoration: _buildInputDecoration(
              hintText: local.selectSalaryPeriod,
            ),
          ),
          const SizedBox(height: 14),

          /// Bank Name
          _buildFieldLabel(local.bankName, icon: Icons.account_balance_rounded),
          TextField(
            controller: bankName,
            decoration: _buildInputDecoration(
              hintText: local.enterBankName,
            ),
          ),
          const SizedBox(height: 14),

          /// Account Number
          _buildFieldLabel(local.accountNo, icon: Icons.account_balance_wallet_rounded),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: accountNo,
            decoration: _buildInputDecoration(
              hintText: local.enterAccountNo,
            ),
          ),
          const SizedBox(height: 18),

          /// Allowances Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: NasColors.darkBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.add_card_rounded, color: NasColors.darkBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  local.allowance,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    allowanceExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: NasColors.darkBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      allowanceExpanded = !allowanceExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_rounded, color: NasColors.darkBlue),
                  onPressed: () {
                    setState(() {
                      allowances.add(AllowanceFormModel());
                      allowanceExpanded = true;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (allowanceExpanded) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allowances.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = allowances[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: NasColors.darkBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "#${index + 1}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (allowances.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  allowances.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildFieldLabel("${local.allowance} ${local.name}", isRequired: false),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: item.title,
                        decoration: _buildInputDecoration(
                          hintText: "${local.allowance} ${local.name}",
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFieldLabel("${local.allowance} ${local.type}", isRequired: false),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: item.type,
                        items: ["Fixed", "Variable"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => item.type = val);
                        },
                        decoration: _buildInputDecoration(
                          hintText: local.selectAllowanceType,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (item.type == "Variable") ...[
                        _buildFieldLabel(local.basedOn, isRequired: false),
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          value: item.basedOn,
                          items: ["Salary"]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => item.basedOn = val);
                          },
                          decoration: _buildInputDecoration(
                            hintText: local.selectOption,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFieldLabel(local.allowancePercentage, isRequired: false),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: item.percentage,
                          decoration: _buildInputDecoration(
                            hintText: local.enterPercentage,
                          ),
                        ),
                      ],
                      if (item.type == "Fixed") ...[
                        _buildFieldLabel(local.allowanceAmount, isRequired: false),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: item.amount,
                          decoration: _buildInputDecoration(
                            hintText: local.enterAmount,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 14),

          /// Deductions Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.remove_shopping_cart_rounded, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  local.deductions,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    deductionExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.red.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      deductionExpanded = !deductionExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_rounded, color: Colors.red.shade700),
                  onPressed: () {
                    setState(() {
                      deductions.add(DeductionFormModel());
                      deductionExpanded = true;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (deductionExpanded) ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deductions.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final item = deductions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "#${index + 1}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (deductions.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  deductions.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildFieldLabel("${local.deductions} ${local.name}", isRequired: false),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: item.title,
                        decoration: _buildInputDecoration(
                          hintText: "${local.deductions} ${local.name}",
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFieldLabel("${local.deductions} ${local.type}", isRequired: false),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: item.type,
                        items: ["Fixed", "Variable"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => item.type = val);
                        },
                        decoration: _buildInputDecoration(
                          hintText: local.selectDeductionType,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (item.type == "Variable") ...[
                        _buildFieldLabel(local.basedOn, isRequired: false),
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          value: item.basedOn,
                          items: ["Salary"]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => item.basedOn = val);
                          },
                          decoration: _buildInputDecoration(
                            hintText: local.selectOption,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFieldLabel(local.deductionPercentage, isRequired: false),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: item.percentage,
                          decoration: _buildInputDecoration(
                            hintText: local.enterPercentage,
                          ),
                        ),
                      ],
                      if (item.type == "Fixed") ...[
                        _buildFieldLabel(local.deductionAmount, isRequired: false),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: item.amount,
                          decoration: _buildInputDecoration(
                            hintText: local.enterAmount,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ],
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
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: NasColors.darkBlue, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: NasColors.darkBlue),
                    const SizedBox(width: 6),
                    Text(
                      "Back",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == 3) {
                  createEmployee();
                } else {
                  _nextPage();
                }
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == 3 ? "Submit" : "Next",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _currentPage == 3
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// S3 Bucket Call Method
  Future<String?> uploadProfileToS3(PlatformFile file) async {
    try {
      setState(() => isLoading = true);

      Uint8List fileBytes = file.bytes ?? await File(file.path!).readAsBytes();

      if (fileBytes.length > 1000000) {
        fileBytes = await FlutterImageCompress.compressWithList(
          fileBytes,
          minWidth: 1080,
          minHeight: 1080,
          quality: 70,
          format: CompressFormat.jpeg,
        );
      }

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

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final jsonRes = json.decode(responseBody);
        profilePicUrl = jsonRes['data']?['url'] ?? jsonRes['url'] ?? '';
      } else {
        return null;
      }
    } catch (e) {
      setState(() => isLoading = false);
      return null;
    }
    return null;
  }

  /// API CALL METHOD
  Future<void> createEmployee() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    String? organizationID = singletonClass.getJWTModel()?.organizationId;
    final List<Map<String, dynamic>> allowanceBenefits = (allowances.isEmpty)
        ? <Map<String, dynamic>>[]
        : allowances.map((e) {
            return {
              "allowanceTitle": e.title.text,
              "allowanceType": (e.type ?? "").toUpperCase(),
              "basedOn": e.type == "Variable" ? "Salary" : "",
              "amount": e.type == "Fixed"
                  ? e.amount.text
                  : calculatePercentageAmount(
                      baseSalary: basicSalary.text,
                      percentage: e.percentage.text,
                    ),
            };
          }).toList();

    final List<Map<String, dynamic>> deductionList = (deductions.isEmpty)
        ? <Map<String, dynamic>>[]
        : deductions.map((e) {
            return {
              "deductionTitle": e.title.text,
              "deductionType": (e.type ?? "").toUpperCase(),
              "basedOn": e.type == "Variable" ? "Salary" : "",
              "amount": e.type == "Fixed"
                  ? e.amount.text
                  : calculatePercentageAmount(
                      baseSalary: basicSalary.text,
                      percentage: e.percentage.text,
                    ),
            };
          }).toList();

    final Map<String, dynamic> data = {
      "userName": userName.text.isNotEmpty ? userName.text : "",
      "password": password.text.isNotEmpty ? password.text : "",
      "email": [
        {
          "personalEmail":
              emailController.text.isNotEmpty ? emailController.text : "",
          "workEmail":
              emailController.text.isNotEmpty ? emailController.text : "",
        }
      ],
      "firstName":
          firstNameController.text.isNotEmpty ? firstNameController.text : "",
      "middleName": "",
      "lastName":
          lastNameController.text.isNotEmpty ? lastNameController.text : "",
      "branchId": selectedBranchId ?? "",
      "martialStatus": (maritalStatus?.toString() ?? ""),
      "religion": (religion?.toString() ?? ""),
      "address": {
        "streetAddress":
            addressController.text.isNotEmpty ? addressController.text : "",
        "city": "",
        "country": nationality?.toString() ?? "",
      },
      "NIC": nationalIdController.text.isNotEmpty
          ? nationalIdController.text
          : "",
      "iqamaNumber": {
        "id": iqamaController.text.isNotEmpty ? iqamaController.text : "",
        "issueDate": "",
        "expiryDate": ""
      },
      "passport": {"id": "", "issueDate": "", "expiryDate": ""},
      "imigrationSatus": "foreigner",
      "DOB": selectedDate != null
          ? selectedDate!.toIso8601String().split('T').first
          : "",
      "age": selectedDate != null ? _calculateAge(selectedDate.toString()) : "",
      "phoneNumber": [
        {
          "mobileNumber":
              phoneController.text.isNotEmpty ? phoneController.text : "",
          "landlineNumber":
              phoneController.text.isNotEmpty ? phoneController.text : "",
        }
      ],
      "gender": gender?.toString() ?? "",
      "role": role?.toString() ?? "",
      "profession": "",
      "nationality": nationality?.toString() ?? "",
      "profilePic": profilePicUrl ?? "",
      "familyInfo": {
        "fatherName": "",
        "motherName": "",
        "familyAddress": {"streetAddress": "", "city": "", "country": ""},
        "familyContactNumber": "",
        "emergencyContactInfo": [
          {
            "relationName": "",
            "relationType": "",
            "relationContactNumber": "",
            "relationAddress": ""
          }
        ]
      },
      "educationInfo": [
        {
          "degreeName": degreeName.text.isNotEmpty ? degreeName.text : "",
          "degreeType": degreeType.text.isNotEmpty ? degreeType.text : "",
          "fieldofStudy": "",
          "institute": "",
          "from": "",
          "to": "",
          "results": ""
        }
      ],
      "experienceBackground": [],
      "bankingInfo": [
        {
          "title": bankName.text.isNotEmpty ? bankName.text : "",
          "accountNumber": accountNo.text.isNotEmpty ? accountNo.text : "",
          "branchCode": "",
          "accountType": "",
          "country": "",
          "empSwiftCode": "",
          "bankName": "",
        }
      ],
      "employeeInfo": [
        {
          "depId": selectedDepartmentId ?? "",
          "depName": selectedDepartment ?? "",
          "jobTitle": "",
          "jobDescription": "",
          "reportingManager": selectedSupervisorId ?? "",
          "jobRank": "",
          "designation": designation.text.isNotEmpty ? designation.text : "",
          "grade": hierarchyGroup == "Admin"
              ? "L1"
              : hierarchyGroup == "Manager"
                  ? "L2"
                  : hierarchyGroup == "Supervisor"
                      ? "L3"
                      : hierarchyGroup == "Employee"
                          ? "L4"
                          : "",
          "workDomain": "",
          "location": selectedBranch?.toString() ?? "",
          "employeeStatus": "Active",
          "employeeType": "",
          "employeeShift": selectedShiftId ?? "",
          "joiningDate": today,
          "leavingDate": "",
          "hiringDate": today,
          "noticePeriod": "",
          "empSignature": ""
        }
      ],
      "salaryInfo": {
        "baseSalary": basicSalary.text.isNotEmpty ? basicSalary.text : "",
        "currency": currency?.toString() ?? "",
        "timeCycle_Period": salaryPeriod?.toString() ?? "",
        "allowance_Benefits": allowanceBenefits,
        "deductions": deductionList,
        "taxInfo": {
          "taxPercentage": "",
          "deductableAmount": "",
          "timeCycle": ""
        },
        "allowanceContribution": "",
        "netSalary": ""
      },
      "shiftInfo": {
        "shiftId": selectedShiftId?.toString() ?? "",
        "shiftType": selectedShiftType?.toString() ?? "",
        "shiftName": selectedShift?.toString() ?? "",
        "timeFrom": selectedShiftFrom?.toString() ?? "",
        "timeTo": selectedShiftTo?.toString() ?? "",
      },
      "socialLinks": [],
      "loanInfo": [],
      "assetsInfo": [],
      "remoteLocation": {
        "isRemoteAttendance": "",
        "remoteAttendanceLoc": "",
        "lastLocation": "",
        "lastLocationUpdatedAt": ""
      },
      "contractInfo": [
        {
          "contractId": "",
          "contractStatus": "",
          "contractType": contractType?.toString() ?? "",
          "contractStartDate": today,
          "contractExpiry": contractEndDate != null
              ? contractEndDate!.toIso8601String().split('T').first
              : "",
          "probabtionStartDate": "",
          "probationPeriod": "",
          "probationstatus": ""
        }
      ],
      "documentsInfo": [],
      "createdBy": singletonClass.getJWTModel()?.empId ?? "",
    };

    String body = json.encode(data);
    log("JSON DATA $body");
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
                fromTeamScreen: false,
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
    }
  }

  /// Helper method
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

  String calculatePercentageAmount({
    required String baseSalary,
    required String percentage,
  }) {
    final double salary = double.tryParse(baseSalary) ?? 0;
    final double percent = double.tryParse(percentage) ?? 0;

    final double amount = (salary * percent) / 100;
    return amount.toStringAsFixed(2);
  }
}

/// Static Models
class AllowanceFormModel {
  final TextEditingController title = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController percentage = TextEditingController();

  String? type;
  String? basedOn;
}

class DeductionFormModel {
  final TextEditingController title = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController percentage = TextEditingController();

  String? type;
  String? basedOn;
}
