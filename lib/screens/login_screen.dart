import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/company_selection_screen.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/buttons.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:local_auth/local_auth.dart';
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
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  bool _isTokenSaved = false;
  bool _isBiometricEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  String version = '';

  @override
  void initState() {
    super.initState();
    _checkToken();
    _checkBiometricStatus();
    loadVersion();
  }

  void loadVersion() async {
    if(Platform.isAndroid || Platform.isIOS){
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

    // If a token is found, decode it
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
    setState(() {
      _isTokenSaved = true;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final isBiometricsAvailable = await _localAuth.canCheckBiometrics;
      if (isBiometricsAvailable) {
        final isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to access this feature',
          options: const AuthenticationOptions(
            biometricOnly: true,
          ),
        );
        if (isAuthenticated) {
          setState(() {
            isLoading = true ;
          });
          final SharedPreferences preferences = await SharedPreferences.getInstance();
          String? token = preferences.getString('token');
          decodeJwt(token!.trim());
          await singletonClass.getEmployeeData();
          await singletonClass.getCompaniesData();
          await singletonClass.getUISettingsData();
          singletonClass.getEmployeeData();
          await singletonClass.getClockingData();
          await singletonClass.getBranchData();
          singletonClass.getCompanyData();
          singletonClass.getRemoteAttendanceData();
          await singletonClass.getEmployeeAttendanceData();
          singletonClass.getNotifications();
          singletonClass.sendFCMToken();
          setState(() {
            isLoading = false ;
          });
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometrics not available or not enrolled'),
          ),
        );
      }
    } catch (e) {
      print('Error during biometric authentication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred during authentication'),
        ),
      );
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
              padding: const EdgeInsets.only(left: 20.0 , right: 20 , top: 10),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [ Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (kDebugMode)
                          Text("You're in Debug mode"),
                        IconButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> CompanySelectionScreen()));
                        }, icon: Icon(Icons.apartment_outlined,
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
                                  } else {
                                    provider.changeLanguage(const Locale('ar'));
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
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterUsername;
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
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.transparent),
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
                    obscuringCharacter: '*',
                    cursorColor: Colors.grey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterPassword;
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
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.transparent),
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
                      ],
                    ),
                    NasButton(
                      text: AppLocalizations.of(context)!.signIn,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(""),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                    ),
                    if (_isTokenSaved && _isBiometricEnabled)
                      IconButton(
                        onPressed: _authenticateWithBiometrics,
                        icon: Icon(
                          Icons.fingerprint,
                          size: 50,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    Text(
                      version.isEmpty ? 'Loading version...' : version,
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                  if (isLoading)
                    Center(
                      child:
                      SizedBox(
                      height: 200,
                      width: 200,
                      child: Lottie.asset(
                          'images/loader.json'
                      ),
                    ),)
        ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login API Call
  Future<void> login() async {
    var uuid = const Uuid();
    var v1 = uuid.v1();
    print(v1);
    String email = _email.text;
    String password = _password.text;
    Map data = {"password": password, "empId": email, "macAddress": v1};
    print(data);
    print("shared preference id ${singletonClass.tenantId}");

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/employee/login');
    print(uri);
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      print(singletonClass.getHeaders());
      print(response.body);
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
            singletonClass.sendFCMToken();
            await _saveTokenLocally(data.data!.trim());
            setState(() {
              isLoading = false;
            });
            await QuickAlert.show(
              autoCloseDuration: const Duration(seconds: 2),
              showCancelBtn: false,
              showConfirmBtn: false,
              context: context,
              title: AppLocalizations.of(context)!.loginSuccess,
              type: QuickAlertType.success,
            );
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        } else if (loginResponse.statusCode == 400) {
          setState(() {
            isLoading = false;
          });
          QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 5),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title:  AppLocalizations.of(context)!.passwordOrPhoneNo,
            type: QuickAlertType.error,
          );
        } else {
          print('Error: ${loginResponse.statusCode}');
        }
      } else if (response.statusCode == 405 || response.statusCode == 502) {
        setState(() {
          isLoading = false;
        });
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          text: AppLocalizations.of(context)!.tryAgain,
          type: QuickAlertType.error,
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title:  AppLocalizations.of(context)!.internalServerError,
        text:  AppLocalizations.of(context)!.tryAgain,
        type: QuickAlertType.error,
      );
    }
  }
  // Decoding Token Data Here
  void decodeJwt(String token) {
    List<String> parts = token.split('.');
    for (int i = 0; i < parts.length; i++) {
      while (parts[i].length % 4 != 0) {
        parts[i] += '=';
      }
    }
    String header = parts[0];
    String payload = parts[1];
    String decodedHeader = utf8.decode(base64Url.decode(header));
    String decodedPayload = utf8.decode(base64Url.decode(payload));
    print('Full Payload: $decodedPayload');
    Map<String, dynamic> headerJson = json.decode(decodedHeader);
    Map<String, dynamic> payloadJson = json.decode(decodedPayload);
    JWTData jwtData = JWTData.fromJson(payloadJson);
    singletonClass.setJWTModel(jwtData);
    JWTData? loginJWTData = singletonClass.getJWTModel();
    print('${loginJWTData?.employeeId}');
    print('Header: $headerJson');
    print('Payload: $payloadJson');
  }
}
