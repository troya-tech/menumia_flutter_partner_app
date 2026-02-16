import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/profile_page.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Navigation Tests
///
/// Verifies tab navigation within the authenticated app:
/// - Categories tab → Profile tab
void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('Tab Navigation', () {
    testWidgets('Navigate from Categories to Profile tab', (tester) async {
      // Start authenticated
      harness.fakeAuth.emitUser(fakeAuthUser);

      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // Verify: on HomePage
      expect(find.byType(HomePage), findsOneWidget);

      // Tap "Profil" tab in bottom navigation
      await tester.tap(find.text('Profil'));
      await pumpAndFlush(tester);

      // Verify: ProfilePage is visible
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget); // AppBar title
    });
  });
}
