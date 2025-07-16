import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/branch_shift_model.dart';
import 'package:nashr/request_controller/time_table_shift.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../singleton_class.dart';

class ManageTimeScreen extends StatefulWidget {
  const ManageTimeScreen({super.key});

  @override
  State<ManageTimeScreen> createState() => _ManageTimeScreenState();
}

class _ManageTimeScreenState extends State<ManageTimeScreen> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();
  bool _isChecked = true;
  bool isSearching = false;
  String? selectedBranchName;
  String? selectedBranchId;
  int selectedEmployeeIndex = 0;
  String? selectedEMPID;
  Future<TimeTableShiftModel?>? timeTableFuture;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> finalShiftDetailList = [];
  final List<Map<String, String>> timeTableShiftEmployees = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      fetchAndSetShiftDetails();
      if (timeTableShiftEmployees.isNotEmpty) {
        selectedEMPID = timeTableShiftEmployees[0]['employeeId'];
        timeTableFuture = getTimeTable(selectedEMPID!);
      }
    });
  }

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
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.manageTime,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildOptionsCard(0, AppLocalizations.of(context)!.shifts),
                  buildOptionsCard(1, AppLocalizations.of(context)!.timeTable),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (isSearching == false) ...[
                if (singletonClass.getJWTModel()?.grade == 'L0' ||
                    singletonClass.getJWTModel()?.grade == 'L1' ||
                    singletonClass.getJWTModel()?.grade == "L2")
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onSelected: (value) {
                        setState(() {
                          selectedBranchId = value;
                          final branch = singletonClass
                              .branchesDataList.first.data
                              ?.firstWhere(
                                  (branch) => branch.branchCompanyId == value);
                          selectedBranchName =
                              branch?.branchName ?? "Unknown Branch";
                          print('Selected Branch ID: $value');
                          _isChecked = false;
                          timeTableShiftEmployees.clear();
                          fetchAndSetShiftDetails();
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        final branchList =
                            singletonClass.branchesDataList.first.data;
                        if (branchList == null || branchList.isEmpty) {
                          return [];
                        }
                        return branchList
                            .map((branch) => PopupMenuItem<String>(
                                  value: branch.branchCompanyId,
                                  child: Text(
                                      branch.branchName ?? "Unknown Branch"),
                                ))
                            .toList();
                      },
                      child: Container(
                        height: 49,
                        width: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            Image.asset(
                              'images/site.png',
                              // <-- Replace with your actual image path
                              height: 14,
                              width: 14,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                selectedBranchName != null &&
                                        selectedBranchName!.isNotEmpty
                                    ? selectedBranchName!
                                    : AppLocalizations.of(context)!
                                        .selectBranch,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                Spacer(),
                if (singletonClass.getJWTModel()?.grade == 'L0' ||
                    singletonClass.getJWTModel()?.grade == 'L1' ||
                    singletonClass.getJWTModel()?.grade == "L2")
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.teams,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: NasColors.darkBlue),
                        ),
                        Checkbox(
                            value: _isChecked,
                            activeColor: NasColors.onTime,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                                if (_isChecked == true){
                                  timeTableShiftEmployees.clear();
                                  fetchAndSetShiftDetails();
                                  selectedBranchId = null;
                                  selectedBranchName = null;
                                }
                              });
                            }),
                      ],
                    ),
                  ),
              ],
              if (isSearching == true)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                              searchController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: Icon(
                    Icons.search,
                    size: 30,
                    color: Colors.black,
                  ))
            ]),
            SizedBox(height: 20),
            if (_selectedOptionIndex == 0) ...[
              Expanded(
                child: finalShiftDetailList.isEmpty
                    ? Center(
                  child: Lottie.asset('images/loader.json', height: 200, width: 200),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: finalShiftDetailList.length,
                  itemBuilder: (ctx, i) {
                    final shift = finalShiftDetailList[i];
                    final searchText = searchController.text.toLowerCase();

                    if (isSearching &&
                        !(shift['employeeName']
                            ?.toLowerCase()
                            .contains(searchText) ??
                            false)) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 23,
                                  child: Image.asset(
                                    'images/DP.png',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 160,
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  shift['employeeName'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 88,
                                child: Text(
                                  "${shift['shiftType'] ?? ''}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "• ${AppLocalizations.of(context)!.time} ${formatIsoTime(shift['timeFrom'])} ${AppLocalizations.of(context)!.to} ${formatIsoTime(shift['timeTo'])}",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.more_vert_outlined),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "• ${AppLocalizations.of(context)!.totalHours} ${shift['totalHours'] ?? ''}",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "• Allowed Breaks ${shift['allowedBreak'] ?? ''}",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_selectedOptionIndex == 1) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: timeTableShiftEmployees.length,
                  itemBuilder: (context, index) {
                    final employee = timeTableShiftEmployees[index];
                    final isSelected = index == selectedEmployeeIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEmployeeIndex = index;
                          selectedEMPID = employee['employeeId'];
                          timeTableFuture = getTimeTable(selectedEMPID!);
                        });
                      },
                      child: Opacity(
                        opacity: isSelected ? 1.0 : 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              ClipOval(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 23,
                                  child: Image.asset(
                                    'images/DP.png',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                employee['employeeName'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isSelected) ...[
                                SizedBox(
                                  height: 30, // Enough height for line + arrow
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex: selectedEmployeeIndex,
                                        fit: FlexFit.loose,
                                        child: Container(
                                          height: 3,
                                          color: NasColors.darkBlue,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 3),
                                          Icon(Icons.arrow_drop_down,
                                              color: NasColors.darkBlue,
                                              size: 20),
                                        ],
                                      ),
                                      Flexible(
                                        flex: timeTableShiftEmployees.length -
                                            selectedEmployeeIndex -
                                            1,
                                        fit: FlexFit.loose,
                                        child: Container(
                                          height: 3,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: timeTableFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Lottie.asset('images/loader.json',
                            height: 200, width: 200),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        singletonClass.timeTableShiftsDataList.isEmpty ||
                        singletonClass
                                .timeTableShiftsDataList.first.data?.isEmpty !=
                            false ||
                        singletonClass.timeTableShiftsDataList.first.data?.first
                                .shifts?.isEmpty !=
                            false ||
                        singletonClass.timeTableShiftsDataList.first.data!.first
                                .shifts!.first.shiftDates?.isEmpty !=
                            false) {
                      return const Center(
                          child: Text('No time table data available.'));
                    }

                    final shiftDates = singletonClass.timeTableShiftsDataList
                        .first.data!.first.shifts!.first.shiftDates!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.timeTable,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: shiftDates.length,
                            itemBuilder: (ctx, i) {
                              final timeTable = shiftDates[i];
                              final slots = timeTable.slots ?? [];

                              String formatDate(String updatedAt) {
                                try {
                                  final updatedAtDateTime =
                                      DateTime.parse(updatedAt);
                                  return DateFormat('dd-MM-yyyy')
                                      .format(updatedAtDateTime);
                                } catch (e) {
                                  return '';
                                }
                              }

                              final String date =
                                  formatDate(timeTable.date ?? '');

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    date,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: slots.map((slot) {
                                      final Color baseColor =
                                          parseColor(slot.color)
                                                  ?.withOpacity(0.85) ??
                                              Colors.orange.shade400;

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: baseColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              slot.start != null
                                                  ? formatOnlyTime(slot.start!)
                                                  : '',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 4,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: baseColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              slot.end != null
                                                  ? formatOnlyTime(slot.end!)
                                                  : '',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text("•", style: TextStyle(fontSize: 18, color: Colors.grey)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            int dashCount = (constraints.maxWidth / 6).floor();
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: List.generate(dashCount, (_) {
                                                return Container(
                                                  width: 3,
                                                  height: 1,
                                                  color: Colors.grey.shade400,
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text("•", style: TextStyle(fontSize: 18, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
        });
      },
      child: SizedBox(
        height: 70,
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
                  fontSize: 17,
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

  //API CALL
  Future<void> fetchAndSetShiftDetails() async {
    String? branchId;
    if(_isChecked == false){
      branchId = selectedBranchId?.isNotEmpty == true
          ? selectedBranchId
          : singletonClass.getJWTModel()?.branchId;
    } else {
      branchId = singletonClass.getJWTModel()?.branchId;
    }

    final String? loggedInEmpId = singletonClass.getJWTModel()?.employeeId;

    if (branchId == null || loggedInEmpId == null) return;

    final uri =
        Uri.parse('${singletonClass.baseURL}/branches/branchId/$branchId');
    final response = await http.get(uri, headers: singletonClass.getHeaders());
    print("shift data ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final branch = BranchShiftModel.fromJson(responseBody);

      singletonClass.branchShiftsDataList.clear();
      singletonClass.branchShiftsDataList.add(branch);

      final employeeShifts = branch.data?.employeeShifts ?? [];
      final departmentDetails = branch.data?.branch?.departmentDetails ?? [];
      final departmentShifts = departmentDetails.first.shifts ?? [];

      Map<String, String> employeeIdToNameMap = {};
      if (selectedBranchId != null && selectedBranchId!.isNotEmpty) {
        for (var dept in departmentDetails) {
          for (var department in dept.departments ?? []) {
            for (var team in department.teams ?? []) {
              for (var emp in team.teamData ?? []) {
                if (emp.employeeId != null && emp.userName != null) {
                  employeeIdToNameMap[emp.employeeId!] = emp.userName!;
                }
              }
            }
          }
        }
      } else {
        String? userTeamId;

        for (var dept in departmentDetails) {
          for (var department in dept.departments ?? []) {
            for (var supervisor in department.supervisors ?? []) {
              if (supervisor.employeeId == loggedInEmpId) {
                userTeamId = supervisor.teamId;
                break;
              }
            }
            if (userTeamId != null) break;
          }
          if (userTeamId != null) break;
        }

        if (userTeamId == null) {
          setState(() => finalShiftDetailList = []);
          return;
        }

        for (var dept in departmentDetails) {
          for (var department in dept.departments ?? []) {
            for (var team in department.teams ?? []) {
              if (team.teamId == userTeamId) {
                for (var emp in team.teamData ?? []) {
                  if (emp.employeeId != null && emp.userName != null) {
                    employeeIdToNameMap[emp.employeeId!] = emp.userName!;
                  }
                }
              }
            }
          }
        }
      }
      // 🔄 Match employeeShifts with employee names and shift details
      final List<Map<String, dynamic>> shiftList = [];

      for (var empShift in employeeShifts) {
        final String? empId = empShift.employeeId;
        final String? shiftName = empShift.employeeShift;

        if (empId != null &&
            shiftName != null &&
            employeeIdToNameMap.containsKey(empId)) {
          if (shiftName == "timeTableShift") {
            timeTableShiftEmployees.add({
              'employeeId': empId,
              'employeeName': employeeIdToNameMap[empId] ?? '',
            });
          }

          final matchedShift = departmentShifts.firstWhere(
            (shift) => shift.shiftName == shiftName,
            orElse: () => Shifts(),
          );

          if (matchedShift.shiftName != null &&
              matchedShift.shiftName!.isNotEmpty) {
            shiftList.add({
              'employeeName': employeeIdToNameMap[empId],
              'shiftName': shiftName,
              'shiftType': matchedShift.shiftType,
              'timeFrom': matchedShift.timeFrom,
              'timeTo': matchedShift.timeTo,
              'totalHours': matchedShift.totalHours,
              'allowedBreak': matchedShift.allowedBreak,
            });
          }
        }
      }

      // Optional: Print timeTableShiftEmployees for verification
      print("🕐 Employees with 'timeTableShift':");
      for (var emp in timeTableShiftEmployees) {
        print("${emp['employeeName']} (${emp['employeeId']})");
      }

      setState(() {
        finalShiftDetailList = shiftList;
      });
    }
  }

  //2nd API Call
  Future<TimeTableShiftModel?> getTimeTable(String employeeId) async {
    String? companyId;
    String? branchId;

    if (selectedBranchId == null || selectedBranchId!.isEmpty) {
      companyId = singletonClass.getJWTModel()?.companyId;
      branchId = singletonClass.getJWTModel()?.branchId;
    } else {
      companyId =
          singletonClass.timeTableShiftsDataList.first.data!.first.companyId;
      branchId =
          singletonClass.timeTableShiftsDataList.first.data!.first.branchId;
    }

    final uri = Uri.parse(
      '${singletonClass.baseURL}/time-tables/getByEmployeeIds/$companyId/$branchId?month=June&employeeId=$employeeId',
    );

    final response = await http.get(uri, headers: singletonClass.getHeaders());
    print("TIME TABLE RESPONSE ${response.body}");
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final timeTable = TimeTableShiftModel.fromJson(responseBody);
      singletonClass.timeTableShiftsDataList.add(timeTable);
      return timeTable;
    }
    return null;
  }

  String formatIsoTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '--';
    try {
      final utcTime = DateTime.parse(isoTime).toLocal(); // convert to local
      return DateFormat('hh:mm a').format(utcTime);
    } catch (e) {
      return '--';
    }
  }

  Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex'; // Add opacity if missing
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return null;
    }
  }

  String formatOnlyTime(String timeStr) {
    try {
      final time = DateTime.parse("1970-01-01T$timeStr"); // use dummy date
      return DateFormat.jm().format(time); // e.g., "8:00 AM"
    } catch (e) {
      return '';
    }
  }
}
