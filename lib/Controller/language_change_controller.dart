import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController extends ChangeNotifier {
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;

  Future<void> loadLanguage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? languageCode = sp.getString("Language");

    if (languageCode != null) {
      _appLocale = Locale(languageCode);
    } else {
      // Default to English if no language is saved in SharedPreferences
      _appLocale = const Locale('en');
    }

    notifyListeners();
  }

  void changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (type == const Locale("en")) {
      _appLocale = type;
      await sp.setString("Language", 'en');
    } else {
      _appLocale = type;
      await sp.setString("Language", 'ar');
    }

    notifyListeners();
  }
}
