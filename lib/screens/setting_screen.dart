import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../UTILS/auth_services.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isToggled = false ;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  // Load the state from SharedPreferences
  Future<void> _loadBiometricState() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = preferences.getBool('biometric_enabled') ?? false;
    });
  }

  // Save the state to SharedPreferences
  Future<void> _saveBiometricState(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('biometric_enabled', value);
  }
  final AuthService _authService = AuthService();

  logout() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                          height: 50,
                          width: 50,
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
                          fontSize: 25,
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
                        color: Colors.grey.withOpacity(0.5),
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
                            // Handle enabling biometric authentication
                            if (!(await _authService.checkBiometricAvailability())) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please set up biometrics in your device settings')),
                              );
                              setState(() {
                                _isToggled = false; // Reset toggle if biometrics aren't available
                              });
                              return; // Skip further actions if biometrics aren't set up
                            }

                            bool isAuthenticated = await _authService.authenticateWithBiometrics(context);
                            if (isAuthenticated) {
                              setState(() {
                                _isBiometricEnabled = value;
                                _saveBiometricState(value);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Biometric authentication enabled')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Biometric authentication failed')),
                              );
                              setState(() {
                                _isToggled = false; // Reset toggle if authentication fails
                              });
                            }
                          } else {
                            // Handle disabling biometric authentication
                            // Implement any necessary actions for turning off biometrics
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric authentication disabled')),
                            );
                          }
                        },
                        activeColor: NasColors.darkBlue,
                        activeTrackColor:NasColors.icons ,
                        inactiveTrackColor: NasColors.lightBlue, // Color of the track when inactive
                        inactiveThumbColor: Colors.white, // Color of the thumb when inactive
                      ),

                    ],
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SplashScreen()));
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
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout , size: 28,color: NasColors.darkBlue,),
                        SizedBox(width: 2),
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
