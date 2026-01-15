import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/language_screen.dart';
import 'package:nashr/screens/slack_screen.dart';
import 'package:nashr/screens/socket_screen.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../UTILS/auth_services.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool _isToggled = false ;
  bool isBiometricEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isNotificationToggled = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
    _initializeSettings();
  }

  void _initializeSettings() async {
    _isNotificationToggled = await _loadNotificationState();
    setState(() {});
  }

  // Load the state from SharedPreferences
  Future<void> _loadBiometricState() async {
    final preferences = await SharedPreferences.getInstance();
    isBiometricEnabled = preferences.getBool('biometric_enabled') ?? false;

    setState(() {
      _isBiometricEnabled = isBiometricEnabled;
      _isToggled = isBiometricEnabled;
    });
  }


  // Save the state to SharedPreferences
  Future<void> _saveBiometricState(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('biometric_enabled', value);
  }

  final AuthService _authService = AuthService();

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    singletonClass.reset();
    SocketService2().socket!.disconnect();
    SocketService().socket!.disconnect();
  }

  /// Notifications
  Future<void> _saveNotificationState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true; // Default to true
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
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
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.4),
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
                        AppLocalizations.of(context)!.settings,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint , size: 28,color: NasColors.darkBlue,),
                      Text( AppLocalizations.of(context)!.biometrics,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isToggled,
                        onChanged: (bool value) async {
                          setState(() {
                            _isToggled = value;
                          });

                          if (_isToggled) {
                            if (!(await _authService.checkBiometricAvailability())) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSetupBiometric,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15
                                  ),
                                )),
                              );
                              setState(() {
                                _isToggled = false;
                              });
                              return;
                            }

                            bool isAuthenticated = await _authService.authenticateWithBiometrics(context);
                            if (isAuthenticated) {
                              setState(() {
                                _isBiometricEnabled = value;
                              });
                              await _saveBiometricState(value);
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(AppLocalizations.of(context)!.biometricAuthenticationEnabled,
                                   style: GoogleFonts.inter(
                                       fontWeight: FontWeight.w500,
                                       color: Colors.white,
                                       fontSize: 15
                                   ),
                                )),
                              );
                            } else {
                              setState(() {
                                _isToggled = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(AppLocalizations.of(context)!.biometricAuthenticationFailed,
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15
                                  ),
                                )),
                              );
                            }
                          } else {
                            await _saveBiometricState(false); // Save state when disabling
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.biometricAuthenticationDisabled,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15
                                ),
                              )),
                            );
                          }
                        },
                        activeColor: Colors.white,
                        activeTrackColor: NasColors.lightBlue,
                        inactiveTrackColor: Colors.white,
                        inactiveThumbColor: Colors.black,
                      ),


                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_none_sharp , size: 28,color: NasColors.darkBlue,),
                      Text( AppLocalizations.of(context)!.notifications,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isNotificationToggled,
                        onChanged: (bool value) async {
                          setState(() {
                            _isNotificationToggled = value;
                          });

                          await _saveNotificationState(value);

                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.notificationEnabled,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15
                                ),
                              )),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content:  Text(AppLocalizations.of(context)!.notificationsDisabled,
                                 style: GoogleFonts.inter(
                                     fontWeight: FontWeight.w500,
                                     color: Colors.white,
                                     fontSize: 15
                                 ),
                               )),
                            );
                          }
                        },
                        activeColor: Colors.white,
                        activeTrackColor: NasColors.lightBlue,
                        inactiveTrackColor: Colors.white,
                        inactiveThumbColor: Colors.black,
                      ),



                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const LanguageScreen()));
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.language , size: 28,color: NasColors.darkBlue,),
                        const SizedBox(width: 2),
                        Text( AppLocalizations.of(context)!.language,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: NasColors.darkBlue,
                          ),
                        ),
                        const Spacer(),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: NasColors.backGround,

                      title: Text(AppLocalizations.of(context)!.areYouSureToLogout,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(AppLocalizations.of(context)!.cancel,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => SplashScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: Text(AppLocalizations.of(context)!.yes,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),);
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 50,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout , size: 28,color: NasColors.darkBlue,),
                        const SizedBox(width: 2),
                        Text( AppLocalizations.of(context)!.logout,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: NasColors.darkBlue,
                          ),
                        ),
                        const Spacer(),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
