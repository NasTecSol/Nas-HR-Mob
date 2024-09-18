import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Controller/language_change_controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late LanguageChangeController _languageController;
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _languageController =
        Provider.of<LanguageChangeController>(context, listen: false);
    _selectedLocale = _languageController.appLocale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NasColors.backGround,
        body: ListView(
          children: [ Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Container(
                            height: 50,
                            width: 50,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                        child: Text(
                          AppLocalizations.of(context)!.language,
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: NasColors.darkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('English',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                    leading: Radio<Locale>(
                      activeColor: NasColors.darkBlue,
                      hoverColor: Colors.black,
                      value: const Locale('en'),
                      groupValue: _selectedLocale,
                      onChanged: (Locale? value) {
                        setState(() {
                          _selectedLocale = value;
                        });
                        if (_selectedLocale != null) {
                          _languageController.changeLanguage(_selectedLocale!);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('العربية',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        )),
                    leading: Radio<Locale>(
                      activeColor: NasColors.darkBlue,
                      hoverColor: Colors.black,
                      value: const Locale('ar'),
                      groupValue: _selectedLocale,
                      onChanged: (Locale? value) {
                        setState(() {
                          _selectedLocale = value;
                        });
                        if (_selectedLocale != null) {
                          _languageController.changeLanguage(_selectedLocale!);

                        }
                      },
                    ),
                  ),
                ]),
          ),
        ]));
  }
}
