import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Login Flow Tests
///
/// Verifies login button behavior, error handling, and navigation:
/// - Tap login → triggers signInWithGoogle
/// - Network error → shows error UI
/// - Auth error → shows error UI
/// - Success → navigates to HomePage
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Login - Success', () {
    testWidgets('Tapping Login button calls signInWithGoogle', (tester) async {
      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the "Login with Google" button
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: FakeAuthRepository signs in → user is now authenticated
      expect(harness.fakeAuth.currentUser, isNotNull);
    });

    testWidgets('Successful login navigates to HomePage', (tester) async {
      // Configure custom sign-in to emit our specific fake user
      harness.fakeAuth.onSignIn = () async {
        harness.fakeAuth.emitUser(fakeAuthUser);
        return fakeAuthUser;
      };

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Verify: starts on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: navigated to HomePage
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });
  });

  group('Login - Error Handling', () {
    testWidgets('No internet shows network error', (tester) async {
      const networkErrorMessage = 'Exception: Network error: No internet connection';
      harness.fakeAuth.signInError = Exception('Network error: No internet connection');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap the "Login with Google" button
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: Error message is displayed in the UI
      expect(find.text(networkErrorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Failed login shows authentication error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Authentication failed: Invalid credentials');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: error is shown, still on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Exception: Authentication failed: Invalid credentials'),
          findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('DNS resolution failure shows network error', (tester) async {
      harness.fakeAuth.signInError =
          Exception('Network error: Unable to resolve host');

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Tap login
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: network error is shown
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Exception: Network error: Unable to resolve host'),
          findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
