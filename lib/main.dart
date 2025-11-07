import 'dart:developer';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nashr/screens/socket_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Controller/language_change_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SingletonClass().init();
  await NotificationService.init();

  if (kDebugMode) {
    print("App is running in Debug mode.");
    SingletonClass().baseURL = "https://www.nashrms.com/api";
    print("Debug url ${SingletonClass().baseURL}");
  }

  if (kReleaseMode) {
    SingletonClass().baseURL = "https://www.nashrms.com/api";
  }

  if (kProfileMode) {
    log("App is running in Profile mode.");
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MapboxOptions.setAccessToken("pk.eyJ1IjoibmFzdGVjc29sIiwiYSI6ImNtMm9qc3lzMTBnamMya3F6cmJsbWZ5MmsifQ.ExjMBEpuTJDstkVQTPeJTA");

  final prefs = await SharedPreferences.getInstance();
  SingletonClass().tenantId = prefs.getString('baseURL') ?? '';
  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print('FCM TOKEN: $fcmToken');
    }
    if (fcmToken != null) {
      SingletonClass().setFCMToken(fcmToken);
      if (kDebugMode) {
        print('FCM TOKEN: $fcmToken');
        print('FCM TOKEN from Singleton: ${SingletonClass().fcmToken}');
      }
    }
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      if (kDebugMode) {
        print('APNS Token: $apnsToken');
      }
    }
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        if (kDebugMode) {
          print('Received notification: ${message.notification?.title} - ${message.notification?.body}');
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print('Error setting up Firebase Messaging: $e');
    }
  }

  LanguageChangeController languageController = LanguageChangeController();
  await languageController.loadLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageController),
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {
          return  MyApp(provider: provider);
        },
      ),
    ),
  );
  initBackgroundFetch();
}

/// ✅ Add your App wrapper here so we can manage socket lifecycle
class MyApp extends StatefulWidget {
  final LanguageChangeController provider;
  const MyApp({super.key, required this.provider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    SocketService().disposeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: widget.provider.appLocale,
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
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings,
      onDidReceiveNotificationResponse: (NotificationResponse response){
      }
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('notifications_enabled') ?? true;

    if (!isEnabled) return;

    final currentScreen = SingletonClass().activeScreen;
    if (currentScreen == "SlackScreen" || currentScreen == "SlackChatDetailScreen") {
      print("🔕 Notification suppressed on Slack screens");
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'socket_channel',
      'Socket Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(0, title, body, notificationDetails);
  }
}

///background mode method
Future<void> backgroundFetchTask(String taskId) async {
  final locale = WidgetsBinding.instance.window.locale.languageCode;
  try {
    SocketService().initializeSocket(
      "${SingletonClass().tenantId}", locale,
    );
  } catch (e) {
    debugPrint("❌ Background fetch error: $e");
  }
  BackgroundFetch.finish(taskId);
}
void initBackgroundFetch() {
  BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
    ),
    backgroundFetchTask,
  ).then((status) {
    debugPrint("[BackgroundFetch] Configured: $status");
  }).catchError((e) {
    debugPrint("[BackgroundFetch] ERROR: $e");
  });
  BackgroundFetch.registerHeadlessTask(backgroundFetchTask);
}
