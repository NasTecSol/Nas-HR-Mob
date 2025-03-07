import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/create_event_screen.dart';
import 'package:nashr/screens/project_screen.dart';
import 'package:nashr/singleton_class.dart';
import '../request_controller/event_model.dart';
import '../widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();

  final List<MeetingModel> meetings = [
    MeetingModel("Scrum Meeting", "10:00 AM", "B201-With Danial + 5 People"),
    MeetingModel(
        "Design Nas-HR Meeting", "12:00 PM", "C105-With Ammar + 5 People"),
    MeetingModel("N-Collect Development Meeting", "1:00 PM",
        "CT200-With Annas + 5 People"),
  ];
  final List<TaskModel> tasks = [
    TaskModel("New Design For Nas Hr Mobile", "Pending", "July 6 12:00",
        "Nas-Hr Project"),
    TaskModel("Color change on Nas Hr Web", "Completed", "July 7 11:00",
        "Nas-Hr Project"),
    TaskModel(
        "N-Sabak Design Remap", "InProgress", "July 8 01:00", "Nas-Hr Project"),
  ];

  final List<EventModels> events = [
    EventModels("Upcoming Birthdays", "Suleman Azeem Khan #082", "July 6 12:00",
        "Nas-Hr Project"),
    EventModels("Company Outing", "Visit to NasTecSol Company", "July 7 11:00",
        "Danial Rana & 6 others"),
    EventModels("Holiday", "Eid-Ul-Fitr Holiday", "July 8 01:00", "Happy Eid!"),
  ];

  String _getDayOfWeek(DateTime date) {
    return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
  }

  DateTime _selectedDate = DateTime.now();
  int? _selectedDateIndex;

  // Sample list of dates
  final List<DateTime> _dates = List.generate(30, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                child: Text(
                  AppLocalizations.of(context)!.calendar,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
              ),
              const Spacer(),
              if (_selectedOptionIndex == 2) ...[
                if (singletonClass.getJWTModel()?.grade == 'L0' ||
                    singletonClass.getJWTModel()?.grade == 'L1') ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: NasColors.darkBlue,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateEventScreen()));
                      },
                    ),
                  ),
                ]
              ],
            ]),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildOptionsCard(0, AppLocalizations.of(context)!.meetings),
                  buildOptionsCard(1, AppLocalizations.of(context)!.tasks),
                  buildOptionsCard(2, AppLocalizations.of(context)!.events),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.selectDate,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NasColors.darkBlue,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80, // Adjust as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  final bool isSelected = _selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = index;
                        _selectedDate = date; // Store selected date
                      });
                      fetchEvents();
                    },
                    child: Container(
                      width: 55, // Adjust the width as needed
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NasColors.darkBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey),
                          ),
                          Text(
                            _getDayOfWeek(date),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedOptionIndex == 0)
              Column(
                children: [
                  const Divider(
                    color: Colors.grey,
                    height: 2,
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "3 Meetings",
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: Image.asset("images/meeting.png"),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Colors.grey,
                    height: 2,
                    thickness: 1,
                  ),
                  // Use ListView.builder directly within the ListView
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    // Disable scrolling for inner ListView
                    shrinkWrap: true,
                    // Make ListView take up only the necessary space
                    itemCount: meetings.length,
                    itemBuilder: (BuildContext context, int index) {
                      final meeting = meetings[index];
                      return Column(
                        children: [
                          const SizedBox(height: 50),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "${meeting.meetingName}",
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 2,
                                  thickness: 1,
                                  endIndent:
                                      10, // Adds spacing between the line and text
                                ),
                              ),
                              Text(
                                "${meeting.time}",
                                style: GoogleFonts.inter(
                                  color: NasColors.darkBlue,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 2,
                                  thickness: 1,
                                  indent:
                                      10, // Adds spacing between the text and line
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${meeting.members}",
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            if (_selectedOptionIndex == 1)
              Column(
                mainAxisSize: MainAxisSize.min,
                // Set the Column to shrink-wrap its children
                children: [
                  Flexible(
                    // Use Flexible instead of Expanded
                    fit: FlexFit.loose,
                    // Allow the child to take only the space it needs
                    child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      // Ensure the ListView doesn't take up unnecessary space
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final task = tasks[index];
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 120,
                                  width: 20,
                                  // Adjusted the width for visibility
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    color: _getColorForVerificationStatus(
                                        task.status!),
                                  ),
                                ),
                                Expanded(
                                  // Use Expanded to fill the remaining space
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              // Expand the text to fill available space
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
                                                color:
                                                    _getColorForVerificationStatus(
                                                        task.status!),
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month_outlined,
                                              color:
                                                  _getColorForVerificationStatus(
                                                      task.status!),
                                              size: 25,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${task.duration}",
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    _getColorForVerificationStatus(
                                                        task.status!),
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
            if (_selectedOptionIndex == 2) ...[
              FutureBuilder<EventModel?>(
                future: getEventData(),
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
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.data!.isNotEmpty) {
                    final eventList =
                        snapshot.data!.data!; // Extracting event list

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      itemCount: eventList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final event = eventList[index];

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "${event.eventType}",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: NasColors.containerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 165,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                        ),
                                        color: NasColors.darkBlue,
                                        image: DecorationImage(
                                          image: AssetImage(
                                              _getImageForEventType(
                                                  event.eventType!)),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 2),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              "${event.eventName}",
                                              maxLines: 2,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.calendar_month_outlined,
                                                color: NasColors.darkBlue,
                                                size: 30,
                                              ),
                                              Text(
                                                singletonClass
                                                    .formatDate2(event.date!),
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: NasColors.darkBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            width: 250,
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "${event.eventDescription}",
                                                maxLines: 5,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void fetchEvents() {
    setState(() {}); // Trigger rebuild to update FutureBuilder
  }

  //API CALL
  Future<EventModel?> getEventData() async {
    String? employeeId = singletonClass.getJWTModel()?.empId;
    var client = http.Client();

    DateTime startDate, endDate;

    if (_selectedDateIndex == null) {
      // Default: Send first & last date of the year
      startDate = DateTime(DateTime.now().year, 1, 1);
      endDate = DateTime(DateTime.now().year, 12, 31, 23, 59, 59, 999);
    } else {
      // If user selects a date, send the same date as start & end
      startDate = _selectedDate;
      endDate = _selectedDate;
    }

    // Format dates as 'yyyy-MM-dd'
    String startDateString = "${startDate.toIso8601String().split('T')[0]}";
    String endDateString = "${endDate.toIso8601String().split('T')[0]}";

    print(startDateString);
    print(endDateString);
    var uri = Uri.parse(
        '${singletonClass.baseURL}/events/getByEmployee/$employeeId?startDate=$startDateString&endDate=$endDateString');

    var response = await client.get(uri);
    log("Event Data : ${response.body}");

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var eventData = EventModel.fromJson(responseBody);
      singletonClass.eventDataList.add(eventData);
      return eventData;
    }

    return null;
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

  Color _getColorForVerificationStatus(String verificationStatus) {
    switch (verificationStatus) {
      case 'Completed':
        return NasColors.completed;
      case 'Pending':
        return NasColors.pending;
      case 'InProgress':
        return NasColors.onTime;
      case 'All':
        return NasColors.darkBlue;
      default:
        return Colors.grey; // or any other default color
    }
  }

  String _getImageForEventType(String eventType) {
    switch (eventType) {
      case 'Upcoming Birthdays':
        return 'images/birthday.png';
      case 'Company Outing':
        return 'images/Company.png';
      default:
        return 'images/Vector.png'; // Default image for company or other types
    }
  }
}

class MeetingModel {
  String? meetingName;
  String? time;
  String? members;

  MeetingModel(this.meetingName, this.time, this.members);
}

class EventModels {
  String? eventType;
  String? eventTile;
  String? duration;
  String? remarks;

  EventModels(this.eventType, this.eventTile, this.duration, this.remarks);
}
