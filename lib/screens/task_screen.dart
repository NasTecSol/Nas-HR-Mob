import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<TaskModel> tasks = [
    TaskModel("New Design For Nas Hr Mobile", "Pending", "July 6 12:00", "Nas-Hr Project"),
    TaskModel("Color change on Nas Hr Web", "Completed", "July 7 11:00", "Nas-Hr Project"),
    TaskModel("N-Sabak Design Remap", "InProgress", "July 8 01:00", "Nas-Hr Project"),
  ];
  int _selectedOptionIndex = 0;
  int? _expandedIndex; // Keeps track of the index of the expanded container

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null; // Collapse if the same item is clicked again
      } else {
        _expandedIndex = index; // Expand the clicked item
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TaskModel> filteredTasks = _selectedOptionIndex == 0
        ? tasks // Show all tasks if "All" is selected
        : tasks.where((task) => task.status == _getStatusFromIndex(_selectedOptionIndex)).toList();

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0 , left: 20.0 , right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0 , top: 15.0),
                  child: Text(
                    AppLocalizations.of(context)!.tasks,
                    style: GoogleFonts.inter(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildOptionsCard(0,  AppLocalizations.of(context)!.all),
                  buildOptionsCard(1,  AppLocalizations.of(context)!.inProgress),
                  buildOptionsCard(2,  AppLocalizations.of(context)!.pending),
                  buildOptionsCard(3,  AppLocalizations.of(context)!.completed),
                ],
              ),
            ),
            Expanded( // Use Expanded to allow ListView to take remaining space
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: filteredTasks.length,
                itemBuilder: (BuildContext context, int index) {
                  final task = filteredTasks[index];
                  return GestureDetector(
                    onTap: () => _toggleExpand(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color:  Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded( // Use Expanded to fill the remaining space
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded( // Expand the text to fill available space
                                        child: Text(
                                          "${task.taskName}",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: _getColorForVerificationStatus(task.status!),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${task.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                 if (_expandedIndex == index) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: _getColorForVerificationStatus(task.status!),
                                        size: 25,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${task.duration}",
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: _getColorForVerificationStatus(task.status!),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "${task.projectName}",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                  ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionsCard(int index, String title) {
    Color getStatusColor(String title) {
      switch (title) {
        case 'Completed':
          return NasColors.completed;
        case 'Pending':
          return Colors.yellow;
        case 'InProgress':
          return NasColors.onTime;
        default:
          return NasColors.darkBlue; // Default color
      }
    }
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
          color: _selectedOptionIndex == index ? getStatusColor(title) : Colors.white,
          elevation: 100.0,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: _selectedOptionIndex == index ? Colors.white : Colors.white,
              width: 0.0,
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
                  color: _selectedOptionIndex == index ? Colors.white : NasColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 1:
        return 'InProgress';
      case 2:
        return 'Pending';
      case 3:
        return 'Completed';
      default:
        return '';
    }
  }

  Color _getColorForVerificationStatus(String verificationStatus) {
    switch (verificationStatus) {
      case 'Completed':
        return NasColors.completed;
      case 'Pending':
        return Colors.yellow;
      case 'InProgress':
        return NasColors.onTime;
      case 'All':
        return NasColors.darkBlue;
      default:
        return Colors.grey; // or any other default color
    }
  }
}

class TaskModel {
  String? taskName;
  String? status;
  String? duration;
  String? projectName;

  TaskModel(this.taskName, this.status, this.duration, this.projectName);
}
