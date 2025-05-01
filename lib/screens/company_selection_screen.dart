import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/base_url_model.dart';
import 'package:nashr/screens/login_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/buttons.dart';

class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  SingletonClass singletonClass = SingletonClass();
  bool _isLoading = false;
  bool _hasBaseUrl = false;
  @override
  void initState() {
    super.initState();
    _checkForSavedBaseUrl();
  }

  void _checkForSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('baseURL');
    setState(() {
      _hasBaseUrl = savedUrl != null && savedUrl.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.zero,
              children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, top: 55),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_hasBaseUrl)
                      IconButton(
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
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: Image.asset("images/site.png"),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Search your Company",
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .pleaseFillAllFields;
                            }
                            return null;
                          },
                          cursorColor: Colors.grey,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                '${AppLocalizations.of(context)!.search}...',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await getBASEURL();
                          } else {}
                        },
                        icon: Icon(
                          Icons.search,
                          size: 25,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  if(singletonClass.baseURLDataList.isNotEmpty && singletonClass.baseURLDataList.first.data != null && singletonClass.baseURLDataList.first.data!.isNotEmpty)...[
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5, // Or a fixed width
                        child: NasButton(
                          text: "Next",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
    ]
                ],
              ),
            ),
          ]),
          if ( _isLoading )
            Center(child:  SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                  'images/loader.json'
              ),
            ),)
        ]),
      ),
    );
  }

  //API CALL
  Future<BaseUrlModel?> getBASEURL() async {
    String? companyCode = _searchController.text;
    setState(() {
      _isLoading = true;
    });

    try {
      var client = http.Client();
      var uri = Uri.parse('https://dev.nashrms.com/api/organization/getStaticUrl/$companyCode');
      var response = await client.get(uri);
      log("Company BASE URL Data: ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var baseURLData = BaseUrlModel.fromJson(responseBody);

        if (baseURLData.data == null || baseURLData.data!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No company found with that code.'))
          );
          return null;
        }
        singletonClass.baseURLDataList.clear();
        singletonClass.baseURLDataList.add(baseURLData);
        singletonClass.baseURL = baseURLData.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('baseURL', baseURLData.data!);
        return baseURLData;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}'))
        );
      }
    } catch (e) {
      log('Error fetching BASE URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong.'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }
}
