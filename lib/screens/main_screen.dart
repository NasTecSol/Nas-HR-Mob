import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/calendar_screen.dart';
import 'package:nashr/screens/profile_screen.dart';
import 'package:nashr/screens/requests/request_screen.dart';
import 'package:nashr/screens/project_screen.dart';
import 'package:nashr/singleton_class.dart';
import '../widgets/colors.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final int index;
  final int selectedIndex;
  const MainScreen({super.key, required this.index, required this.selectedIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  SingletonClass singletonClass = SingletonClass();
  int _currentIndex = 0;
  bool isLoading = false;
  final imageIconList = <String>[
    'images/homeScreen.png',
    'images/projectScreen.png',
    'images/requestScreen.png',
    'images/calendarScreen.png',
  ];



  @override
  void initState() {
    super.initState();
    _loadData();
    setState(() {
      _currentIndex = widget.index;
      _loadData();
    });
  }




  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loadInitialData();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
     singletonClass.getCompaniesData(),
     singletonClass.getRoleAndAccessData(),
     singletonClass.getUISettingsData(),
     singletonClass.getEmployeeData(),
     singletonClass.getClockingData(),
     singletonClass.getBranchData(),
     singletonClass.getCompanyData(),
     singletonClass.getRemoteAttendanceData(),
     singletonClass.getEmployeeAttendanceData(),
     singletonClass.getNotifications(),
     singletonClass.getBranchesData(),
     singletonClass.getChats(),
     singletonClass.getOrganizationData(),
     singletonClass.getPolicyData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const ProjectScreen(),
      RequestScreen(selectedIndex: widget.selectedIndex),
      const CalendarScreen(),
      const ProfileScreen()
    ];
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ?  Padding(
              padding: const EdgeInsets.only(top: 45.0),
              child: Center(
                child:SizedBox(
                  child: Lottie.asset(
                  'images/splash5.json'
              ),),
              ),
            )
            : screens[_currentIndex],
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
                itemCount: imageIconList.length + 1,
                tabBuilder: (int index, bool isActive) {
                  if (index == imageIconList.length) {
                    return CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: ClipOval(
                        child: (singletonClass.employeeDataList.isNotEmpty &&
                            singletonClass.employeeDataList.first.data?.profilePic != null &&
                            singletonClass.employeeDataList.first.data!.profilePic!.isNotEmpty &&
                            singletonClass.employeeDataList.first.data!.profilePic != "https://www.profilePic.com")
                            ? Image.network(
                          singletonClass.employeeDataList.first.data!.profilePic!,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: NasColors.darkBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'images/DP.png',
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            );
                          },
                        )
                            : Image.asset(
                          'images/DP.png',
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
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
                            child: Image.asset(
                              imageIconList[index],
                              height: 35,
                              width: 35,
                              fit: BoxFit.contain,
                              color: _currentIndex == index
                                  ? Colors.white
                                  : (index == 0 || index == 2 ? Colors.black : null),
                            ),
                          ),
                          if (index == 2)
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
                                child: singletonClass.getJWTModel()?.grade == 'L0' || singletonClass.getJWTModel()?.grade == 'L1'
                                    || singletonClass.getJWTModel()?.grade == 'L2'
                                    || singletonClass.getJWTModel()?.grade == 'L3'
                                    ?
                                Text(
                                  '${singletonClass.requestDataList.isNotEmpty && singletonClass.requestDataList.first.data != null &&
                                      singletonClass.approverDataList.isNotEmpty && singletonClass.approverDataList.first.data != null
                                      ? singletonClass.requestDataList.first.data!.data!.where((request) => request.status == 'approved').length +
                                      singletonClass.approverDataList.first.data!.data!.where((request) => request.status == 'pending').length
                                      : 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ) : Text(
                                  '${singletonClass.requestDataList.isNotEmpty && singletonClass.requestDataList.first.data != null && singletonClass.requestDataList.first.data!.data != null
                                      ? singletonClass.requestDataList.first.data!.data!.where((request) => request.status == 'approved').length
                                      : 0}',
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
