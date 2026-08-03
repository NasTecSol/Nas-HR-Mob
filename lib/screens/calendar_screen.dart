import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/create_event_screen.dart';
import 'package:nashr/singleton_class.dart';
import '../request_controller/event_model.dart';
import '../widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';

import '../widgets/loader.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();
  late List<DateTime> _dates;
  bool _isLoading = false;
  bool _hasError = false;
  EventModel? _eventData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(today.day, (index) {
      return DateTime(today.year, today.month, index + 1);
    });
    _selectedDateIndex = today.day - 1;
    _selectedDate = today;
    _fetchAndLoadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients &&
        _selectedDateIndex != null &&
        _selectedDateIndex! >= 0) {
      _scrollController.animateTo(
        _selectedDateIndex! * 66.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchAndLoadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final res = await getEventData();
      if (mounted) {
        setState(() {
          _eventData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }
  String _getDayOfWeek(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == "ar") {
      return [
        "الإثنين", // Monday
        "الثلاثاء", // Tuesday
        "الأربعاء", // Wednesday
        "الخميس", // Thursday
        "الجمعة", // Friday
        "السبت", // Saturday
        "الأحد", // Sunday
      ][date.weekday - 1];
    } else {
      return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1];
    }
  }


  DateTime _selectedDate = DateTime.now();
  int? _selectedDateIndex;


  String formatDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == "ar") {
      return _toArabicNumber(date.day);
    } else {
      return date.day.toString();
    }
  }


  String _toArabicNumber(int number) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join('');
  }


  Future<void> fetchLatestEventData() async {
    await _fetchAndLoadData();
  }

  Widget _buildHeader(BuildContext context) {
    final canCreate = singletonClass.getJWTModel()?.grade == 'L0' ||
        singletonClass.getJWTModel()?.grade == 'L1';

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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.calendar,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (canCreate)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventScreen(
                          selectedIndex: _selectedOptionIndex,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RefreshIndicator(
                color: NasColors.darkBlue,
                backgroundColor: Colors.white,
                onRefresh: fetchLatestEventData,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: [
                    _FilterChip(
                      label: AppLocalizations.of(context)!.meetings,
                      count: _getCountForOption(0),
                      selected: _selectedOptionIndex == 0,
                      accentColor: _chipAccentColor(0),
                      onTap: () {
                        setState(() {
                          _selectedOptionIndex = 0;
                        });
                      },
                    ),
                    _FilterChip(
                      label: AppLocalizations.of(context)!.tasks,
                      count: _getCountForOption(1),
                      selected: _selectedOptionIndex == 1,
                      accentColor: _chipAccentColor(1),
                      onTap: () {
                        setState(() {
                          _selectedOptionIndex = 1;
                        });
                      },
                    ),
                    _FilterChip(
                      label: AppLocalizations.of(context)!.events,
                      count: _getCountForOption(2),
                      selected: _selectedOptionIndex == 2,
                      accentColor: _chipAccentColor(2),
                      onTap: () {
                        setState(() {
                          _selectedOptionIndex = 2;
                        });
                      },
                    ),
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
                height: 80,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final bool isSelected = _selectedDateIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateIndex = index;
                          _selectedDate = date;
                        });
                        _fetchAndLoadData();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NasColors.darkBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: NasColors.darkBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                             formatDay(context, date),
                              style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey.shade500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getDayOfWeek(context ,date),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : Colors.grey.shade400,
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
              if (_isLoading) ...[
                const SizedBox(height: 50),
                const Loader(),
              ] else if (_hasError) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset('images/error.json'),
                    ),
                  ),
                ),
              ] else if (_eventData != null) ...[
                if (_selectedOptionIndex == 0) ...[
                  Builder(
                    builder: (context) {
                      final meetingList = _eventData!.data!.where((event) =>
                          event.category == "General Meeting" || event.category == "Work Meeting").toList();
                      if (meetingList.isEmpty) {
                        return Center(
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
                        );
                      }

                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "${meetingList.length} ${AppLocalizations.of(context)!.meetings}",
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: Image.asset("images/meeting.png"),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: meetingList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final meeting = meetingList[index];
                              String membersList = "---";

                              if (meeting.members != null && meeting.members is List<Members>) {
                                List<String?> names = meeting.members!.map((e) => e.name).toList();

                                if (names.isNotEmpty) {
                                  membersList = names.join(", ");
                                }
                              }
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: NasColors.darkBlue.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.groups_rounded,
                                                  size: 14,
                                                  color: NasColors.darkBlue,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  meeting.category ?? "Meeting",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          if (meeting.date != null)
                                            Text(
                                              singletonClass.formatWithDateTime(meeting.date!),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        meeting.eventName ?? "---",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (meeting.eventDescription != null && meeting.eventDescription!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          meeting.eventDescription!,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF7F8FA),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(18),
                                          bottomRight: Radius.circular(18),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_search_rounded,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              membersList,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  ),
                ],
                if (_selectedOptionIndex == 1) ...[
                  Builder(
                    builder: (context) {
                      final eventList = _eventData!.data!
                          .where((event) => event.category == "Task Deadlines")
                          .toList();

                      if (eventList.isEmpty) {
                        return Center(
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
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final task = eventList[index];
                          return Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          bottomLeft: Radius.circular(18),
                                        ),
                                        color: _getColorForVerificationStatus("Pending"),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getColorForVerificationStatus("Pending").withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    task.eventType ?? "Task",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: _getColorForVerificationStatus("Pending"),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (task.date != null)
                                                  Text(
                                                    singletonClass.formatDate2(task.date!, context),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              task.eventName ?? "No Task Name",
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (task.eventDescription != null && task.eventDescription!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                task.eventDescription!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7F8FA),
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(18),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: _getColorForVerificationStatus("Pending"),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  task.month ?? "No Duration",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getColorForVerificationStatus("Pending"),
                                                  ),
                                                ),
                                              ],
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
                        },
                      );
                    }
                  ),
                ],
                if (_selectedOptionIndex == 2) ...[
                  Builder(
                    builder: (context) {
                      final eventList = _eventData!.data!
                          .where((event) => event.category == "Standup" || event.category == "Celebration")
                          .toList();
                      if (eventList.isEmpty) {
                        return Center(
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
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: eventList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final event = eventList[index];

                          return Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          bottomLeft: Radius.circular(18),
                                        ),
                                        color: NasColors.darkBlue.withOpacity(0.05),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Center(
                                        child: Image.asset(
                                          _getImageForEventType(event.eventType ?? ""),
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.event_note_rounded,
                                            color: NasColors.darkBlue,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: NasColors.darkBlue.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    event.eventType ?? "Event",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: NasColors.darkBlue,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (event.category != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal.withOpacity(0.08),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      event.category!,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.teal.shade700,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              event.eventName ?? "Unnamed Event",
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (event.eventDescription != null && event.eventDescription!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                event.eventDescription!,
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF7F8FA),
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(18),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  color: NasColors.darkBlue,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  singletonClass.formatDate2(event.date ?? "", context),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: NasColors.darkBlue,
                                                  ),
                                                ),
                                              ],
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
                        },
                      );
                    }
                  ),
                ],
              ] else ...[
                Center(
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
          ),
        ),
      ),
    ),
  ],
),
);
  }

  ///API CALL
  Future<EventModel?> getEventData() async {
    String? employeeId = singletonClass.getJWTModel()?.employeeId;
    var client = http.Client();

    DateTime startDate, endDate;

    if (_selectedDateIndex == null) {
      startDate = DateTime(DateTime.now().year, 1, 1);
      endDate = DateTime(DateTime.now().year, 12, 31, 23, 59, 59, 999);
    } else {
      startDate = _selectedDate;
      endDate = _selectedDate;
    }
    String startDateString = startDate.toIso8601String().split('T')[0];
    String endDateString = endDate.toIso8601String().split('T')[0];
    if (kDebugMode) {
      print(startDateString);
      print(endDateString);
    }
    var uri = Uri.parse(
        '${singletonClass.baseURL}/events/getByEmployee/$employeeId?startDate=$startDateString&endDate=$endDateString');

    var response = await client.get(uri,headers: singletonClass.getHeaders());
    log("Event Data : ${response.body}");

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var eventData = EventModel.fromJson(responseBody);
      singletonClass.eventDataList.add(eventData);
      return eventData;
    }

    return null;
  }

  int _getCountForOption(int index) {
    if (_eventData?.data == null) return 0;
    switch (index) {
      case 0:
        return _eventData!.data!
            .where((event) => event.category == "General Meeting" || event.category == "Work Meeting")
            .length;
      case 1:
        return _eventData!.data!
            .where((event) => event.category == "Task Deadlines")
            .length;
      case 2:
        return _eventData!.data!
            .where((event) => event.category == "Standup" || event.category == "Celebration")
            .length;
      default:
        return 0;
    }
  }

  Color _chipAccentColor(int index) {
    switch (index) {
      case 0:
        return NasColors.darkBlue;
      case 1:
        return NasColors.pending;
      case 2:
        return NasColors.completed;
      default:
        return NasColors.darkBlue;
    }
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

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.accentColor,
  });

  Color get _chipBg => selected ? accentColor : Colors.white;
  Color get _textColor => selected ? Colors.white : accentColor;
  Color get _badgeBg => selected
      ? Colors.white.withOpacity(0.25)
      : accentColor.withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: accentColor.withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accentColor.withOpacity(0.35)
                  : Colors.black.withOpacity(0.06),
              blurRadius: selected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
