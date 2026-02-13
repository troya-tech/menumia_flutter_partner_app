import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/edit_product_dialog.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/product.dart';

void main() {
  const testProduct = Product(
    id: 'p_test',
    name: 'Test Kebab',
    description: 'A delicious test kebab',
    price: 75.50,
    imageUrl: 'https://example.com/kebab.png',
    displayOrder: 1,
  );

  group('EditProductDialog', () {
    testWidgets('renders with pre-filled product data', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  product: testProduct,
                  onSave: (name, price, desc) {},
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Ürünü Düzenle'), findsOneWidget);

      // Verify pre-filled data
      expect(find.text('Test Kebab'), findsOneWidget);
      expect(find.text('75.50'), findsOneWidget);
      expect(find.text('A delicious test kebab'), findsOneWidget);

      // Verify buttons exist
      expect(find.text('İptal'), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);
    });

    testWidgets('calls onSave with updated values when save is tapped', (tester) async {
      String? savedName;
      double? savedPrice;
      String? savedDescription;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  product: testProduct,
                  onSave: (name, price, desc) {
                    savedName = name;
                    savedPrice = price;
                    savedDescription = desc;
                  },
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Modify the name field
      final nameField = find.widgetWithText(TextField, 'Test Kebab');
      await tester.enterText(nameField, 'Updated Kebab');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(savedName, 'Updated Kebab');
      expect(savedPrice, 75.50); // unchanged
      expect(savedDescription, 'A delicious test kebab'); // unchanged
    });

    testWidgets('shows error snackbar when name is empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  product: testProduct,
                  onSave: (name, price, desc) {},
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Clear the name field
      final nameField = find.widgetWithText(TextField, 'Test Kebab');
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      // Should show validation snackbar
      expect(find.text('Lütfen geçerli isim ve fiyat giriniz'), findsOneWidget);
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  product: testProduct,
                  onSave: (name, price, desc) {},
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Ürünü Düzenle'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Ürünü Düzenle'), findsNothing);
    });

    testWidgets('handles comma as decimal separator in price', (tester) async {
      double? savedPrice;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => EditProductDialog(
                  product: testProduct,
                  onSave: (name, price, desc) {
                    savedPrice = price;
                  },
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter price with comma (Turkish convention)
      final priceField = find.widgetWithText(TextField, '75.50');
      await tester.enterText(priceField, '99,99');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(savedPrice, 99.99);
    });
  });
}
