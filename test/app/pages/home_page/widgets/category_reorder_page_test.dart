
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/widgets/category_reorder_page.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';

class MockMenuService extends Mock implements MenuService {}

void main() {
  late MockMenuService mockMenuService;
  late List<Category> testCategories;
  const testMenuKey = 'test_menu_key';

  setUp(() {
    mockMenuService = MockMenuService();
    testCategories = [
      const Category(id: '1', name: 'Cat 1', displayOrder: 10, isActive: true),
      const Category(id: '2', name: 'Cat 2', displayOrder: 20, isActive: true),
    ];
    
    // Default success response
    when(() => mockMenuService.updateCategoriesOrder(any(), any()))
        .thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CategoryReorderPage(
        categories: testCategories,
        menuService: mockMenuService,
        menuKey: testMenuKey,
      ),
    );
  }

  testWidgets('Renders categories correctly', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Cat 1'), findsOneWidget);
    expect(find.text('Cat 2'), findsOneWidget);
  });

  testWidgets('Calls updateCategoriesOrder with correct menuKey on save', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find the save button (ElevatedButton) and tap it
    final saveButton = find.widgetWithText(ElevatedButton, 'Kaydet');
    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pump(); // Start async action
    await tester.pump(const Duration(milliseconds: 100)); // Finish async action

    // Verify it was called with the correct key
    verify(() => mockMenuService.updateCategoriesOrder(
          testMenuKey, 
          any(),
        )).called(1);
  });
}
