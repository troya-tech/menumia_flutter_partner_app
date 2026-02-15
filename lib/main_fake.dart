import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/repositories/fake_shared_config_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/infrastructure/repositories/fake_restaurant_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/repositories/fake_restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/repositories/fake_menu_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'firebase_options_uat.dart' as firebase_uat;
import 'main.dart';

/// Entry point for running the app with a Fake authentication repository.
/// 
/// Usage: flutter run -t lib/main_fake.dart
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with UAT options so we can read real data
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: firebase_uat.DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  runApp(
    ProviderScope(
      overrides: [
        // Inject the Fake implementation at the root
        // external logic dependencies
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),

        // internal logic dependencies
        menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
        restaurantRepositoryProvider.overrideWithValue(FakeRestaurantRepository()),
        restaurantUserRepositoryProvider.overrideWithValue(FakeRestaurantUserRepository()),
        sharedConfigRepositoryProvider.overrideWithValue(FakeSharedConfigRepository()),
      ],
      child: const MyApp(),
    ),
  );
}
