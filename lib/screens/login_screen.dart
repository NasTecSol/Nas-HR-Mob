import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/company_selection_screen.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:local_auth/local_auth.dart';
import '../Controller/language_change_controller.dart';
import '../request_controller/login_model.dart';
import '../widgets/loader.dart';

enum Language { english, arabic }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonEnabled = false;
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  bool _isTokenSaved = false;
  bool _isBiometricEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  String version = '';
  bool _isPasswordValid = false;
  bool _isEmailValid = false;


  @override
  void initState() {
    super.initState();
    _checkToken();
    _checkBiometricStatus();
    loadVersion();
    _email.addListener(_updateButtonState);
    _password.addListener(_updateButtonState);
    _password.addListener(() {
      setState(() {
        _isPasswordValid = _password.text.length >= 6;
      });
    });
    _email.addListener(() {
      setState(() {
        _isEmailValid = _email.text.isNotEmpty;
      });
    });
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled =
          _email.text.isNotEmpty && _password.text.isNotEmpty && _password.text.length >= 6;
    });
  }
  void loadVersion() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        version = 'v${info.version}';
      });
    }
  }

  Future<void> _checkToken() async {
    final preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString('token');

    setState(() {
      _isTokenSaved = token != null && token.isNotEmpty;
    });

    if (token != null && token.isNotEmpty) {
      decodeJwt(token);
    }
  }

  Future<void> _checkBiometricStatus() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = preferences.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _saveTokenLocally(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
    singletonClass.token = preferences.getString('token');
    setState(() {
      _isTokenSaved = true;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final isBiometricsAvailable = await _localAuth.canCheckBiometrics;
      if (isBiometricsAvailable) {
        final isAuthenticated = await _localAuth.authenticate(
          localizedReason: AppLocalizations.of(context)!.pleaseAuthenticate,
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );
        if (isAuthenticated) {
          setState(() {
            isLoading = true;
          });
          final SharedPreferences preferences = await SharedPreferences.getInstance();
          singletonClass.token = preferences.getString('token');
          String? token = preferences.getString('token');
          decodeJwt(token!.trim());
          setState(() {
            isLoading = false;
          });
          await singletonClass.showFaceIDSuccessPopup(context);
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen(index: 0, selectedIndex: 0 , showBanner: true,)),
          );
        } else {
          await singletonClass.showNotSuccessPopup(context);
        }
      } else {
        await singletonClass.showNotSuccessPopup(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during biometric authentication: $e');
      }
      await singletonClass.showNotSuccessPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
              child: Stack(alignment: AlignmentDirectional.center, children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(singletonClass.env == "staging")...[
                          Row(
                            children: [
                              Text(
                                "Dev",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Switch(
                                value: singletonClass.envToggle == "prod",
                                onChanged: (value) {
                                  setState(() {
                                    singletonClass.envToggle = value ? "prod" : "dev";
                                    if(singletonClass.envToggle == "prod" ){
                                      singletonClass.baseURL = "https://www.nashrms.com/api";
                                    } else {
                                      singletonClass.baseURL = "https://dev.nashrms.com/api";
                                    }
                                  });
                                },
                              ),
                              Text(
                                "Prod",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        Spacer(),
                        ],
                        if (singletonClass.companyName != null &&
                            singletonClass.companyName!.isNotEmpty) ...[
                          Container(
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 5),
                          Text(
                            singletonClass.companyName ?? "None",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CompanySelectionScreen()));
                            },
                            icon: Icon(
                              Icons.apartment_outlined,
                              size: 28,
                            )),
                        Consumer<LanguageChangeController>(
                            builder: (context, provider, child) {
                          return PopupMenuButton(
                            color: Colors.white,
                            icon: const Icon(Icons.language_rounded),
                            onSelected: (Language item) {
                              if (Language.english.name == item.name) {
                                provider.changeLanguage(const Locale('en'));
                                SingletonClass().local = 'en';
                              } else {
                                provider.changeLanguage(const Locale('ar'));
                                SingletonClass().local = 'ar';
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<Language>>[
                              const PopupMenuItem(
                                value: Language.english,
                                child: Text("English"),
                              ),
                              const PopupMenuItem(
                                value: Language.arabic,
                                child: Text("العربية"),
                              ),
                            ],
                          );
                        }),

                      ],
                    ),
                    if ( singletonClass.env == "staging") ...[
                      Text(
                        "You're in debug mode",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.lets,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.normal,
                            fontSize: 30,
                            color: NasColors.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.signIn,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: NasColors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.enterTheEmailAndPassword,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.asset(
                        "images/login.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: NasColors.lightGrey,
                      ),
                      child: TextFormField(
                        controller: _email,
                        validator: (value) {
                          if (_isPasswordValid) return null;
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)!
                                .pleaseEnterUsername;
                          }
                          return null;
                        },
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.userName,
                          hintStyle: GoogleFonts.inter(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.person,
                            color: NasColors.icons,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: NasColors.lightGrey,
                      ),
                      child: TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        obscuringCharacter: '•',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                        ),
                        cursorColor: Colors.grey,
                        validator: (value) {
                          if (_isPasswordValid) return null;
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .pleaseEnterPassword;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: NasColors.icons,
                            ),
                          ),
                          hintText: AppLocalizations.of(context)!.password,
                          hintStyle: GoogleFonts.inter(color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: NasColors.icons,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            AppLocalizations.of(context)!.forgetPassword,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Checkbox(
                          activeColor: NasColors.darkBlue,
                          checkColor: Colors.white,
                          value: singletonClass.rememberMe,
                          onChanged: (value) {
                            setState(() {
                              singletonClass.rememberMe = value ?? true;
                            });
                          },
                        ),
                        Text(
                          "Remember Me",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap:  _isButtonEnabled ?(){
                              if (_formKey.currentState!.validate()) {
                                login();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .pleaseFillAllFields),
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            } : null ,
                            child: Container(
                              width: double.infinity,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius:  const BorderRadius.all(Radius.circular(10)),
                                color: _isButtonEnabled
                                    ? NasColors.darkBlue
                                    : Colors.grey,
                              ),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(AppLocalizations.of(context)!.signIn,
                                    style:  GoogleFonts.inter(
                                      fontSize: 19,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        if (_isTokenSaved && _isBiometricEnabled)
                          IconButton(
                            onPressed: _authenticateWithBiometrics,
                            icon: Icon(
                              Icons.fingerprint,
                              size: 40,
                              color: NasColors.darkBlue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      version.isEmpty ? 'Loading version...' : version,
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                        color: Colors.white.withOpacity(0.7),
                        child: Loader()),
                  )
              ]),
            ),
          ],
        ),
      ),
    );
  }
  ///Helper method
  Future<void> handleLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (singletonClass.rememberMe == true) {
      await prefs.setString("email", _email.text);
      await prefs.setString("password", _password.text);
      await prefs.setBool("rememberMe", true);
    } else {
      await prefs.remove("email");
      await prefs.remove("password");
      await prefs.setBool("rememberMe", false);
    }
  }

  /// Login API Call
  Future<void> login() async {
    var uuid = const Uuid();
    var v1 = uuid.v1();
    String email = _email.text.trim().toUpperCase();
    String password = _password.text;
    Map data = {"password": password, "empId": email, "macAddress": v1};

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/employee/login');
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        LoginModel loginModel = LoginModel.fromJson(decodedResponse);
        singletonClass.setLoginModel(loginModel);
        LoginModel? loginResponse = singletonClass.getLoginModel();
        if (loginResponse!.statusCode == 200) {
          LoginModel? data = singletonClass.getLoginModel();
          if (data != null && data.data != null) {
            String jwtToken = data.data!.trim();
            decodeJwt(jwtToken);
            await singletonClass.getNotifications();
            singletonClass.getCompanyNotificationData();
            await _saveTokenLocally(data.data!.trim());
            setState(() {
              isLoading = false;
            });
            singletonClass.sendFCMToken();
            await singletonClass.showSuccessPopup(context);
            await singletonClass.getEmployeeData();
            await handleLogin();
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainScreen(
                    index: 0,
                    selectedIndex: 0,
                    showBanner: true,
                      )),
            );
          }
        } else if (loginResponse.statusCode == 400 || loginResponse.statusCode == 500) {
          setState(() {
            isLoading = false;
          });
          await singletonClass.showNotSuccessPopup(context);
        } else {
          setState(() {
            isLoading = false;
          });
          await singletonClass.showNotSuccessPopup(context);
        }
      } else if (response.statusCode == 405 || response.statusCode == 502) {
        setState(() {
          isLoading = false;
        });
        await singletonClass.showNotSuccessPopup(context);
      } else {
        setState(() {
          isLoading = false;
        });
        await singletonClass.showNotSuccessPopup(context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      await singletonClass.showNotSuccessPopup(context);
    }
  }

  void decodeJwt(String token) {
    List<String> parts = token.split('.');
    for (int i = 0; i < parts.length; i++) {
      while (parts[i].length % 4 != 0) {
        parts[i] += '=';
      }
    }
    String payload = parts[1];
    String decodedPayload = utf8.decode(base64Url.decode(payload));
    Map<String, dynamic> payloadJson = json.decode(decodedPayload);
    JWTData jwtData = JWTData.fromJson(payloadJson);
    singletonClass.setJWTModel(jwtData);
  }

}
