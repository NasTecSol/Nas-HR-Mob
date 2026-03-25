import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../request_controller/login_model.dart';
import 'company_selection_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  SingletonClass singletonClass = SingletonClass();
  bool _isTokenSaved = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _animationController.forward().then((value) async {
      final prefs = await SharedPreferences.getInstance();
      final String? url = prefs.getString('baseURL');
      final bool rememberMe = prefs.getBool('rememberMe') ?? false;
      singletonClass.tenantId = url;
      singletonClass.companyName = prefs.getString('companyName');
      if (url == null || url.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompanySelectionScreen()),
        );
        return;
      }

      /// 🔥 NEW LOGIC
      if (rememberMe) {
        final email = prefs.getString("email") ?? '';
        final password = prefs.getString("password") ?? '';

        if (email.isNotEmpty && password.isNotEmpty) {
          bool success = await loginWithCredentials(email, password);

          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainScreen(
                  index: 0,
                  selectedIndex: 0,
                  showBanner: true,
                ),
              ),
            );
            return;
          }
        }
      }
      // fallback → go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 400,
                width: 400,
                child: Lottie.asset('images/splash5.json'),
              ),
              SizedBox(
                    height: 200,
                    width: 280,
                    child: Image.asset('images/N.png'),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Nas",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: NasColors.darkBlue,
                      ),
                    ),
                    TextSpan(
                      text: "HR",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: NasColors.blue,
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
  }


  ///API CALL's
  Future<bool> loginWithCredentials(String email, String password) async {
    try {
      var uuid = const Uuid();
      var v1 = uuid.v1();
      Map data = {
        "password": password,
        "empId": email.toUpperCase(),
        "macAddress": v1
      };
      String body = json.encode(data);
      var uri = Uri.parse('${singletonClass.baseURL}/employee/login');
      final response = await http.post(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        LoginModel loginModel = LoginModel.fromJson(decodedResponse);
        if (loginModel.statusCode == 200 && loginModel.data != null) {
          String token = loginModel.data!.trim();
          decodeJwt(token);
          await _saveTokenLocally(token);
          singletonClass.sendFCMToken();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
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

  Future<void> _saveTokenLocally(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
    singletonClass.token = preferences.getString('token');
    setState(() {
      _isTokenSaved = true;
    });
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
}
