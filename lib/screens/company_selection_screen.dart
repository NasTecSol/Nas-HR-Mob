import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/base_url_model.dart';
import 'package:nashr/screens/login_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/buttons.dart';
import '../widgets/loader.dart';

class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  SingletonClass singletonClass = SingletonClass();
  final bool _isLoading = false;
  bool _hasBaseUrl = false;

  List<Data> _suggestions = [];
  String? _selectedTenantId;

  @override
  void initState() {
    super.initState();
    _checkForSavedBaseUrl();
    _searchController.addListener(() {
      getTenantSuggestions(_searchController.text);
    });
  }

  void _checkForSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('baseURL');
    singletonClass.tenantLogo = prefs.getString('organizationLogo');
    setState(() {
      _hasBaseUrl = savedUrl != null && savedUrl.isNotEmpty;
    });
  }

  Future<void> getTenantSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }

    try {
      final uri = Uri.parse('${singletonClass.baseURL}/organization/getOrganizationTenancy?tenantName=$query');
      final response = await http.get(uri);
      if (kDebugMode) {
        print("tanent response ${response.body}");
      }
      if (response.statusCode == 200) {
        final result = TenantIdModel.fromJson(json.decode(response.body));
        if (result.data != null && result.data!.tenantName != null) {
          setState(() {
            _suggestions = [result.data!];
          });
        } else {
          setState(() => _suggestions.clear());
        }
      }
    } catch (e) {
      log('Suggestion fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.29,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 50 , right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (_hasBaseUrl)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Spacer(),
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
                                ],
                              ),
                            ],
                          ],
                        ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.currentOrganization,
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: (singletonClass.tenantLogo != null && singletonClass.tenantLogo!.isNotEmpty)
                                  ? Image.network(
                                singletonClass.tenantLogo.toString(),
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('images/site.png');
                                },
                              )
                                  : Image.asset('images/site.png'),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              singletonClass.companyName ?? "None",
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),]))
                    ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 25 , right: 30),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                           Text(
                              AppLocalizations.of(context)!.searchYourCompany,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.pleaseFillAllFields;
                                    }
                                    return null;
                                  },
                                  cursorColor: Colors.grey,
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: '${AppLocalizations.of(context)!.search}...',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    getTenantSuggestions(_searchController.text);
                                  }
                                },
                                icon: Icon(
                                  Icons.search,
                                  size: 25,
                                  color: NasColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (_suggestions.isNotEmpty)
                            ..._suggestions.map((suggestion) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  elevation: 1,
                                  child: CheckboxListTile(
                                    activeColor: NasColors.darkBlue,
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    title: Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Image.network(
                                            suggestion.tenantLogo ?? '',
                                            errorBuilder: (_, __, ___) {
                                              return Image.asset('images/site.png');
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            suggestion.tenantName ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    value:
                                    _selectedTenantId ==
                                        suggestion.tenantId.toString(),
                                    onChanged: (bool? selected) async {
                                      if (selected == true) {
                                        final prefs =
                                        await SharedPreferences.getInstance();

                                        await prefs.setString(
                                          'baseURL',
                                          suggestion.tenantId.toString(),
                                        );

                                        await prefs.setString(
                                          'companyName',
                                          suggestion.tenantName.toString(),
                                        );

                                        await prefs.setString(
                                          'organizationLogo',
                                          suggestion.tenantLogo.toString(),
                                        );

                                        singletonClass.tenantId =
                                            prefs.getString('baseURL') ?? '';

                                        singletonClass.companyName =
                                            prefs.getString('companyName') ?? '';

                                        singletonClass.tenantLogo =
                                            prefs.getString('organizationLogo') ?? '';

                                        singletonClass.tenantIDDataList.clear();

                                        singletonClass.tenantIDDataList.add(
                                          TenantIdModel(data: suggestion),
                                        );

                                        setState(() {
                                          _selectedTenantId =
                                              suggestion.tenantId.toString();
                                          _suggestions.clear();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            }),

                          const SizedBox(height: 20),

                          // Next Button
                          if (_selectedTenantId != null)
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: NasButton(
                                  text: AppLocalizations.of(context)!.next,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
            Loader(),
          ],
        ),
      ),
    );
  }
}
