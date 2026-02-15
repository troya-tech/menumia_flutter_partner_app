import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/presentation/auth_gate.dart';
import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/application/auth_providers.dart';

void main() {
  testWidgets('Simple AuthGate Test', (tester) async {
    final fakeRepo = FakeAuthRepository(initialUser: null);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
