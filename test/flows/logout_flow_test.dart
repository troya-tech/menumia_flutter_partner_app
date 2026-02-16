import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/profile_page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Logout Flow Tests
///
/// Verifies the complete logout journey and re-login scenarios:
/// - Login → Profile → Logout → LoginPage
/// - Logout → Re-login with same account
/// - Logout → Re-login with different account
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Logout', () {
    testWidgets('Login, go to Profile, then Logout', (tester) async {
      // Start authenticated
      harness.fakeAuth.emitUser(fakeAuthUser);

      await tester.pumpWidget(harness.buildApp(
        currentUserStream: Stream.value(fakeRestaurantUser),
      ));
      await pumpAndFlush(tester);

      // Verify: on HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // Navigate to Profile tab
      await tester.tap(find.text('Profil'));
      await pumpAndFlush(tester);
      expect(find.byType(ProfilePage), findsOneWidget);

      // Scroll the Logout button into view (it's below the fold on ProfilePage)
      final logoutButton = find.text('Logout');
      await tester.ensureVisible(logoutButton);
      await pumpAndFlush(tester);

      // Tap Logout button (the OutlinedButton in ProfilePage)
      await tester.tap(logoutButton);
      await pumpAndFlush(tester);

      // Verify: confirmation dialog appears
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Tap confirm "Logout" button in the dialog (ElevatedButton)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await pumpAndFlush(tester);

      // Verify: user is signed out
      expect(harness.fakeAuth.currentUser, isNull);

      // Verify: navigated back to LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
    });
  });

  group('Re-login', () {
    testWidgets('Logout then re-login with same account', (tester) async {
      // Start authenticated
      harness.fakeAuth.emitUser(fakeAuthUser);

      // Configure re-login to emit same user
      harness.fakeAuth.onSignIn = () async {
        harness.fakeAuth.emitUser(fakeAuthUser);
        return fakeAuthUser;
      };

      await tester.pumpWidget(harness.buildApp(
        currentUserStream: Stream.value(fakeRestaurantUser),
      ));
      await pumpAndFlush(tester);

      // ── Phase 1: Logout ──
      // Navigate to Profile tab
      await tester.tap(find.text('Profil'));
      await pumpAndFlush(tester);

      // Scroll Logout button into view and tap
      final logoutBtn = find.text('Logout');
      await tester.ensureVisible(logoutBtn);
      await pumpAndFlush(tester);
      await tester.tap(logoutBtn);
      await pumpAndFlush(tester);

      // Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await pumpAndFlush(tester);

      // Verify: on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);

      // ── Phase 2: Re-login with same account ──
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: back on HomePage
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
    });

    testWidgets('Logout then re-login with different account', (tester) async {
      // Start authenticated with User 1
      harness.fakeAuth.emitUser(fakeAuthUser);

      // Configure re-login to emit DIFFERENT user
      harness.fakeAuth.onSignIn = () async {
        harness.fakeAuth.emitUser(fakeAuthUser2);
        return fakeAuthUser2;
      };

      await tester.pumpWidget(harness.buildApp(
        currentUserStream: Stream.value(fakeRestaurantUser),
      ));
      await pumpAndFlush(tester);

      // ── Phase 1: Logout ──
      // Navigate to Profile tab
      await tester.tap(find.text('Profil'));
      await pumpAndFlush(tester);

      // Scroll Logout button into view and tap
      final logoutBtn = find.text('Logout');
      await tester.ensureVisible(logoutBtn);
      await pumpAndFlush(tester);
      await tester.tap(logoutBtn);
      await pumpAndFlush(tester);

      // Confirm logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await pumpAndFlush(tester);

      // Verify: on LoginPage
      expect(find.byType(LoginPage), findsOneWidget);

      // ── Phase 2: Re-login with different account ──
      await tester.tap(find.text('Login with Google'));
      await pumpAndFlush(tester);

      // Verify: back on HomePage with different user
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);

      // Verify: signed in as second user
      expect(harness.fakeAuth.currentUser?.uid, equals(fakeAuthUser2.uid));
    });
  });
}
