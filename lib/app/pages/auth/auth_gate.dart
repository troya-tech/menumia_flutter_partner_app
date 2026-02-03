import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page/home_page.dart';
import 'sign_in_page.dart';

/// Auth gate that manages navigation based on authentication state
///
/// This widget listens to Firebase auth state changes and displays
/// the appropriate screen based on whether the user is signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on auth state
        return snapshot.data == null ? const SignInPage() : const HomePage();
      },
    );
  }
}
