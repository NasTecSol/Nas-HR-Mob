import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/widgets/buttons.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                        if (value == null ||
                            !value.contains('@') ||
                            !value.contains('.com')) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterAValidEmailAddress;
                        }
                        return null;
                      },
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        prefixIcon:  Icon(
                          Icons.email_outlined,
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
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const MainScreen()));
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
}
