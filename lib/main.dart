import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options_uat.dart' as firebase_uat;
import 'firebase_options_prod.dart' as firebase_prod;

import 'app/routing/routing.dart';
import 'app/theme/theme.dart';

// Get environment from dart-define
const String environment = String.fromEnvironment('ENV', defaultValue: 'uat');

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Select Firebase options based on environment
    final firebaseOptions = environment == 'prod'
        ? firebase_prod.DefaultFirebaseOptions.currentPlatform
        : firebase_uat.DefaultFirebaseOptions.currentPlatform;

    // Initialize Firebase (Check if already initialized to prevent 'duplicate-app' crash)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
    } else {
      // Firebase already initialized (likely by native layer), use existing instance
      // Validation: Ensure the existing instance configuration matches expectation if needed
      // For now, we assume the native google-services.json matches the dart configuration
    }

    // Initialize Google Sign-In (v7+)
    await GoogleSignIn.instance.initialize();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SelectableText( // Use SelectableText for easier copying
                'Initialization Error:\n$e\n\nSTACK TRACE:\n$stackTrace',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menumia Partner',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.auth,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
