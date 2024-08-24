import 'dart:async';
import 'dart:isolate';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intraflow/firebase_options.dart';
import 'package:intraflow/views/auth_view.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
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
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
        } else {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
          }

          FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        }
      }

      runApp(
        const MyApp(),
      );
    },
    (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const AuthView(),
    );
  }
}
