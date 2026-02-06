import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage renders correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify main visual elements
    expect(find.text('Menumia Partner'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.text('Manage your restaurant with ease'), findsOneWidget);
  });

  testWidgets('LoginPage shows loading state when signing in', (tester) async {
    when(() => mockAuthRepository.signInWithGoogle())
        .thenAnswer((_) async => await Future.delayed(const Duration(seconds: 1)));

    await tester.pumpWidget(createWidgetUnderTest());

    // Find and tap the login button
    final loginButton = find.text('Login with Google');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    
    // We need to pump multiple times because the loading state change 
    // occurs in an async microtask after the button is pressed.
    await tester.pump(); // Handle the tap
    await tester.pump(const Duration(milliseconds: 50)); // Handle the setState

    // Verify loading state
    expect(find.text('Logging in...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoginPage shows error message on failure', (tester) async {
    const errorMessage = 'Google Sign-In Canceled';
    when(() => mockAuthRepository.signInWithGoogle())
        .thenThrow(errorMessage);

    await tester.pumpWidget(createWidgetUnderTest());

    // Tap the login button
    await tester.tap(find.text('Login with Google'));
    await tester.pump(); // Process the tap and error

    // Verify error message is displayed
    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
