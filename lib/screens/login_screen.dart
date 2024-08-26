import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/buttons.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:uuid/uuid.dart';

import '../request_controller/login_model.dart';
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.only(top: 80), children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let's",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontSize: 30,
                          color: NasColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Sign In",
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
                    "Enter the email & password your administrator provided you with",
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
                    child: Image.asset("images/login.png",
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
                        if (value == null) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterAUsername;
                        }
                        return null;
                      },
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        prefixIcon:  Icon(
                          Icons.person,
                          color:NasColors.icons,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      obscuringCharacter: '*',
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        prefixIcon:  Icon(
                          Icons.lock_outline,
                          color:NasColors.icons,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
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
                          "Forgot password?",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Text(
                          _obscurePassword ? "Show password" : "Hide password",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  NasButton(text: "Sign In", onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      login();

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .pleaseFillAllFields),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  })
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
  //Login API Call
  Future login() async {
    var uuid = const Uuid();
    var v1 = uuid.v1();
    print(v1);
    String email = _email.text;
    String password = _password.text;
    Map data = {"password": password , "empId": email ,"macAddress":v1};
    print(data);

    String body = json.encode(data);
    var uri = Uri.parse('${singletonClass.baseURL}/employee/login');
    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        LoginModel loginModel = LoginModel.fromJson(decodedResponse);
        singletonClass.setLoginModel(loginModel);
        LoginModel? loginResponse = singletonClass.getLoginModel();
        if (loginResponse!.statusCode == 200) {
          LoginModel? data = singletonClass.getLoginModel();
          if (data != null && data.data != null) {
            String jwtToken = data.data!.trim(); // Ensure the token is not null and trim any leading/trailing whitespace
            decodeJwt(jwtToken);
            singletonClass.getEmployeeData();
            await QuickAlert.show(
              autoCloseDuration: const Duration(seconds: 2),
              showCancelBtn: false,
              showConfirmBtn: false,
              context: context,
              title: AppLocalizations.of(context)!.loginSuccessful,
              type: QuickAlertType.success,
            );
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MainScreen()));
          }
        } else if (loginResponse.statusCode == 400) {
          QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 5),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)!.phoneNumberOrPassCode,
            type: QuickAlertType.error,
          );
        } else {
          print('Error: ${loginResponse.statusCode}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  //Decoding Token Data Here
  void decodeJwt(String token) {
    List<String> parts = token.split('.');

    // Ensure parts have correct length by adding padding if necessary
    for (int i = 0; i < parts.length; i++) {
      while (parts[i].length % 4 != 0) {
        parts[i] += '=';
      }
    }

    String header = parts[0];
    String payload = parts[1];
    // Signature is not used for decoding in this example.

    String decodedHeader = utf8.decode(base64Url.decode(header));
    String decodedPayload = utf8.decode(base64Url.decode(payload));

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
