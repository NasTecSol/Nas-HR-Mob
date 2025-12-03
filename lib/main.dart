import 'dart:developer';
import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nashr/screens/socket_screen.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'enviroment/enviroment.dart';
import 'l10n/app_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nashr/screens/splash_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Controller/language_change_controller.dart';
import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final env = await Environment.detectEnv();
    await SingletonClass().init();
    await NotificationService.init();

    if (env == "staging") {
      debugPrint("App is running in Debug mode.");
      SingletonClass().baseURL = "https://dev.nashrms.com/api";
    }
    if ( env == "production") {
      SingletonClass().baseURL = "https://dev.nashrms.com/api";
    }

    if (kProfileMode) {
      log("App is running in Profile mode.");
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    MapboxOptions.setAccessToken(
        "pk.eyJ1IjoibmFzdGVjc29sIiwiYSI6ImNtMm9qc3lzMTBnamMya3F6cmJsbWZ5MmsifQ.ExjMBEpuTJDstkVQTPeJTA"
    );

    final prefs = await SharedPreferences.getInstance();
    SingletonClass().tenantId = prefs.getString('baseURL') ?? '';

    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        SingletonClass().setFCMToken(fcmToken);
      }

      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && kDebugMode) {
        debugPrint('APNS Token: $apnsToken');
      }

      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null && kDebugMode) {
          debugPrint('Notification: ${message.notification?.title}');
        }
      });
    } catch (e) {
      if (kDebugMode) print('Firebase Messaging Error: $e');
    }

    LanguageChangeController languageController = LanguageChangeController();
    await languageController.loadLanguage();

    // NEW RELIC
    var appToken = "";
    if (Platform.isIOS) {
      appToken = 'AA796b590654035b9f72fb84c72e39173ffbcc165b-NRMA';
    } else if (Platform.isAndroid) {
      appToken = 'AA54e627aef512b22489a6d1abf365e9ab63e294f6-NRMA';
    }

    Config config = Config(
      accessToken: appToken,
      analyticsEventEnabled: true,
      webViewInstrumentation: true,
      networkErrorRequestEnabled: true,
      networkRequestEnabled: true,
      crashReportingEnabled: true,
      interactionTracingEnabled: true,
      httpResponseBodyCaptureEnabled: true,
      loggingEnabled: true,
      printStatementAsEventsEnabled: true,
      httpInstrumentationEnabled: true,
    );

    // Start New Relic (NO runApp inside)
    await NewrelicMobile.instance.start(config , (){});

    // Now run the app safely in SAME zone
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => languageController),
        ],
        child: Consumer<LanguageChangeController>(
          builder: (context, provider, child) {
            return MyApp(provider: provider);
          },
        ),
      ),
    );

    initBackgroundFetch();
  }, (error, stack) {
    if (kDebugMode) {
      print("Uncaught Zone Error: $error");
    }
  });
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
      navigatorObservers: [
        NewRelicNavigationObserver(),
      ],
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
      debugPrint("🔕 Notification suppressed on Slack screens");
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
