import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/calendar_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/screens/request_screen.dart';
import 'package:nashr/screens/project_screen.dart';
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
    const ProjectScreen(),
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
                  color: Colors.grey.withValues(alpha: 0.5),
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
                          borderRadius: BorderRadius.circular(15),
                          color: NasColors.darkBlue,
                        )
                            : null,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 35,
                          child: ClipOval(
                            child: (singletonClass.employeeDataList.first.data?.profilePic != null && singletonClass.employeeDataList.first.data!.profilePic!.isNotEmpty)
                                ? Image.network(
                              singletonClass.employeeDataList.first.data!.profilePic!,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'images/DP.png',
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                );
                              },
                            )
                                : Image.asset(
                              'images/DP.png', // Default image if profilePic is null/empty
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                            ),
                          ),
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
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: NasColors.darkBlue,
                      )
                          : null,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(
                              iconList[index],
                              size: 30,
                              color: color,
                            ),
                          ),
                          if (index == 2) // Add badge only for the RequestScreen icon (index 2)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1'  ?
                                Text(
                                  '${singletonClass.requestDataList.isNotEmpty && singletonClass.requestDataList.first.data != null &&
                                      singletonClass.approverDataList.isNotEmpty && singletonClass.approverDataList.first.data != null
                                      ? singletonClass.requestDataList.first.data!.data!.where((request) => request.status == 'approved').length +
                                      singletonClass.approverDataList.first.data!.data!.where((request) => request.status == 'pending').length
                                      : 0}', // Request List Notification count
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ) : Text(
                                  '${singletonClass.requestDataList.isNotEmpty && singletonClass.requestDataList.first.data != null && singletonClass.requestDataList.first.data!.data != null
                                      ? singletonClass.requestDataList.first.data!.data!.where((request) => request.status == 'approved').length
                                      : 0}', // Approver List Notification count
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                )

                              ),
                            ),
                        ],
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
