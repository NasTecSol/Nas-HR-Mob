
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Controller/language_change_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SingletonClass().init();
  MapboxOptions.setAccessToken(const String.fromEnvironment("ACCESS_TOKEN"));

  try {
    // Request notification permissions
    final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

    // Get the FCM token and set it in NewSingleton
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      SingletonClass().setFCMToken(fcmToken);
      print('FCM TOKEN $fcmToken');
      print('FCM TOKEN /// ${SingletonClass().fcmToken}');
    }

    // For Apple platforms, ensure the APNS token is available
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // You can use the APNS token for Apple devices
    }

    // Automatically initialize messaging on app startup
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Received notification: ${message.notification?.title} - ${message.notification?.body}');
        // Handle the notification in your app (e.g., show a dialog or update UI)
      }
    });

  } catch (e) {
    print('Error setting up Firebase Messaging: $e');
  }

  // SharedPreferences sp = await SharedPreferences.getInstance();

  LanguageChangeController languageController = LanguageChangeController();
  await languageController.loadLanguage(); // Load the selected language

  runApp(
    MultiProvider(
      providers:[
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
            home:   const SplashScreen(),
          );
        },
      ),
    ),
  );
}
