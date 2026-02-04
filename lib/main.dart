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
  WidgetsFlutterBinding.ensureInitialized();

  // Select Firebase options based on environment
  final firebaseOptions = environment == 'prod'
      ? firebase_prod.DefaultFirebaseOptions.currentPlatform
      : firebase_uat.DefaultFirebaseOptions.currentPlatform;

  // Initialize Firebase with the correct options
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  // Initialize Google Sign-In (v7+)
  await GoogleSignIn.instance.initialize();

  runApp(const MyApp());
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
