import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:provider/provider.dart';
import 'Controller/language_change_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SingletonClass().init();

  LanguageChangeController languageController = LanguageChangeController();
  await languageController.loadLanguage();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageController),
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {
          return MaterialApp(
            locale: provider.appLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    ),
  );
}