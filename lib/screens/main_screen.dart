import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/calendar_screen.dart';
import 'package:nashr/screens/request_screen.dart';
import 'package:nashr/screens/task_screen.dart';
import '../widgets/colors.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final iconList = <IconData>[
    Icons.home,
    Icons.task,
    Icons.mail_outline,
    Icons.calendar_today,
  ];

  List<String> iconLabels = [
    'Home',
    'Task',
    'Requests',
    'Calendar',
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const TaskScreen(),
    const RequestScreen(),
    const CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ]),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: AnimatedBottomNavigationBar.builder(
              itemCount: iconList.length,
              tabBuilder: (int index, bool isActive) {
                final color = isActive ? Colors.white : Colors.grey;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 90,
                    alignment: Alignment.center,
                    decoration: isActive
                        ? BoxDecoration(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(15)),
                      color: NasColors
                          .darkBlue, // Change this to your desired color for the active item
                    )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Icon(
                            iconList[index],
                            size: 35,
                            color: color,
                          ),
                          if (isActive)
                             Expanded(
                               child: Text(
                                  iconLabels[index],
                                 overflow: TextOverflow.ellipsis,
                                 softWrap: false,
                                  style: GoogleFonts.poppins(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                             ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              activeIndex: _currentIndex,
              gapLocation: GapLocation.none,
              notchSmoothness: NotchSmoothness.softEdge,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              height: 80,
              shadow: const Shadow(
                color: Colors.grey,
                blurRadius: 20.5,
              ),
              backgroundColor: Colors.white,
              splashColor: Colors.white,

              // Add this line if you want a splash effect on tap
            ),
          ),
        ),
      ),
    );
  }
}
