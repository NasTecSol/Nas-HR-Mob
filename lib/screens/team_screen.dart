import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/employee_profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/branch_model.dart';

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
  List<Teams> filteredUnderTeams = [];
  bool _isTeamChecked = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initData();
    teamCheck();
  }

   void teamCheck(){
    if (singletonClass.branchID != null && singletonClass.branchID!.isNotEmpty  ){
      _isTeamChecked = false;
      _selectedOptionIndex = 2;
    }
   }
  Future<void> initData() async {
    setState(() {
      isLoading = true;
    });

    await singletonClass.getBranchData();
    await singletonClass.getTeamBranchData();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';

    final branchDataList = singletonClass.branchDataList;
    final filteredData = getFilteredTeams(branchDataList, reportingManagerId!);

    setState(() {
      filteredTeams = filteredData['ownTeams']!;
      filteredUnderTeams = filteredData['underTeams']!;
      isLoading = false;
    });
  }

  Map<String, List<Teams>> getFilteredTeams(
      List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> ownTeams = [];
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;

    if (kDebugMode) {
      print('Branch Data List length: ${branchDataList.length}');
      print('Reporting Manager ID: $reportingManagerId');
    }
    if (_isTeamChecked == false && singletonClass.branchID != null) {
      List<TeamData> allEmployees = [];

      final teamBranchData = singletonClass.teamBranchDataList.isNotEmpty
          ? singletonClass.teamBranchDataList.first.data
          : null;

      if (teamBranchData != null) {
        for (var emp in teamBranchData.employees ?? []) {
          allEmployees.add(TeamData(
            empId: emp.employeeInfo?.isNotEmpty == true
                ? emp.employeeInfo!.first.empId ?? ''
                : '',
            employeeId: emp.id ?? '',
            userName: emp.userName ?? '',
            designation: emp.employeeInfo?.isNotEmpty == true
                ? emp.employeeInfo!.first.designation ?? ''
                : '',
            grade: emp.employeeInfo?.isNotEmpty == true
                ? emp.employeeInfo!.first.grade ?? ''
                : '',
          ));
        }
      }

      if (allEmployees.isNotEmpty) {
        ownTeams.add(Teams(
          teamId: 'All_Employees',
          teamData: allEmployees,
        ));
      }

      return {
        'ownTeams': ownTeams,
        'underTeams': [],
      };
    } else {
      for (BranchData branchData in branchDataList) {
        for (var departmentDetails
        in branchData.data?.branch?.departmentDetails ?? []) {
          for (var department in departmentDetails.departments ?? []) {
            final supervisors = department.supervisors ?? [];
            final teams = department.teams ?? [];
            if (["L0", "L1", "L2", "L3"].contains(userGrade)) {
              bool isUserSupervisorInDepartment =
              supervisors.any((s) => s.empId == reportingManagerId);
              if (isUserSupervisorInDepartment) {
                if (kDebugMode) {
                  print('✅ User is a supervisor in this department');
                }
                ownTeams.add(
                  Teams(
                    teamId:
                    'Supervisors_${DateTime.now().millisecondsSinceEpoch}',
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
                for (var supervisor in department.supervisors ?? []) {
                  if (supervisor.empId == reportingManagerId) {
                    for (var team in teams) {
                      if (supervisor.teamId == team.teamId) {
                        if (kDebugMode) {
                          print('Adding subordinate team to underTeams based on supervisor empId and teamId match: ${team.teamId}');
                        }
                        underTeams.add(team);
                      }
                    }
                  }
                }
              }
            } else if (userGrade == "L4") {
              for (var team in teams) {
                bool isUserInTeam = team.teamData
                    ?.any((member) => member.empId == reportingManagerId) ??
                    false;
                if (isUserInTeam) {
                  if (kDebugMode) {
                    print(
                        '👤 User is team member of ${team.teamId}, adding to ownTeams');
                  }
                  ownTeams.add(team);
                }
              }
            }
          }
        }
      }
      return {
        'ownTeams': ownTeams,
        'underTeams': underTeams,
      };
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IconButton(
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
                            color: Colors.grey.withValues(alpha: 0.4),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Text(
                    AppLocalizations.of(context)!.teams,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 50,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          isSearching = true;
                        });
                      },
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: '${AppLocalizations.of(context)!.search}...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.search,
                    color: NasColors.darkBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (singletonClass.getJWTModel()?.grade == "L0" ||
                singletonClass.getJWTModel()?.grade == "L1" ||
                singletonClass.getJWTModel()?.grade == "L2") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onSelected: (value) async {
                        setState(() {
                          setState(() => isLoading = true);
                          filteredTeams.clear();
                          singletonClass.teamBranchDataList.clear();
                          singletonClass.branchID = value;
                          final branch = singletonClass.branchesDataList.first.data?.firstWhere((branch) => branch.branchCompanyId == value);
                          singletonClass.branchName = branch?.branchName ?? "Unknown Branch";
                          if (kDebugMode) {
                            print('Selected Branch ID: $value');
                          }
                          _isTeamChecked = false;
                          _selectedOptionIndex = 2;
                          singletonClass.getBranchData();
                        });
                        await initData();
                      },
                      itemBuilder: (context) {
                        final branchList = singletonClass.branchesDataList.first.data ?? [];
                        return branchList.map((branch) {
                          return PopupMenuItem<String>(
                            value: branch.branchCompanyId,
                            child: Text(branch.branchName ?? "Unknown Branch"),
                          );
                        }).toList();
                      },
                      child: Container(
                        height: 60,
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_city, size: 18),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                singletonClass.branchName ??
                                    singletonClass.branchDataList.first.data!.branch!.branchName,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Checkbox(
                          value: _isTeamChecked,
                          activeColor: NasColors.onTime,
                          onChanged: (singletonClass.branchID != null)
                              ? (bool? value) async {
                                  setState(() {
                                    setState(() => isLoading = true);
                                    _isTeamChecked = value ?? false;
                                    singletonClass.branchID = null;
                                    singletonClass.branchName = null;
                                    _selectedOptionIndex = 0;
                                  });
                                  await initData();
                                }
                              : null),
                      Text(
                        AppLocalizations.of(context)!.teams,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue),
                      ),
                    ],
                  ),
                ],
              ),],
              SizedBox(height: 5),
            if (singletonClass.getJWTModel()?.grade == "L0" ||
                singletonClass.getJWTModel()?.grade == "L1" ||
                singletonClass.getJWTModel()?.grade == "L2" ||
                singletonClass.getJWTModel()?.grade == "L3")...[
              Row(
                children: [
                  if(_isTeamChecked == true && singletonClass.branchID == null)...[
                    buildOptionsCard(0, AppLocalizations.of(context)!.teamMates),
                    buildOptionsCard(1, AppLocalizations.of(context)!.myTeams),
                  ],
                  if(_isTeamChecked == false && singletonClass.branchID != null)...[
                    buildOptionsCard(2, AppLocalizations.of(context)!.allEmployees),
                  ]
                ],
              ),

              if (_selectedOptionIndex == 0) ...[
                if (isLoading)
                  Expanded(
                      child: Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'),
                        ),
                      ))
                else ...[
                  (filteredTeams.isEmpty ||
                      (filteredTeams.first.teamData?.where((member) => member.employeeId != singletonClass.getJWTModel()?.employeeId).isEmpty ?? true))
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/empty.json'),
                          ),
                          Text(
                            AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: filteredTeams.first.teamData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = filteredTeams.first.teamData![index];
                        String imageUrl = images[index % images.length];
                        if (singletonClass.getJWTModel()?.employeeId == team.employeeId) {
                          return SizedBox.shrink();
                        }
                        final searchText = searchController.text.toLowerCase();
                        if (isSearching && !(team.userName?.toLowerCase().contains(searchText) ?? false)) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EmployeeProfileScreen(
                                          teamData: team,
                                          isTeamMate: false,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4),
                                decoration: BoxDecoration(
                                  color: NasColors.containerColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${team.userName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          SizedBox(
                                            width:270,
                                            child: Text(
                                              "${team.designation}",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ],
              if (_selectedOptionIndex == 1) ...[
                if (isLoading)
                  Expanded(
                      child: Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'),
                        ),
                      ))
                else ...[
                  filteredUnderTeams.first.teamData!.isNotEmpty
                      ? Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount:
                      filteredUnderTeams.first.teamData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team =
                        filteredUnderTeams.first.teamData![index];
                        String imageUrl = images[index % images.length];
                        if (singletonClass.getJWTModel()?.employeeId ==
                            team.employeeId) {
                          return SizedBox.shrink();
                        }
                        final searchText =
                        searchController.text.toLowerCase();
                        if (isSearching &&
                            !(team.userName
                                ?.toLowerCase()
                                .contains(searchText) ??
                                false)) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EmployeeProfileScreen(
                                          teamData: team,
                                          isTeamMate: true,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4),
                                decoration: BoxDecoration(
                                  color: NasColors.containerColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${team.userName}",
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: NasColors.darkBlue,
                                              ),
                                            ),
                                            SizedBox(
                                              width:270,
                                              child: Text(
                                                "${team.designation}",
                                                maxLines: 2,
                                                softWrap: true,
                                                overflow:
                                                TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ],
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/empty.json'),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (_selectedOptionIndex == 2) ...[
                if (isLoading)
                  Expanded(
                      child: Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset('images/loader.json'),
                        ),
                      ))
                else ...[
                  filteredTeams.first.teamData!.isNotEmpty
                      ? Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: filteredTeams.first.teamData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = filteredTeams.first.teamData![index];
                        String imageUrl = images[index % images.length];
                        if (singletonClass.getJWTModel()?.employeeId == team.employeeId) {
                          return SizedBox.shrink();
                        }
                        final searchText = searchController.text.toLowerCase();
                        if (isSearching && !(team.userName?.toLowerCase().contains(searchText) ?? false)) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EmployeeProfileScreen(
                                          teamData: team,
                                          isTeamMate: true,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4),
                                decoration: BoxDecoration(
                                  color: NasColors.containerColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${team.userName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 270,
                                            child: Text(
                                              "${team.designation}",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ],
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/empty.json'),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
            if (singletonClass.getJWTModel()?.grade == "L4") ...[
              if (isLoading)
                Expanded(
                    child: Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset('images/loader.json'),
                  ),
                ))
              else ...[
                filteredTeams.first.teamData!.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5),
                          itemCount: filteredTeams.first.teamData!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final team = filteredTeams.first.teamData![index];
                            String imageUrl = images[index % images.length];
                            if (singletonClass.getJWTModel()?.employeeId ==
                                team.employeeId) {
                              return SizedBox.shrink();
                            }
                            final searchText =
                                searchController.text.toLowerCase();
                            if (isSearching &&
                                !(team.userName
                                        ?.toLowerCase()
                                        .contains(searchText) ??
                                    false)) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeProfileScreen(
                                          teamData: team,
                                          isTeamMate: false,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: NasColors.containerColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${team.userName}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue,
                                                ),
                                              ),
                                              SizedBox(
                                                width:270,
                                                child: Text(
                                                  "${team.designation}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey[300],
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Lottie.asset('images/empty.json'),
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.noData,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ]
            ]
          ],
        ),
      ),
    );
  }

  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
          searchController.clear();
        });
      },
      child: SizedBox(
        height: 65,
        width: 160,
        child: Card(
          color:
              _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color:
                  _selectedOptionIndex == index ? Colors.white : Colors.white,
              width: 0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : NasColors.darkBlue,
                ),
              ),
              SizedBox(width: 10),
              if(index == 0)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '${filteredTeams.isNotEmpty && filteredTeams.first.teamData != null ? filteredTeams.first.teamData!.length -1: 0}', // Request List Notification count
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if(index == 1)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${filteredUnderTeams.isNotEmpty && filteredUnderTeams.first.teamData != null ? filteredUnderTeams.first.teamData!.length: 0}', // Request List Notification count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if(index == 2)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${filteredTeams.isNotEmpty && filteredTeams.first.teamData != null ? filteredTeams.first.teamData!.length: 0}', // Request List Notification count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
