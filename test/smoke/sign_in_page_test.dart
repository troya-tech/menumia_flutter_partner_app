import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/app/pages/auth/sign_in_page.dart';
import 'package:menumia_flutter_partner_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('SignInPage renders correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SignInPage(authService: mockAuthService),
    ));

    // Verify main visual elements
    expect(find.text('Menumia Partner'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}
