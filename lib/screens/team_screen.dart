import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/team_model.dart';
import 'package:nashr/screens/employee_profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/branch_model.dart';
import '../widgets/loader.dart';
import 'branch_employee_profile_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  SingletonClass singletonClass = SingletonClass();

  bool isSearching = false;
  bool isTeamMate = false;
  TextEditingController searchController = TextEditingController();
  final List<String> images = [
    "https://img.freepik.com/premium-photo/happy-fashionable-handsome-man_739685-5867.jpg?w=740",
    "https://img.freepik.com/premium-photo/smiling-businessman-formal-wear-using-tablet-while-standing-rooftop_1289061-391.jpg?w=740",
    "https://img.freepik.com/premium-vector/man-suit-tie-is-smiling-looking-camera_697880-29692.jpg?w=740",
    "https://img.freepik.com/free-photo/confident-handsome-guy-posing-against-white-wall_176420-32936.jpg?t=st=1723452897~exp=1723456497~hmac=d1063ee18ade6b4f24d492b93758d241342ffeca0abc0759b44bfe7a0986bb4c&w=996",
    "https://img.freepik.com/free-psd/flat-man-character_23-2151534197.jpg?w=740&t=st=1723453930~exp=1723454530~hmac=f047b2fdb91350768e41906694186ffddadcde4b49b6d55de3083dfb18cbe3e3",
  ];
  int _selectedOptionIndex = 0;
  String? reportingManagerId;
  List<Teams> filteredTeams = [];
  List<Employees> filteredBranchTeams = [];
  List<Teams> filteredUnderTeams = [];

  bool _isTeamChecked = false;
  bool showDropdown = false;
  bool showTeamCheckbox = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void teamCheck() {
    final teamModule = singletonClass.roleAndAccessModelDataList.first.data!.uiSettings!.uiModules!
        .firstWhere((e) => (e.title == "Teams" || e.name == "Teams"));

    final employeeManagementMenu = teamModule.subMenu!.firstWhere((submenu) =>
    submenu.title == "Employee Management" ||
        submenu.name == "Employee Management");

    final access = employeeManagementMenu.accessLevel;
    final companies = access?.companies ?? [];

    final hasValidCompanies = companies.isNotEmpty &&
        companies.any((c) => c.companyId != null && c.companyId!.isNotEmpty);

    final hasValidBranches = hasValidCompanies &&
        companies.any((c) =>
        c.branches != null &&
            c.branches!.isNotEmpty &&
            c.branches!.any((b) => b.branchId != null && b.branchId!.isNotEmpty));

    final teamEnabled = access?.team == true;
    final hasBranchId = singletonClass.branchID != null && singletonClass.branchID!.isNotEmpty;

    showDropdown = false;
    showTeamCheckbox = false;
    _isTeamChecked = false;

    if (singletonClass.getJWTModel()?.grade == "L0" ||
        singletonClass.getJWTModel()?.grade == "L1" ||
        singletonClass.getJWTModel()?.grade == "L2" ||
        singletonClass.getJWTModel()?.grade == "L3") {
      if (hasValidCompanies && hasValidBranches && teamEnabled) {
        showDropdown = true;
        showTeamCheckbox = true;

        if (hasBranchId) {
          _isTeamChecked = false;
          _selectedOptionIndex = 2;
        } else {
          _isTeamChecked = true;
          _selectedOptionIndex = 0;
        }
      }
      else if (hasValidCompanies && hasValidBranches && !teamEnabled) {
        showDropdown = true;
        showTeamCheckbox = false;
        _isTeamChecked = false;
        _selectedOptionIndex = 2;
      }
      else if (!hasValidCompanies && teamEnabled) {
        showDropdown = false;
        showTeamCheckbox = true;
        _isTeamChecked = true;
        _selectedOptionIndex = 0;
      }
      else {
        showDropdown = false;
        showTeamCheckbox = false;
        _isTeamChecked = false;
        _selectedOptionIndex = 2;
      }
    } else {
      showDropdown = false;
      showTeamCheckbox = false;
      _isTeamChecked = false;
    }

    if (kDebugMode) {
      print("✅ Access check: hasValidCompanies=$hasValidCompanies | hasValidBranches=$hasValidBranches | teamEnabled=$teamEnabled");
      print("✅ UI State: showDropdown=$showDropdown | showTeamCheckbox=$showTeamCheckbox | _isTeamChecked=$_isTeamChecked | _selectedOptionIndex=$_selectedOptionIndex");
    }
  }

  Future<void> initData() async {
    setState(() {
      isLoading = true;
    });

    await singletonClass.getBranchData();
    await singletonClass.getTeamBranchData();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';

    teamCheck();

    if (singletonClass.getJWTModel()?.grade == "L0" ||
        singletonClass.getJWTModel()?.grade == "L1" ||
        singletonClass.getJWTModel()?.grade == "L2" ||
        singletonClass.getJWTModel()?.grade == "L3") {

      if (_isTeamChecked == false && singletonClass.branchID != null && singletonClass.branchID!.isNotEmpty) {
        final data = _getBranchEmployees();
        setState(() {
          filteredBranchTeams = data['ownTeams']!;
          filteredTeams = [];
          filteredUnderTeams = [];
        });
      } else if (_isTeamChecked == true) {
        final branchDataList = singletonClass.branchDataList;
        final data = getFilteredTeams(branchDataList, reportingManagerId!);
        setState(() {
          filteredBranchTeams = [];
          filteredTeams = data['ownTeams']!;
          filteredUnderTeams = data['underTeams']!;
        });
      } else {
        setState(() {
          filteredBranchTeams = [];
          filteredTeams = [];
          filteredUnderTeams = [];
        });
      }
    } else {
      final branchDataList = singletonClass.branchDataList;
      final data = getFilteredTeams(branchDataList, reportingManagerId!);
      setState(() {
        filteredBranchTeams = [];
        filteredTeams = data['ownTeams']!;
        filteredUnderTeams = data['underTeams']!;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Map<String, List<Employees>> _getBranchEmployees() {
    List<Employees> branchTeams = [];
    final branchData = singletonClass.teamBranchDataList.first;
    List<Employees> employees = [];

    for (var emp in branchData.data?.employees ?? []) {
      employees.add(emp);
    }

    if (employees.isNotEmpty) {
      branchTeams.addAll(employees);
    }

    return {'ownTeams': branchTeams, 'underTeams': []};
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> ownTeams = [];
    List<Teams> underTeams = [];

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data?.branch?.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          final supervisors = department.supervisors ?? [];
          final teams = department.teams ?? [];

          bool isSupervisor = supervisors.any((s) => s.empId == reportingManagerId);
          if (isSupervisor) {
            ownTeams.add(
              Teams(
                teamId: 'Supervisors_${DateTime.now().millisecondsSinceEpoch}',
                teamData: supervisors.map<TeamData>((supervisor) {
                  return TeamData(
                    empId: supervisor.empId,
                    employeeId: supervisor.employeeId,
                    userName: supervisor.userName,
                    designation: supervisor.designation,
                    grade: supervisor.grade,
                  );
                }).toList(),
              ),
            );

            for (var supervisor in supervisors) {
              if (supervisor.empId == reportingManagerId) {
                for (var team in teams) {
                  if (supervisor.teamId == team.teamId) {
                    underTeams.add(team);
                  }
                }
              }
            }
          } else {
            for (var team in teams) {
              bool isMember = team.teamData
                      ?.any((member) => member.empId == reportingManagerId) ??
                  false;
              if (isMember) {
                ownTeams.add(team);
              }
            }
          }
        }
      }
    }

    return {'ownTeams': ownTeams, 'underTeams': underTeams};
  }

  // ══════════════════════════════════════════════════════════════════
  // UI BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isManagerGrade = (singletonClass.getJWTModel()?.grade == "L0" ||
        singletonClass.getJWTModel()?.grade == "L1" ||
        singletonClass.getJWTModel()?.grade == "L2" ||
        singletonClass.getJWTModel()?.grade == "L3");

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (isManagerGrade) ...[
                        _buildBranchAndTeamControls(context),
                        const SizedBox(height: 12),
                        _buildOptionsRow(context),
                        const SizedBox(height: 12),
                      ] else ...[
                        const SizedBox(height: 16),
                        _buildOptionsRow(context),
                        const SizedBox(height: 12),
                      ],
                      Expanded(
                        child: _buildMemberList(context),
                      ),
                    ],
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

  // ── Header Widget (Non-scrollable, Gradient Header) ────────────────────────
  Widget _buildHeader(BuildContext context) {
    final isManagerGrade = (singletonClass.getJWTModel()?.grade == "L0" ||
        singletonClass.getJWTModel()?.grade == "L1" ||
        singletonClass.getJWTModel()?.grade == "L2" ||
        singletonClass.getJWTModel()?.grade == "L3");

    final int nonManagerCount = (filteredTeams.isNotEmpty && filteredTeams.first.teamData != null)
        ? filteredTeams.first.teamData!.length
        : 0;

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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (Back button + Screen Title)
              Row(
                children: [
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    AppLocalizations.of(context)!.teams,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!isManagerGrade) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: Text(
                        '$nonManagerCount',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // Embedded Search Field
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: NasColors.darkBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            isSearching = value.isNotEmpty;
                          });
                        },
                        style: GoogleFonts.inter(fontSize: 14, color: NasColors.darkBlue),
                        cursorColor: NasColors.darkBlue,
                        decoration: InputDecoration(
                          hintText: '${AppLocalizations.of(context)!.search}...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                            isSearching = false;
                          });
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Branch Selector & Teams Checkbox Bar ─────────────────────────────────
  Widget _buildBranchAndTeamControls(BuildContext context) {
    if (!showDropdown && !showTeamCheckbox) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showDropdown)
            PopupMenuButton<String>(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) async {
                setState(() {
                  isLoading = true;
                  filteredTeams.clear();
                  singletonClass.teamBranchDataList.clear();
                  singletonClass.branchID = value;
                  final selectedBranch = singletonClass.availableBranches
                      .firstWhere((branch) => branch.branchId.toString() == value);
                  singletonClass.branchName = selectedBranch.branchName ?? '';
                  if (kDebugMode) {
                    print('Selected Branch ID: $value');
                  }
                  _isTeamChecked = false;
                  _selectedOptionIndex = 2;
                  singletonClass.getTeamBranchData();
                });
                await initData();
              },
              itemBuilder: (BuildContext context) {
                final branchList = singletonClass.availableBranches.isNotEmpty
                    ? singletonClass.availableBranches
                    : [];
                if (branchList.isEmpty) return [];

                return branchList.map((branch) => PopupMenuItem<String>(
                  value: branch.branchId,
                  child: Text(
                    branch.branchName ?? "---",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                  ),
                )).toList();
              },
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_city_rounded, size: 18, color: NasColors.darkBlue),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Text(
                        singletonClass.branchName ??
                            (singletonClass.branchDataList.isNotEmpty
                                ? singletonClass.branchDataList.first.data!.branch!.branchName
                                : 'Select Branch'),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: NasColors.darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: NasColors.darkBlue),
                  ],
                ),
              ),
            ),
          if (showTeamCheckbox)
            Row(
              children: [
                Checkbox(
                  value: _isTeamChecked,
                  activeColor: NasColors.darkBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (singletonClass.branchID != null)
                      ? (bool? value) async {
                          setState(() {
                            isLoading = true;
                            _isTeamChecked = value ?? false;
                            singletonClass.branchID = null;
                            singletonClass.branchName = null;
                            _selectedOptionIndex = 0;
                          });
                          await initData();
                        }
                      : null,
                ),
                Text(
                  AppLocalizations.of(context)!.teams,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Filter Options Row ("Team Mates", "My Teams", "All Employees") ───────
  Widget _buildOptionsRow(BuildContext context) {
    final isManagerGrade = (singletonClass.getJWTModel()?.grade == "L0" ||
        singletonClass.getJWTModel()?.grade == "L1" ||
        singletonClass.getJWTModel()?.grade == "L2" ||
        singletonClass.getJWTModel()?.grade == "L3");

    if (isManagerGrade) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_isTeamChecked == true &&
                (singletonClass.branchID == null || singletonClass.branchID!.isEmpty)) ...[
              buildOptionsCard(0, AppLocalizations.of(context)!.teamMates),
              buildOptionsCard(1, AppLocalizations.of(context)!.myTeams),
            ],
            if (_isTeamChecked == false &&
                singletonClass.branchID != null &&
                singletonClass.branchID!.isNotEmpty) ...[
              buildOptionsCard(2, AppLocalizations.of(context)!.allEmployees),
            ],
          ],
        ),
      );
    } else {
      return Row(
        children: [
          buildOptionsCard(0, AppLocalizations.of(context)!.teamMates),
        ],
      );
    }
  }

  // ── Option Card Tab ───────────────────────────────────────────────────────
  Widget buildOptionsCard(int index, String title) {
    final bool isSelected = _selectedOptionIndex == index;
    int count = 0;

    if (index == 0) {
      count = (filteredTeams.isNotEmpty && filteredTeams.first.teamData != null)
          ? filteredTeams.first.teamData!.length
          : 0;
    } else if (index == 1) {
      count = (filteredUnderTeams.isNotEmpty && filteredUnderTeams.first.teamData != null)
          ? filteredUnderTeams.first.teamData!.length
          : 0;
    } else if (index == 2) {
      count = filteredBranchTeams.where((team) =>
          team.employeeInfo != null &&
          team.employeeInfo!.first.employeeStatus?.toLowerCase() == "active"
      ).length;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
          searchController.clear();
          isSearching = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [NasColors.darkBlue, NasColors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? NasColors.darkBlue.withOpacity(0.25)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : NasColors.darkBlue,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : NasColors.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : NasColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Member List Switcher ──────────────────────────────────────────────────
  Widget _buildMemberList(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    if (_selectedOptionIndex == 0) {
      final bool isEmpty = filteredTeams.isEmpty ||
          (filteredTeams.first.teamData
                  ?.where((member) =>
                      member.employeeId != singletonClass.getJWTModel()?.employeeId)
                  .isEmpty ??
              true);

      if (isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: filteredTeams.first.teamData!.length,
        itemBuilder: (context, index) {
          final team = filteredTeams.first.teamData![index];
          return _buildTeamMemberTile(
            team: team,
            index: index,
            isUnderTeam: false,
          );
        },
      );
    }

    if (_selectedOptionIndex == 1) {
      final bool isEmpty = filteredUnderTeams.isEmpty ||
          (filteredUnderTeams.first.teamData == null ||
              filteredUnderTeams.first.teamData!.isEmpty);

      if (isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: filteredUnderTeams.first.teamData!.length,
        itemBuilder: (context, index) {
          final team = filteredUnderTeams.first.teamData![index];
          return _buildTeamMemberTile(
            team: team,
            index: index,
            isUnderTeam: true,
          );
        },
      );
    }

    if (_selectedOptionIndex == 2) {
      if (filteredBranchTeams.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        itemCount: filteredBranchTeams.length,
        itemBuilder: (context, index) {
          final team = filteredBranchTeams[index];
          return _buildBranchMemberTile(team: team);
        },
      );
    }

    return const SizedBox.shrink();
  }

  // ── Member Tile (Teams & UnderTeams) ──────────────────────────────────────
  Widget _buildTeamMemberTile({
    required TeamData team,
    required int index,
    required bool isUnderTeam,
  }) {
    if (singletonClass.getJWTModel()?.employeeId == team.employeeId) {
      return const SizedBox.shrink();
    }

    final searchText = searchController.text.toLowerCase();
    if (isSearching && searchText.isNotEmpty) {
      final matchesName = team.userName?.toLowerCase().contains(searchText) ?? false;
      final matchesId = team.empId?.toLowerCase().contains(searchText) ?? false;
      if (!matchesName && !matchesId) {
        return const SizedBox.shrink();
      }
    }

    String imageUrl = images[index % images.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeProfileScreen(
                  teamData: team,
                  isTeamMate: isUnderTeam,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: NasColors.lightBlue.withOpacity(0.3), width: 1.5),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.userName ?? '---',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        team.designation ?? '---',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: NasColors.darkBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: NasColors.darkBlue,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Branch Member Tile ────────────────────────────────────────────────────
  Widget _buildBranchMemberTile({
    required Employees team,
  }) {
    if (singletonClass.getJWTModel()?.employeeId == team.id ||
        (team.employeeInfo != null &&
            team.employeeInfo!.isNotEmpty &&
            team.employeeInfo!.first.employeeStatus?.toLowerCase() == 'suspended')) {
      return const SizedBox.shrink();
    }

    final searchText = searchController.text.toLowerCase();
    if (isSearching && searchText.isNotEmpty) {
      final matchesName = team.userName?.toLowerCase().contains(searchText) ?? false;
      final matchesId = (team.employeeInfo != null && team.employeeInfo!.isNotEmpty)
          ? (team.employeeInfo!.first.empId?.toLowerCase().contains(searchText) ?? false)
          : false;

      if (!matchesName && !matchesId) {
        return const SizedBox.shrink();
      }
    }

    final hasPic = !(team.profilePic == "https://www.profilePic.com" ||
        team.profilePic == null ||
        team.profilePic!.isEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BranchEmployeeProfileScreen(
                  employees: team,
                  isTeamMate: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                hasPic
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: NasColors.lightBlue.withOpacity(0.3), width: 1.5),
                          image: DecorationImage(
                            image: NetworkImage(team.profilePic!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipOval(
                        child: Image.asset(
                          'images/DP.png',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              team.userName ?? '---',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ),
                          if (team.employeeInfo != null && team.employeeInfo!.isNotEmpty)
                            Text(
                              "${team.employeeInfo!.first.empId}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (team.employeeInfo != null && team.employeeInfo!.isNotEmpty)
                        Text(
                          "${team.employeeInfo!.first.designation}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: NasColors.darkBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: NasColors.darkBlue,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset('images/empty.json'),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.noData,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NasColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
