import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/employee_profile_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../request_controller/branch_model.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  SingletonClass singletonClass = SingletonClass();
  List<TeamModel> teams = [
    TeamModel(
      "https://img.freepik.com/premium-photo/happy-fashionable-handsome-man_739685-5867.jpg?w=740",
      "Suleman Azeem Khan",
      "suleman.nastecsol@gmail,com",
    ),
    TeamModel(
      "https://img.freepik.com/premium-photo/smiling-businessman-formal-wear-using-tablet-while-standing-rooftop_1289061-391.jpg?w=740",
      "Muhammad Ali Rana",
      "alirana.nastecol@gmail.com",
    ),
    TeamModel(
      "https://img.freepik.com/premium-vector/man-suit-tie-is-smiling-looking-camera_697880-29692.jpg?w=740",
      "Arqum Naeem",
      "arqumnaeem.nastecol@gmail.com",
    ),
    TeamModel(
      "https://img.freepik.com/free-photo/confident-handsome-guy-posing-against-white-wall_176420-32936.jpg?t=st=1723452897~exp=1723456497~hmac=d1063ee18ade6b4f24d492b93758d241342ffeca0abc0759b44bfe7a0986bb4c&w=996",
      "Shoaib Sardar",
      "shoaibsardar.nastecol@gmail.com",
    ),
    TeamModel(
      "https://img.freepik.com/free-psd/flat-man-character_23-2151534197.jpg?w=740&t=st=1723453930~exp=1723454530~hmac=f047b2fdb91350768e41906694186ffddadcde4b49b6d55de3083dfb18cbe3e3",
      "Imad Shareef",
      "imadshareef.nastecol@gmail.com",
    ),
  ];
  int _selectedOptionIndex = 0;
  late String reportingManagerId;
  late List<Teams> filteredTeams;
  late List<Teams> filteredUnderTeams;

  @override
  void initState() {
    super.initState();
    reportingManagerId = singletonClass.getJWTModel()?.empId ?? '';
    List<BranchData> branchDataList = singletonClass.branchDataList;

    // Get the filtered teams
    var filteredData = getFilteredTeams(branchDataList, reportingManagerId);

    // Assign the filtered teams (ownTeams and underTeams) to the filteredTeams list
    filteredTeams = filteredData['ownTeams']!; // or underTeams if you need that specifically
    filteredUnderTeams = filteredData['underTeams']!; // or underTeams if you need that specifically

    // Debug Logs
    print('filteredTeams length: ${filteredTeams.length}');
    print('filteredTeams data: ${filteredTeams}');
  }

  Map<String, List<Teams>> getFilteredTeams(List<BranchData> branchDataList, String reportingManagerId) {
    List<Teams> ownTeams = [];
    List<Teams> underTeams = [];
    String? userGrade = singletonClass.getJWTModel()?.grade;

    // Debugging: print branch data
    print('Branch Data List length: ${branchDataList.length}');

    for (BranchData branchData in branchDataList) {
      for (var departmentDetails in branchData.data?.departmentDetails ?? []) {
        for (var department in departmentDetails.departments ?? []) {
          // Check if the user is a supervisor in the department
          bool isSupervisor = department.supervisors?.any((supervisor) => supervisor.empId == reportingManagerId) ?? false;
          print('Is Supervisor: $isSupervisor, Reporting Manager ID: $reportingManagerId');

          if (userGrade == "L0" || userGrade == "L1") {
            // Supervisor with L0 or L1 grade
            for (var team in department.teams ?? []) {
              bool isUserInTeam = team.teamData?.any((member) => member.empId == reportingManagerId) ?? false;
              if (isUserInTeam) {
                print('Adding under team: ${team.teamId}');
                ownTeams.addAll([team]); // Add to underTeams if the user is part of the team
              }


              // Check if the supervisor manages the team based on teamId match
              for (var supervisor in department.supervisors ?? []) {
                // Check if the supervisor empId matches the reportingManagerId
                if (supervisor.empId == reportingManagerId) {
                  // Now check if the supervisor's teamId matches the current team's teamId
                  if (supervisor.teamId == team.teamId) {
                    print('Adding subordinate team to underTeams based on supervisor empId and teamId match: ${team.teamId}');
                    underTeams.add(team); // Add to underTeams if supervisor manages the team
                  }
                }
              }
            }
          } else if (userGrade == "L2" || userGrade == "L3") {
            // Non-Supervisor: Add teams where the user is a member to underTeams
            for (var team in department.teams ?? []) {
              bool isUserInTeam = team.teamData?.any((member) => member.empId == reportingManagerId) ?? false;
              if (isUserInTeam) {
                print('Adding under team: ${team.teamId}');
                ownTeams.addAll([team]); // Add to underTeams if the user is part of the team
              }
            }
          }
        }
      }
    }

    // Return both lists in a map
    return {
      'ownTeams': ownTeams,
      'underTeams': underTeams,
    };
  }








  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
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
                                color: Colors.grey.withOpacity(0.4),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: NasColors.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // Add your onPressed functionality here
                        },
                        child: SizedBox(
                          height: 30,
                          width: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.filter_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context)!.filter,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                        color: Colors.grey.withOpacity(0.5),
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
                if (singletonClass.getJWTModel()?.grade == "L0" || singletonClass.getJWTModel()?.grade == "L1")...[
                  Row(
                    children: [
                      buildOptionsCard(0, AppLocalizations.of(context)!.teams),
                      buildOptionsCard(1, "My Teams"),
                    ],
                  ),
                  if (_selectedOptionIndex == 0) ...[
                    filteredTeams.isNotEmpty
                        ? ListView.builder(
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      itemCount: filteredTeams.first.teamData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = filteredTeams.first.teamData![index];
                        final team1 = teams[index];
                        bool isSupervisor = team.empId == reportingManagerId;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmployeeProfileScreen(
                                      teamData: team,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
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
                                            image: NetworkImage('${team1.imageURL}'),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${team.userName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          Text(
                                            isSupervisor ? 'Supervisor' : 'Employee',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "${team.designation}",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 35,
                                          ),
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
                    )
                        : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (_selectedOptionIndex == 1) ...[
                    filteredUnderTeams.isNotEmpty
                        ? ListView.builder(
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      itemCount: filteredUnderTeams.first.teamData!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final team = filteredUnderTeams.first.teamData![index];
                        final team1 = teams[index];
                        bool isSupervisor = team.empId == reportingManagerId;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmployeeProfileScreen(
                                      teamData: team,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
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
                                            image: NetworkImage('${team1.imageURL}'),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${team.userName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                          Text(
                                            isSupervisor ? 'Supervisor' : 'Employee',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "${team.designation}",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 35,
                                          ),
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
                    )
                        : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],

                if (singletonClass.getJWTModel()?.grade == "L2" || singletonClass.getJWTModel()?.grade == "L3")...[
                  filteredTeams.isNotEmpty
                      ? ListView.builder(
                    padding: const EdgeInsets.all(5),
                    shrinkWrap: true,
                    itemCount: filteredTeams.first.teamData!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final team = filteredTeams.first.teamData![index];
                      final team1 = teams[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeProfileScreen(
                                    teamData: team,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
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
                                          image: NetworkImage('${team1.imageURL}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${team.userName}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                        Text(
                                          'Employee',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "${team.designation}",
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: 40,
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 35,
                                        ),
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
                  )
                      : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                ]

              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 65,
        width: 140,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ],
          ),
        ),
      ),
    );
  }
}

class TeamModel {
  String? imageURL;
  String? employeeName;
  String? email;

  TeamModel(this.imageURL, this.employeeName, this.email);
}
