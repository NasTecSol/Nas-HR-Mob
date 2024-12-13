import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/buttons.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UrlScreen extends StatefulWidget {
  const UrlScreen({super.key});

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  TextEditingController baseUrl = TextEditingController();
  SingletonClass singletonClass = SingletonClass();
  saveBaseURL(String url) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('baseURL', url);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:  const EdgeInsets.all (10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/login.png', // replace 'your_image.png' with the path to your image asset
                  width: 100,  // adjust width as needed
                  height: 100, // adjust height as needed
                ),
                const SizedBox(
                  height:10,
                ),
                TextField(
                  controller: baseUrl,
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: NasColors.darkBlue,
                        width: 3,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelText: 'Base URL',
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
                NasButton(text: "OK", onPressed: () async {
                  singletonClass.setBaseURL(baseUrl.text);
                  await saveBaseURL(baseUrl.text);
                  Navigator.pop(context);
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
