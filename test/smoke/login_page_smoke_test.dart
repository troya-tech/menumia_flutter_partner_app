import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('Smoke Test: LoginPage renders without crashing', (tester) async {
    final mockAuthRepository = MockAuthRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Menumia Partner'), findsOneWidget);
  });
}
