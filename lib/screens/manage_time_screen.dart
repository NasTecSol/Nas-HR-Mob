import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/branch_shift_model.dart';
import 'package:nashr/request_controller/time_table_shift.dart';
import 'package:nashr/screens/update_shift_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../request_controller/branches_model.dart';
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
  int selectedEmployeeIndex = 0;
  String? selectedEMPID;
  Future<TimeTableShiftModel?>? timeTableFuture;
  TextEditingController searchController = TextEditingController();
  final List<Map<String, String>> timeTableShiftEmployees = [];
  Future<void>? _shiftFuture;

  @override
  void initState() {
    super.initState();
    _teamCheck();
    _shiftFuture = fetchAndSetShiftDetails();
    getShiftsFromBranches();
  }

  void _teamCheck(){
    if (singletonClass.branchID != null && singletonClass.branchID!.isNotEmpty){
      _isChecked = false ;
    }
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
                  AppLocalizations.of(context)!.manageShifts,
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
                if(_selectedOptionIndex == 0)...[
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
                            timeTableShiftEmployees.clear();
                            singletonClass.branchID = value;
                            final branch = singletonClass.branchesDataList.first.data?.firstWhere(
                                    (branch) => branch.branchCompanyId == value);
                            singletonClass.branchName = branch?.branchName ?? "Unknown Branch";
                            _isChecked = false;
                            /// UPDATE _shiftFuture so FutureBuilder gets refreshed
                            _shiftFuture = fetchAndSetShiftDetails();
                            getShiftsFromBranches();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          final branchList = singletonClass.branchesDataList.first.data;
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
                                height: 14,
                                width: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  singletonClass.branchName != null &&
                                      singletonClass.branchName!.isNotEmpty
                                      ? singletonClass.branchName!
                                      : singletonClass.branchDataList.first.data!.branch!.branchName!,
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
                            onChanged:(singletonClass.branchID != null) ? (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                                if (_isChecked == true) {
                                  timeTableShiftEmployees.clear();
                                  singletonClass.branchID = null;
                                  singletonClass.branchName = null;
                                  _shiftFuture = fetchAndSetShiftDetails();
                                  getShiftsFromBranches();
                                }
                              });
                            } : null ),
                        ],
                      ),
                    ),
                ]

              ],
              if(_selectedOptionIndex == 0)...[
                if(isSearching == true)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {

                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
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
                          borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
              ],
            ]),
            SizedBox(height: 20),
            if (_selectedOptionIndex == 0) ...[
              Expanded(
                child: FutureBuilder(
                    future: _shiftFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/loader.json'),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/error.json'),
                            ),
                          ),
                        );
                      } else  {
                        final employees = singletonClass.branchShiftsDataList.first.data?.employees ?? [];
                        return employees.isEmpty
                            ? Center(
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
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: employees.length,
                          itemBuilder: (ctx, i) {
                            final employee = employees[i];
                            final searchText = searchController.text.toLowerCase();

                            if (isSearching &&
                                !((employee.userName?.toLowerCase().contains(searchText) ?? false) ||
                                    (employee.employeeInfo!.first.empId?.toLowerCase().contains(searchText) ?? false))) {
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
                                        width: 110,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "${employee.userName}",
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
                                        width: 100,
                                        child: Text(
                                          _translateShifts(employee.shiftInfo?.shiftType ?? '---', context),
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
                                      if (employee.shiftInfo != null && employee.shiftInfo!.shiftType == 'fullTime')
                                      Text(
                                        "• ${AppLocalizations.of(context)!.time} ${formatIsoTime(employee.shiftInfo?.timeFrom)} ${AppLocalizations.of(context)!.to} ${formatIsoTime(employee.shiftInfo?.timeTo)}",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(),
                                      Builder(
                                        builder: (context) {
                                          return IconButton(
                                            icon: const Icon(Icons.more_vert_outlined),
                                            onPressed: () async {
                                              final RenderBox button = context.findRenderObject() as RenderBox;
                                              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                                              final RelativeRect position = RelativeRect.fromRect(
                                                Rect.fromPoints(
                                                  button.localToGlobal(Offset.zero, ancestor: overlay),
                                                  button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                                ),
                                                Offset.zero & overlay.size,
                                              );

                                              await showMenu(
                                                context: context,
                                                position: position,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                color: Colors.white,
                                                items: [
                                                  PopupMenuItem(
                                                    padding: EdgeInsets.zero,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateShiftScreen(employees: employee)));
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                        child: Row(
                                                          children: [
                                                            const Icon(Icons.edit, size: 18),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              AppLocalizations.of(context)!.update,
                                                              style: GoogleFonts.inter(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }),
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
                                  height: 30,
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
                      return Center(
                        child: Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.asset('images/error.json'),
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        singletonClass.timeTableShiftsDataList.isEmpty ||
                        singletonClass.timeTableShiftsDataList.first.data == null ||
                        singletonClass.timeTableShiftsDataList.first.data!.isEmpty ||
                        singletonClass.timeTableShiftsDataList.first.data!.first.shifts == null ||
                        singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.isEmpty ||
                        singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.first.shiftDates == null ||
                        singletonClass.timeTableShiftsDataList.first.data!.first.shifts!.first.shiftDates!.isEmpty) {
                      return  Center(
                        child: Padding(
                          padding:  EdgeInsets.all(20.0),
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
                      );
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
                                                  : '--:--',
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
                                                  : '--:--',
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

  /// CARDS
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
          if (index == 0) {
            _shiftFuture = fetchAndSetShiftDetails();
            getShiftsFromBranches();
            isSearching = false;
          } else {
            isSearching = true;
            final employee = timeTableShiftEmployees[0];
            print(employee['employeeId']);
            selectedEMPID = employee['employeeId'];
            timeTableFuture = getTimeTable(selectedEMPID!);
          }
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

  /// API CALLS
  Future<void> fetchAndSetShiftDetails() async {
    String? branchId;
    if (_isChecked == false) {
      branchId = singletonClass.branchID?.isNotEmpty == true
          ? singletonClass.branchID
          : singletonClass.getJWTModel()?.branchId;
    } else {
      branchId = singletonClass.getJWTModel()?.branchId;
    }

    if (branchId == null) return;

    final uri = Uri.parse(
      '${singletonClass.baseURL}/branches/branchEmplyeesInfo/$branchId',
    );
    final response = await http.get(uri, headers: singletonClass.getHeaders());

    print("Shifts uri $uri");
    print("Shift data: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final branch = BranchShiftModel.fromJson(responseBody);

      singletonClass.branchShiftsDataList.clear();
      singletonClass.branchShiftsDataList.add(branch);

      final employees = branch.data?.employees;
      timeTableShiftEmployees.clear();

      if (employees != null) {
        for (var emp in employees) {
          final shiftType = emp.shiftInfo?.shiftType;
          if (shiftType != null &&
              shiftType.toLowerCase() == 'timetableshift') {
            timeTableShiftEmployees.add({
              "employeeId": emp.id ?? "NoID",
              "employeeName": emp.userName ?? "Unknown",
            });
          }
        }

        if (timeTableShiftEmployees.isNotEmpty) {
          selectedEMPID = timeTableShiftEmployees[0]['employeeId'];
        }
      }
    }
  }
  /// TIME TABLE API CALL
  Future<TimeTableShiftModel?> getTimeTable(String employeeId) async {
    final jwt = singletonClass.getJWTModel();

    final companyId = (singletonClass.selectedCompanyId?.isNotEmpty ?? false)
        ? singletonClass.selectedCompanyId
        : jwt?.companyId;

    final branchId = (singletonClass.branchID?.isNotEmpty ?? false)
        ? singletonClass.branchID
        : jwt?.branchId;

    if (companyId == null || branchId == null) {
      if (kDebugMode) {
        print("Company ID or Branch ID is missing");
      }
      return null;
    }

    final uri = Uri.parse(
      '${singletonClass.baseURL}/time-tables/getByEmployeeIds/$companyId/$branchId?month=August&employeeId=$employeeId',
    );

    final response = await http.get(uri, headers: singletonClass.getHeaders());
    if (kDebugMode) {
      print("time table uri $uri");
      print("TIME TABLE RESPONSE ${response.body}");
    }


    if (response.statusCode == 200) {
      final timeTable = TimeTableShiftModel.fromJson(json.decode(response.body));
      singletonClass.timeTableShiftsDataList
        ..clear()
        ..add(timeTable);
      return timeTable;
    }
    return null;
  }



  /// UPDATE SHIFT DATA
  Future<void> getShiftsFromBranches() async {
    String? branchId;
    if(_isChecked == false){
      branchId = singletonClass.branchID?.isNotEmpty == true
          ? singletonClass.branchID
          : singletonClass.getJWTModel()?.branchId;
    } else {
      branchId = singletonClass.getJWTModel()?.branchId;
    }

    final uri =
    Uri.parse('${singletonClass.baseURL}/branches/branchId/$branchId');
    final response = await http.get(uri, headers: singletonClass.getHeaders());
    print("shift data update${response.body}");

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final branch = BranchesModel.fromJson(responseBody);

      singletonClass.branchesModelDataList.clear();
      singletonClass.branchesModelDataList.addAll([branch]);
    }}



  String formatIsoTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '--';
    try {
      final utcTime = DateTime.parse(isoTime).toLocal(); // convert to local
      return DateFormat('hh:mm a').format(utcTime);
    } catch (e) {
      return '--:--';
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
      final time = DateTime.parse("1970-01-01T$timeStr");
      return DateFormat.jm().format(time);
    } catch (e) {
      return '--:--';
    }
  }

  String _translateShifts(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (status == null || status.isEmpty) {
      return localizations.noData;
    }

    switch (status) {
      case 'fullTime':
        return localizations.fullTime;
      case 'flexibleShift':
        return localizations.flexibleShift;
      case 'timeTableShift':
        return localizations.timeTableShift;
      default:
        return status;
    }
  }
}