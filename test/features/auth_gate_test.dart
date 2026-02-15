import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/presentation/auth_gate.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:menumia_flutter_partner_app/testing/auth_fixtures.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/application/auth_providers.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/menu_providers.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_setup.dart';

void main() {
  group('AuthGate Dual-Track Test', () {
    
    testWidgets('Shows LoginPage when NOT authenticated (Using Fake)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: TestSetup.authOverrides(useFake: true),
          child: const MaterialApp(home: AuthGate()),
        ),
      );

      // BehaviorSubject provides the value immediately.
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('Shows HomePage when authenticated (Using Fake)', (tester) async {
      // Use the helper but manually override the repo with a logged-in user
      final fakeRepo = FakeAuthRepository(initialUser: AuthFixtures.testUser);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...TestSetup.authOverrides(useFake: true),
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: AuthGate()),
        ),
      );

      // Relaxed pump to allow the build to happen
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
