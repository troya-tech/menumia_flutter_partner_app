import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_reorder_page.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/repositories/fake_menu_repository.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Categories Flow Tests
///
/// Verifies:
/// - Category list renders with data from FakeMenuRepository
/// - Add category dialog + creation
/// - Toggle category active/inactive
/// - Tap category → details page
/// - Reorder page navigation
///
/// Data chain (full fake resolution):
/// fakeAuth.emitUser(testUser) → email: foorcun@gmail.com
///   → FakeRestaurantUserRepository → fake_foorcun (relatedRestaurantsIds: [-OlKaa_kkasdfsadfcrF])
///   → FakeRestaurantRepository → restaurant "fake restaurant" (menuKey: key_fake)
///   → FakeMenuRepository → MenuFixtures.fake (2 categories: "Fake Burgers", "Fake Drinks")
void main() {
  late TestHarness harness;

  setUp(() {
    // Reset static menu cache to prevent state leakage between tests
    FakeMenuRepository.reset();
    harness = TestHarness.create();
  });

  /// Helper: authenticate and navigate to CategoriesPage (default tab on HomePage)
  ///
  /// Uses runAsync to escape FakeAsync so the restaurant context chain
  /// (nested BehaviorSubject stream subscriptions) can process in real async.
  Future<void> loginAndShowCategories(WidgetTester tester) async {
    await tester.pumpWidget(harness.buildApp(
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));

    await tester.runAsync(() async {
      harness.fakeAuth.emitUser(fakeAuthUser);
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await pumpAndFlush(tester);
    expect(find.byType(HomePage), findsOneWidget);
  }

  Future<void> tapPopupMenuItem(WidgetTester tester, String value) async {
    // Open the popup menu
    await tester.tap(find.byType(PopupMenuButton<String>));
    // Advance past the full popup open animation (Material default: 300ms)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Find and tap the PopupMenuItem by its value
    final itemFinder = find.byWidgetPredicate(
      (widget) => widget is PopupMenuItem<String> && widget.value == value,
    );
    expect(itemFinder, findsOneWidget, reason: 'PopupMenuItem with value "$value" should exist');
    await tester.tap(itemFinder);
    // Pump for popup close animation + onSelected callback processing
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  group('Categories Page - UI States', () {
    testWidgets('Shows category list with data from fake repository',
        (tester) async {
      await loginAndShowCategories(tester);

      // Verify: "Kategoriler" title in AppBar
      expect(find.text('Kategoriler'), findsOneWidget);

      // Verify: Both categories from MenuFixtures.fake are visible
      expect(find.text('Fake Burgers'), findsOneWidget);
      expect(find.text('Fake Drinks'), findsOneWidget);
    });

    testWidgets('Each category card has an active/inactive toggle',
        (tester) async {
      await loginAndShowCategories(tester);

      // Verify: Each category card has a Switch widget
      // MenuFixtures.fake has 2 categories, both isActive: true
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));
    });
  });

  group('Categories Page - Add Category', () {
    testWidgets('Open Add Category dialog from popup menu', (tester) async {
      await loginAndShowCategories(tester);

      await tapPopupMenuItem(tester, 'add_category');
      await tester.pump();

      // Verify: Add Category dialog is shown
      // Title "Yeni Kategori Ekle" appears in the dialog
      expect(find.text('Yeni Kategori Ekle'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Ekle'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });

    testWidgets('Add a new category and verify it appears in the list',
        (tester) async {
      await loginAndShowCategories(tester);

      await tapPopupMenuItem(tester, 'add_category');
      await tester.pump();

      // Enter a category name in the dialog
      await tester.enterText(find.byType(TextField), 'Tatlılar');
      await tester.pump();

      // Tap "Ekle" button
      await tester.tap(find.text('Ekle'));
      await pumpAndFlush(tester);

      // Verify: New category appears in the list alongside existing ones
      expect(find.text('Fake Burgers'), findsOneWidget);
      expect(find.text('Fake Drinks'), findsOneWidget);
      expect(find.text('Tatlılar'), findsOneWidget);
    });
  });

  group('Categories Page - Category Interactions', () {
    testWidgets('Toggle category active/inactive', (tester) async {
      await loginAndShowCategories(tester);

      // Both categories start as active (isActive: true)
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      // Toggle the first category's switch off
      await tester.tap(switches.first);
      await pumpAndFlush(tester);

      // Verify: The switch has been toggled
      final firstSwitch = tester.widget<Switch>(switches.first);
      expect(firstSwitch.value, isFalse);
    });

    testWidgets('Tap category card navigates to CategoryDetailsPage',
        (tester) async {
      await loginAndShowCategories(tester);

      // Tap on "Fake Burgers" category card
      await tester.tap(find.text('Fake Burgers'));
      await pumpAndFlush(tester);

      // Verify: CategoryDetailsPage is shown
      expect(find.byType(CategoryDetailsPage), findsOneWidget);
      expect(find.text('Fake Burgers'), findsOneWidget);
    });
  });

  group('Categories Page - Reorder', () {
    testWidgets('Open reorder page from popup menu', (tester) async {
      await loginAndShowCategories(tester);

      await tapPopupMenuItem(tester, 'reorder_categories');
      await pumpAndFlush(tester);

      // Verify: CategoryReorderPage is shown
      expect(find.byType(CategoryReorderPage), findsOneWidget);
      expect(find.text('Kategori Sıralaması'), findsOneWidget);

      // Verify: Both categories are listed
      expect(find.text('Fake Burgers'), findsOneWidget);
      expect(find.text('Fake Drinks'), findsOneWidget);

      // Verify: Save and Cancel buttons are present
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });
  });
}
