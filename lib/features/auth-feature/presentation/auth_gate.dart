
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import '../application/auth_providers.dart';

/// Auth gate that manages navigation based on authentication state
///
/// This widget listens to auth state changes via Riverpod and displays
/// the appropriate screen based on whether the user is signed in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user == null ? const LoginPage() : const HomePage(),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: SelectableText('Auth Error: $error\n$stack'),
        ),
      ),
    );
  }
}
