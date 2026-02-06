import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/presentation/auth_gate.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/profile_page.dart';
import 'package:menumia_flutter_partner_app/app/routing/app_router.dart';
import 'package:menumia_flutter_partner_app/app/routing/app_routes.dart';
import 'package:mocktail/mocktail.dart';

// Mock BuildContext
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('AppRouter Route Generation Tests', () {
    test('generateRoute for AppRoutes.auth returns AuthGate', () {
      final settings = const RouteSettings(name: AppRoutes.auth);
      final route = AppRouter.generateRoute(settings);

      expect(route, isA<MaterialPageRoute>());
      expect((route as MaterialPageRoute).builder(MockBuildContext()),
          isA<AuthGate>());
    });

    test('generateRoute for AppRoutes.home returns HomePage', () {
      final settings = const RouteSettings(name: AppRoutes.home);
      final route = AppRouter.generateRoute(settings);

      expect(route, isA<MaterialPageRoute>());
      expect((route as MaterialPageRoute).builder(MockBuildContext()),
          isA<HomePage>());
    });

    test('generateRoute for AppRoutes.profile returns ProfilePage', () {
      final settings = const RouteSettings(name: AppRoutes.profile);
      final route = AppRouter.generateRoute(settings);

      expect(route, isA<MaterialPageRoute>());
      expect((route as MaterialPageRoute).builder(MockBuildContext()),
          isA<ProfilePage>());
    });

    test('generateRoute for unknown route returns Error Route', () {
      final settings = const RouteSettings(name: '/unknown_route');
      final route = AppRouter.generateRoute(settings);

      expect(route, isA<MaterialPageRoute>());
      
      // Verify the error route contains checking for specific widgets would require pumping,
      // so we just check it builds a Scaffold with an error message
      final builtWidget = (route as MaterialPageRoute).builder(MockBuildContext());
      expect(builtWidget, isA<Scaffold>());
      
      // We can also verify title is 'Error' by inspecting the widget properties if needed,
      // but 'isA<Scaffold>' is sufficient for unit smoke testing the return type.
    });
  });
}
