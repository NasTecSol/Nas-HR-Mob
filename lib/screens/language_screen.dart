import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:provider/provider.dart';
import 'package:nashr/l10n/app_localizations.dart';
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.language,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required String subtitle,
    required Locale locale,
    required IconData icon,
  }) {
    final bool isSelected = _selectedLocale?.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocale = locale;
          SingletonClass().local = locale.languageCode;
        });
        _languageController.changeLanguage(locale);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? NasColors.darkBlue
                : NasColors.darkBlue.withOpacity(0.06),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? NasColors.darkBlue.withOpacity(0.12)
                    : NasColors.darkBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? NasColors.darkBlue : Colors.grey.shade600,
                size: 24,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: NasColors.darkBlue,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            trailing: Radio<Locale>(
              activeColor: NasColors.darkBlue,
              value: locale,
              groupValue: _selectedLocale,
              onChanged: (Locale? value) {
                if (value != null) {
                  setState(() {
                    _selectedLocale = value;
                    SingletonClass().local = value.languageCode;
                  });
                  _languageController.changeLanguage(value);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _buildLanguageTile(
                  title: 'English',
                  subtitle: 'English (US)',
                  locale: const Locale('en'),
                  icon: Icons.language_rounded,
                ),
                _buildLanguageTile(
                  title: 'العربية',
                  subtitle: 'Arabic (العربية)',
                  locale: const Locale('ar'),
                  icon: Icons.translate_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
