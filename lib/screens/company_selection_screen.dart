import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/base_url_model.dart';
import 'package:nashr/screens/login_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompanySelectionScreen extends StatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  State<CompanySelectionScreen> createState() =>
      _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  SingletonClass singletonClass = SingletonClass();
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
      final uri = Uri.parse(
          '${singletonClass.baseURL}/organization/getOrganizationTenancy?tenantName=$query');
      final response = await http.get(uri);
      if (kDebugMode) {
        print("tenant response ${response.body}");
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            /// Curved Gradient Header (Matching Create Leave Request style)
            Container(
              padding: const EdgeInsets.only(
                  top: 50, left: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NasColors.darkBlue,
                    NasColors.lightBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: NasColors.darkBlue.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// Top Navigation Row (Back Button & Dev/Prod Switch)
                  Row(
                    children: [
                      /// Staging Environment Switch
                      if (singletonClass.env == "staging") ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Dev",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Switch(
                                activeColor: Colors.white,
                                activeTrackColor:
                                    Colors.white.withOpacity(0.4),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Selected Company Information Display inside Header
                  Row(
                    children: [
                      if (_hasBaseUrl)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white.withOpacity(0.18),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      const SizedBox(width: 30),
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: (singletonClass.tenantLogo != null &&
                                singletonClass.tenantLogo!.isNotEmpty)
                            ? Image.network(
                                singletonClass.tenantLogo.toString(),
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('images/site.png');
                                },
                              )
                            : Image.asset('images/site.png'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.currentOrganization,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              singletonClass.companyName ?? "None",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Below Design (Search & Results - Text Removed)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: NasColors.darkBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.searchYourCompany,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// 3D Search Field Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _searchController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .pleaseFillAllFields;
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
                                hintText:
                                    '${AppLocalizations.of(context)!.search}...',
                                hintStyle: GoogleFonts.inter(
                                    color: Colors.grey.shade500,
                                    fontSize: 14),
                                prefixIcon: Icon(
                                  Icons.business_rounded,
                                  color: NasColors.darkBlue.withOpacity(0.7),
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(
                                              () => _suggestions.clear());
                                        },
                                        icon: Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.grey.shade500,
                                          size: 18,
                                        ),
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
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
                                    color:
                                        NasColors.darkBlue.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              getTenantSuggestions(_searchController.text);
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: NasColors.darkBlue,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: NasColors.darkBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    /// Suggestions Result List
                    Expanded(
                      child: _suggestions.isNotEmpty
                          ? ListView.builder(
                        padding: EdgeInsets.only(top: 30),
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                final isSelected = _selectedTenantId ==
                                    suggestion.tenantId.toString();

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? NasColors.darkBlue
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? NasColors.darkBlue
                                                .withOpacity(0.12)
                                            : Colors.black.withOpacity(0.04),
                                        blurRadius: isSelected ? 12 : 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CheckboxListTile(
                                    activeColor: NasColors.darkBlue,
                                    tileColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    title: Row(
                                      children: [
                                        Container(
                                          height: 42,
                                          width: 42,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.shade50,
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: Image.network(
                                            suggestion.tenantLogo ?? '',
                                            errorBuilder: (_, __, ___) {
                                              return Image.asset(
                                                  'images/site.png');
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            suggestion.tenantName ?? '',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: NasColors.darkBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    value: isSelected,
                                    onChanged: (bool? selected) async {
                                      if (selected == true) {
                                        final prefs =
                                            await SharedPreferences
                                                .getInstance();

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
                                            prefs.getString('companyName') ??
                                                '';

                                        singletonClass.tenantLogo =
                                            prefs.getString(
                                                    'organizationLogo') ??
                                                '';

                                        singletonClass.tenantIDDataList
                                            .clear();

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
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),

                    /// 3D Next Action Button
                    if (_selectedTenantId != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                NasColors.darkBlue,
                                NasColors.lightBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: NasColors.darkBlue.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.next,
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
