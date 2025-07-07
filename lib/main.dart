import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'Controller/language_change_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  SingletonClass().setEnvironment(env);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SingletonClass().init();
  MapboxOptions.setAccessToken("pk.eyJ1IjoibmFzdGVjc29sIiwiYSI6ImNtMm9qc3lzMTBnamMya3F6cmJsbWZ5MmsifQ.ExjMBEpuTJDstkVQTPeJTA");

  try {
    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    // Get the FCM token and set it in SingletonClass
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      SingletonClass().setFCMToken(fcmToken);
      print('FCM TOKEN: $fcmToken');
      print('FCM TOKEN from Singleton: ${SingletonClass().fcmToken}');
    }

    // For Apple platforms, ensure the APNS token is available
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      print('APNS Token: $apnsToken');
    }

    // Automatically initialize messaging on app startup
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Received notification: ${message.notification?.title} - ${message.notification?.body}');
      }
    });
  } catch (e) {
    print('Error setting up Firebase Messaging: $e');
  }

  // Initialize language controller
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
