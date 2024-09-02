import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/calendar_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/screens/request_screen.dart';
import 'package:nashr/screens/task_screen.dart';
import 'package:nashr/singleton_class.dart';
import '../widgets/colors.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _currentIndex = 0;
  bool _isLoading = true;
  final iconList = <IconData>[
    Icons.home,
    Icons.task,
    Icons.mail_outline,
    Icons.calendar_today, // Remove the last icon data
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const TaskScreen(),
    const RequestScreen(),
    const CalendarScreen(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }


  void _fetchEmployeeData() async {
    if (singletonClass.employeeDataList.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    } else {

      Future.delayed(const Duration(seconds: 2), () {
        _fetchEmployeeData();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: NasColors.backGround,
        body: _isLoading
            ?  Center(
          child:SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset(
                'images/loader.json'
            ),
          ), // Show loader while loading
        )
            : _screens[_currentIndex],
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: AnimatedBottomNavigationBar.builder(
                itemCount: iconList.length + 1, // Increment the item count by 1
                tabBuilder: (int index, bool isActive) {
                  final color = isActive ? Colors.white : Colors.grey;

                  if (index == iconList.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 70,
                        alignment: Alignment.center,
                        decoration: index == 3
                            ? BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(15)),
                          color: NasColors.darkBlue,
                        )
                            : null,
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('images/DP.jpg'),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 70,
                      alignment: Alignment.center,
                      decoration: isActive
                          ? BoxDecoration(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(15)),
                        color: NasColors.darkBlue,
                      )
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                              iconList[index],
                              size: 30,
                              color: color,
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
                height: 70,
                shadow: const Shadow(
                  color: Colors.grey,
                  blurRadius: 20.5,
                ),
                backgroundColor: Colors.white,
                splashColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
