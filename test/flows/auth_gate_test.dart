import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Auth Gate Tests
///
/// Verifies that the auth gate correctly routes users based on
/// authentication state:
/// - Unauthenticated → LoginPage
/// - Authenticated → HomePage
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Auth Gate Routing', () {
    testWidgets('Shows LoginPage when user is not authenticated', (tester) async {
      // harness.fakeAuth starts with null user (unauthenticated by default)

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Verify: LoginPage is visible
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Menumia Partner'), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
    });

    testWidgets('Shows HomePage when user is authenticated', (tester) async {
      // Pre-authenticate the fake auth repository
      harness.fakeAuth.emitUser(fakeAuthUser);

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Verify: HomePage is visible with bottom navigation
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);  // Bottom nav item
      expect(find.text('Profil'), findsOneWidget);     // Bottom nav item
    });
  });
}
