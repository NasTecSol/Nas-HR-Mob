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

  late String reportingManagerId;
  late List<Supervisors> filteredSupervisors;

  @override
  void initState() {
    super.initState();

    // Initialize reportingManagerId
    reportingManagerId = singletonClass.employeeDataList.first.data!.employeeInfo!.first.reportingManager ?? '';
    List<BranchData> branchDataList = singletonClass.branchDataList;

    // Initialize filteredSupervisors
    filteredSupervisors = getFilteredSupervisors(branchDataList, reportingManagerId);
  }

  // Extract supervisors from the list of BranchData models
  List<Supervisors> getFilteredSupervisors(List<BranchData> branchDataList, String reportingManagerId) {
    List<Supervisors> filteredSupervisors = [];

    for (var branchData in branchDataList) {
      if (branchData.data?.departmentDetails != null) {
        for (var departmentDetails in branchData.data!.departmentDetails!) {
          if (departmentDetails.departments != null) {
            for (var department in departmentDetails.departments!) {
              if (department.supervisors != null) {
                // Filter supervisors where empId matches reportingManagerId
                var matchingSupervisors = department.supervisors!
                    .where((supervisor) => supervisor.empId == reportingManagerId)
                    .toList();

                if (matchingSupervisors.isNotEmpty) {
                  // Add matching supervisors to filtered list
                  filteredSupervisors.addAll(matchingSupervisors);

                  // Add team members of the matched supervisor
                  for (var supervisor in matchingSupervisors) {
                    var team = department.teams?.firstWhere(
                          (team) => team.teamId == supervisor.teamId,
                      orElse: () => Teams(teamId: '', teamData: []), // Return an empty Teams object if not found
                    );

                    if (team != null && team.teamData != null) {
                      // Convert team members to Supervisors type and add to the filtered list
                      for (var member in team.teamData!) {
                        filteredSupervisors.add(
                          Supervisors(
                            empId: member.empId,
                            userName: member.userName,
                            designation: member.designation,
                            grade: member.grade,
                            teamId: supervisor.teamId, // Keeping the same team ID
                          ),
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return filteredSupervisors;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0 , left: 20 , right: 20),
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
                          height: 50,
                          width: 50,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                      child: Text(
                        AppLocalizations.of(context)!.teams,
                        style: GoogleFonts.inter(
                          fontSize: 25,
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
                          width: 100,
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
                ListView.builder(
                  padding: const EdgeInsets.all(5),
                  shrinkWrap: true,
                  itemCount: filteredSupervisors.length,
                  itemBuilder: (BuildContext context, int index) {
                    final team = filteredSupervisors[index];
                    final team1 = teams[index];
                    bool isSupervisor = team.empId == reportingManagerId;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> EmployeeProfileScreen(supervisors: team,)));
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
              ],
            ),
          ),
        ],
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
