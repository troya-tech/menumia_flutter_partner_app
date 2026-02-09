import 'package:flutter/material.dart';
import '../pages/auth-gate-page/auth_gate_page.dart';
import '../pages/home_page/home_page.dart';
import '../pages/profile_page.dart';
import 'app_routes.dart';

/// Centralized app router configuration
/// Similar to Angular's RouterModule
class AppRouter {
  AppRouter._();

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(
          builder: (_) => const AuthGatePage(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      // TODO: Add more routes as features are implemented
      // case AppRoutes.orders:
      //   return MaterialPageRoute(builder: (_) => const OrdersPage());
      // case AppRoutes.menu:
      //   return MaterialPageRoute(builder: (_) => const MenuPage());
      // case AppRoutes.categories:
      //   return MaterialPageRoute(builder: (_) => const CategoriesPage());
      // case AppRoutes.settings:
      //   return MaterialPageRoute(builder: (_) => const SettingsPage());

      default:
        return _errorRoute(settings.name);
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Route not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                routeName ?? 'Unknown route',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
