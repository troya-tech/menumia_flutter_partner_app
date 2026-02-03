import 'package:firebase_core/firebase_core.dart';

enum AppEnv { prod, uat }

class AppEnvironment {
  static const String _envKey = 'ENV';
  
  /// Current environment determined by --dart-define=ENV=... (defaults to uat)
  static AppEnv get current {
    const envStr = String.fromEnvironment(_envKey, defaultValue: 'uat');
    if (envStr.toLowerCase() == 'prod') return AppEnv.prod;
    return AppEnv.uat;
  }

  /// Get FirebaseOptions for the current environment
  static FirebaseOptions get firebaseOptions {
    switch (current) {
      case AppEnv.uat:
        return _uatFirebaseOptions;
      case AppEnv.prod:
      default:
        return _prodFirebaseOptions;
    }
  }

  // PRDO Config (Menumia)
  static const FirebaseOptions _prodFirebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyDQC3c-ZjNbFBZORDBDBHxYEzmA_Bp16Ik",
    authDomain: "menumia-f10d8.firebaseapp.com",
    databaseURL: "https://menumia-f10d8-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "menumia-f10d8",
    storageBucket: "menumia-f10d8.firebasestorage.app",
    messagingSenderId: "943516634106",
    appId: "1:943516634106:web:91e4478e6315fb2dd67243",
    measurementId: "G-TC98WC6R13",
  );

  // UAT Config (Adisyon Project)
  static const FirebaseOptions _uatFirebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyCEbHghNUSZ6juY9bPRWdrmH0xK_FDk5hY",
    authDomain: "adisyon-project.firebaseapp.com",
    databaseURL: "https://adisyon-project-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "adisyon-project",
    storageBucket: "adisyon-project.firebasestorage.app",
    messagingSenderId: "296178610293",
    appId: "1:296178610293:web:c04aa884244350f5cf083c",
    measurementId: "G-LF58432TVL",
  );
}
