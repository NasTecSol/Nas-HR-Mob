import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/company_selection_screen.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/widgets/loader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Controller/language_change_controller.dart';
import '../request_controller/login_model.dart';

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
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _email.text.isNotEmpty &&
          _password.text.isNotEmpty &&
          _password.text.length >= 6;
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
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
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
          final SharedPreferences preferences =
              await SharedPreferences.getInstance();
          singletonClass.token = preferences.getString('token');
          String? token = preferences.getString('token');
          decodeJwt(token!.trim());
          setState(() {
            isLoading = false;
          });
          await singletonClass.showFaceIDSuccessPopup(context);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(
                index: 0,
                selectedIndex: 0,
                showBanner: true,
              ),
            ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          /// 3D Ambient Decorative Background Spheres
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NasColors.darkBlue.withOpacity(0.18),
                    NasColors.lightBlue.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    NasColors.lightBlue.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// Form Body
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  /// Top Glassmorphic Utility Controls (Staging, Company Chip, Language Selector)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (singletonClass.env == "staging") ...[
                        Row(
                          children: [
                            Text(
                              "Dev",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Switch(
                              activeColor: NasColors.darkBlue,
                              value: singletonClass.envToggle == "prod",
                              onChanged: (value) {
                                setState(() {
                                  singletonClass.envToggle =
                                      value ? "prod" : "dev";
                                  if (singletonClass.envToggle == "prod") {
                                    singletonClass.baseURL =
                                        "https://www.nashrms.com/api";
                                  } else {
                                    singletonClass.baseURL =
                                        "https://dev.nashrms.com/api";
                                  }
                                });
                              },
                            ),
                            Text(
                              "Prod",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],

                      /// Company Chip
                      if (singletonClass.companyName != null &&
                          singletonClass.companyName!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                singletonClass.companyName ?? "None",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],

                      /// Company Selection Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CompanySelectionScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.apartment_rounded,
                            size: 22,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      /// Language Switcher Menu
                      Consumer<LanguageChangeController>(
                        builder: (context, provider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: PopupMenuButton<Language>(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              icon: Icon(
                                Icons.language_rounded,
                                size: 22,
                                color: NasColors.darkBlue,
                              ),
                              onSelected: (Language item) {
                                if (Language.english.name == item.name) {
                                  provider
                                      .changeLanguage(const Locale('en'));
                                  SingletonClass().local = 'en';
                                } else {
                                  provider
                                      .changeLanguage(const Locale('ar'));
                                  SingletonClass().local = 'ar';
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<Language>>[
                                PopupMenuItem(
                                  value: Language.english,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.translate_rounded,
                                          size: 18, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        "English",
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: Language.arabic,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.translate_rounded,
                                          size: 18, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text(
                                        "العربية",
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500),
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
                  ),

                  if (singletonClass.env == "staging") ...[
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          "You're in debug mode",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  /// Header Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lets,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontSize: 28,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.signIn,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: NasColors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.enterTheEmailAndPassword,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Elevated 3D Banner Container
                  Center(
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NasColors.darkBlue.withOpacity(0.09),
                        boxShadow: [
                          BoxShadow(
                            color: NasColors.darkBlue.withOpacity(0.08),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: -2,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Image.asset(
                        "images/login.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// Main 3D Card Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Email / Username Input Field (3D Style)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF1F5F9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                            cursorColor: NasColors.darkBlue,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: NasColors.darkBlue,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.userName,
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey.shade500, fontSize: 14),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: NasColors.darkBlue,
                                  size: 20,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: NasColors.darkBlue.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// Password Input Field (3D Style)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF1F5F9),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _password,
                            obscureText: _obscurePassword,
                            obscuringCharacter: '•',
                            cursorColor: NasColors.darkBlue,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: NasColors.darkBlue,
                            ),
                            validator: (value) {
                              if (_isPasswordValid) return null;
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .pleaseEnterPassword;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.password,
                              hintStyle: GoogleFonts.inter(
                                  color: Colors.grey.shade500, fontSize: 14),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: NasColors.darkBlue,
                                  size: 20,
                                ),
                              ),
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
                                  color: Colors.grey.shade600,
                                  size: 22,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: NasColors.darkBlue.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Forgot Password & Remember Me Row
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.forgetPassword,
                                style: GoogleFonts.inter(
                                  color: NasColors.darkBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                activeColor: NasColors.darkBlue,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                value: singletonClass.rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    singletonClass.rememberMe =
                                        value ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  singletonClass.rememberMe =
                                      !(singletonClass.rememberMe ?? false);
                                });
                              },
                              child: Text(
                                "Remember Me",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 3D Action Buttons (Sign In + Biometric Action)
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _isButtonEnabled
                                    ? () {
                                        if (_formKey.currentState!
                                            .validate()) {
                                          login();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  AppLocalizations.of(context)!
                                                      .pleaseFillAllFields),
                                              duration:
                                                  const Duration(seconds: 4),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: _isButtonEnabled
                                        ? LinearGradient(
                                            colors: [
                                              NasColors.darkBlue,
                                              NasColors.lightBlue,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: _isButtonEnabled
                                        ? null
                                        : Colors.grey.shade300,
                                    boxShadow: _isButtonEnabled
                                        ? [
                                            BoxShadow(
                                              color: NasColors.darkBlue
                                                  .withOpacity(0.35),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.signIn,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_isTokenSaved && _isBiometricEnabled) ...[
                              const SizedBox(width: 12),
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: NasColors.darkBlue.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _authenticateWithBiometrics,
                                  icon: Icon(
                                    Icons.fingerprint_rounded,
                                    size: 28,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Version Info Display
                  Center(
                    child: Text(
                      version.isEmpty ? 'Loading version...' : version,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Loading Overlay
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Loader(),
              ),
            ),
        ],
      ),
    );
  }

  /// Helper method for Remember Me
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
                ),
              ),
            );
          }
        } else if (loginResponse.statusCode == 400 ||
            loginResponse.statusCode == 500) {
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
