import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/edit_category_name_dialog.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/add_product_dialog.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/edit_product_dialog.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/product_reorder_page.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/repositories/fake_menu_repository.dart';

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

/// Category Details Flow Tests
///
/// Verifies interactions within the CategoryDetailsPage:
/// - Edit category name (Kategori Adını Düzenle)
/// - Add new product (Yeni Ürün Ekle)
/// - Product reorder navigation (Ürün Sıralaması)
/// - Edit menu item (tap product → edit dialog)
///
/// Data chain:
/// fakeAuth.emitUser(testUser) → email: foorcun@gmail.com
///   → FakeRestaurantUserRepository → fake_foorcun (relatedRestaurantsIds: [-OlKaa_kkasdfsadfcrF])
///   → FakeRestaurantRepository → restaurant "fake restaurant" (menuKey: key_fake)
///   → FakeMenuRepository → MenuFixtures.fake
///     - "Fake Burgers" category with 2 products: "Fake Burger", "Fake Cheeseburger"
///     - "Fake Drinks" category with 1 product: "Fake Cola"
void main() {
  late TestHarness harness;

  /// Suppress NetworkImageLoadException inside a test body.
  ///
  /// MUST be called at the top of a testWidgets callback, NOT in setUp().
  /// Reason: the test binding's runTest() resets FlutterError.onError AFTER
  /// setUp() runs, so any override set in setUp() gets immediately clobbered.
  void suppressNetworkImageErrors() {
    final binding = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('HTTP request failed') ||
          message.contains('NetworkImageLoadException')) {
        return;
      }
      binding?.call(details);
    };
    addTearDown(() => FlutterError.onError = binding);
  }

  setUp(() {
    FakeMenuRepository.reset();
    harness = TestHarness.create();
  });

  /// Helper: authenticate → CategoriesPage → tap "Fake Burgers" → CategoryDetailsPage
  Future<void> navigateToCategoryDetails(WidgetTester tester) async {
    await tester.pumpWidget(harness.buildApp(
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));

    await tester.runAsync(() async {
      harness.fakeAuth.emitUser(fakeAuthUser);
      await Future.delayed(const Duration(milliseconds: 500));
    });

    await pumpAndFlush(tester);
    expect(find.byType(HomePage), findsOneWidget);

    // Tap "Fake Burgers" category card → CategoryDetailsPage
    await tester.tap(find.text('Fake Burgers'));
    await pumpAndFlush(tester);
    expect(find.byType(CategoryDetailsPage), findsOneWidget);
  }

  /// Helper: open popup menu on CategoryDetailsPage and tap a menu item by value
  Future<void> tapDetailsPopupMenuItem(WidgetTester tester, String value) async {
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final itemFinder = find.byWidgetPredicate(
      (widget) => widget is PopupMenuItem<String> && widget.value == value,
    );
    expect(itemFinder, findsOneWidget,
        reason: 'PopupMenuItem with value "$value" should exist');
    await tester.tap(itemFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  // ─── Group 1: Kategori Adını Düzenle ─────────────────────────────────────────

  group('CategoryDetailsPage - Edit Category Name', () {
    testWidgets('Opens EditCategoryNameDialog from popup menu', (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'edit_name');

      // Verify: EditCategoryNameDialog is shown
      expect(find.byType(EditCategoryNameDialog), findsOneWidget);
      expect(find.text('Kategori Düzenle'), findsOneWidget);
      expect(find.text('Kategori Adı'), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });

    testWidgets('Rename category and verify update via stream', (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'edit_name');
      expect(find.byType(EditCategoryNameDialog), findsOneWidget);

      // Clear existing name and enter new one
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Hamburgerler');
      await tester.pump();

      // Tap "Kaydet"
      await tester.tap(find.text('Kaydet'));
      await pumpAndFlush(tester);

      // Verify: Dialog closed, category name updated in AppBar
      expect(find.byType(EditCategoryNameDialog), findsNothing);
      expect(find.text('Hamburgerler'), findsOneWidget);
    });

    testWidgets('Cancel edit does not change category name', (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'edit_name');
      expect(find.byType(EditCategoryNameDialog), findsOneWidget);

      // Enter a different name but cancel
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Should Not Appear');
      await tester.pump();

      // Tap "İptal"
      await tester.tap(find.text('İptal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify: Dialog closed, original name intact
      expect(find.byType(EditCategoryNameDialog), findsNothing);
      expect(find.text('Fake Burgers'), findsOneWidget);
    });
  });

  // ─── Group 2: Yeni Ürün Ekle ─────────────────────────────────────────────────

  group('CategoryDetailsPage - Add New Product', () {
    testWidgets('Opens AddProductDialog from popup menu', (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'create_item');

      // Verify: AddProductDialog is shown
      expect(find.byType(AddProductDialog), findsOneWidget);
      expect(find.text('Yeni Ürün Ekle'), findsOneWidget);
      expect(find.text('Ürün Adı'), findsOneWidget);
      expect(find.text('Fiyat (₺)'), findsOneWidget);
      expect(find.text('Açıklama (Opsiyonel)'), findsOneWidget);
      expect(find.text('Ekle'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });

    testWidgets('Add a product and verify it appears in the list',
        (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'create_item');
      expect(find.byType(AddProductDialog), findsOneWidget);

      // Fill in the fields — there are 3 TextFields: name, price, description
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      await tester.enterText(textFields.at(0), 'Tavuk Burger');
      await tester.enterText(textFields.at(1), '180');
      await tester.enterText(textFields.at(2), 'Lezzetli tavuk burger');
      await tester.pump();

      // Tap "Ekle"
      await tester.tap(find.text('Ekle'));
      await pumpAndFlush(tester);

      // Verify: Dialog closed, new product visible alongside existing ones
      expect(find.byType(AddProductDialog), findsNothing);
      expect(find.text('Fake Burger'), findsOneWidget);
      expect(find.text('Fake Cheeseburger'), findsOneWidget);
      expect(find.text('Tavuk Burger'), findsOneWidget);
    });

    testWidgets('Shows validation error when submitting empty fields',
        (tester) async {
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'create_item');
      expect(find.byType(AddProductDialog), findsOneWidget);

      // Tap "Ekle" without filling any fields
      await tester.tap(find.text('Ekle'));
      await tester.pump();

      // Verify: Error snackbar shown, dialog still open
      expect(find.text('Lütfen geçerli isim ve fiyat giriniz'), findsOneWidget);
      expect(find.byType(AddProductDialog), findsOneWidget);
    });
  });

  // ─── Group 3: Ürün Sıralaması ─────────────────────────────────────────────────

  group('CategoryDetailsPage - Product Reorder', () {
    testWidgets('Navigates to ProductReorderPage from popup menu',
        (tester) async {
      suppressNetworkImageErrors();
      await navigateToCategoryDetails(tester);

      await tapDetailsPopupMenuItem(tester, 'rearrange_items');
      await pumpAndFlush(tester);

      // Verify: ProductReorderPage is shown
      expect(find.byType(ProductReorderPage), findsOneWidget);
      expect(find.text('Ürün Sıralaması'), findsOneWidget);

      // Verify: Products from "Fake Burgers" are listed
      expect(find.text('Fake Burger'), findsOneWidget);
      expect(find.text('Fake Cheeseburger'), findsOneWidget);

      // Verify: Save and Cancel buttons
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });
  });

  // ─── Group 4: Edit Menu Item ──────────────────────────────────────────────────

  group('CategoryDetailsPage - Edit Menu Item', () {
    testWidgets('Tap product card opens EditProductDialog', (tester) async {
      await navigateToCategoryDetails(tester);

      // Tap on "Fake Burger" product card
      await tester.tap(find.text('Fake Burger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify: EditProductDialog is shown
      expect(find.byType(EditProductDialog), findsOneWidget);
      expect(find.text('Ürünü Düzenle'), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);
    });

    testWidgets('EditProductDialog is pre-filled with existing product data',
        (tester) async {
      await navigateToCategoryDetails(tester);

      await tester.tap(find.text('Fake Burger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EditProductDialog), findsOneWidget);

      // Verify: TextField controllers are pre-filled
      // Name field should contain "Fake Burger"
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(3));

      final nameField = tester.widget<TextField>(textFields.at(0));
      expect(nameField.controller?.text, 'Fake Burger');

      final priceField = tester.widget<TextField>(textFields.at(1));
      expect(priceField.controller?.text, '100.00');

      final descField = tester.widget<TextField>(textFields.at(2));
      expect(descField.controller?.text, 'A delicious fake burger for testing');
    });

    testWidgets('Edit product name and verify update via stream',
        (tester) async {
      await navigateToCategoryDetails(tester);

      await tester.tap(find.text('Fake Burger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EditProductDialog), findsOneWidget);

      // Change the product name
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Super Burger');
      await tester.pump();

      // Tap "Kaydet"
      await tester.tap(find.text('Kaydet'));
      await pumpAndFlush(tester);

      // Verify: Dialog closed, product name updated
      expect(find.byType(EditProductDialog), findsNothing);
      expect(find.text('Super Burger'), findsOneWidget);
      expect(find.text('Fake Cheeseburger'), findsOneWidget);
    });

    testWidgets('Cancel edit does not change product data', (tester) async {
      await navigateToCategoryDetails(tester);

      await tester.tap(find.text('Fake Burger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EditProductDialog), findsOneWidget);

      // Change name but cancel
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Should Not Appear');
      await tester.pump();

      // Tap "İptal"
      await tester.tap(find.text('İptal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify: Dialog closed, original name intact
      expect(find.byType(EditProductDialog), findsNothing);
      expect(find.text('Fake Burger'), findsOneWidget);
    });
  });
}
