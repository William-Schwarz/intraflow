import 'dart:async';
import 'dart:isolate';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intraflow/firebase_options.dart';
import 'package:intraflow/routes/routes.dart';
import 'package:intraflow/services/local/local_user_controller.dart';
import 'package:intraflow/services/messaging/start_push_notification_handler.dart';
import 'package:intraflow/utils/theme/custom_colors.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final StartPushNotificationHandler _startPushNotificationHandler =
    StartPushNotificationHandler();
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
        );
      }).sendPort);

      if (kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);

        // Obtenha o ID do usuário logado
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
        }

        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      }
    }

    if (!kIsWeb) {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print(
              'Permissão concedida pelo usuário: ${settings.authorizationStatus}');
        }
        _startPushNotificationHandler.startPushNotificationHandler(
            messaging: messaging);
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print(
              'Permissão concedida previsoriamente pelo usuário: ${settings.authorizationStatus}');
        }
        _startPushNotificationHandler.startPushNotificationHandler(
            messaging: messaging);
      } else {
        if (kDebugMode) {
          print(
              'Permissão negada pelo usuário: ${settings.authorizationStatus}');
        }
      }
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => LocalUserController(),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'K1 Informa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: CustomColors.secondaryColor,
        textTheme: GoogleFonts.robotoTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                12,
              ),
            ),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          elevation: 5,
        ),
      ),
      routerConfig: router,
    );
  }
}
