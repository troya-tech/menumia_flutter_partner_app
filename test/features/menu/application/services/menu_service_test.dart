import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/repositories/menu_repository.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';

class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late MockMenuRepository mockMenuRepository;
  late MenuService menuService;

  setUp(() {
    mockMenuRepository = MockMenuRepository();
    menuService = MenuService(mockMenuRepository);
  });

  group('MenuService', () {
    const tMenuKey = 'test_menu_key';
    final tMenu = Menu(menuKey: tMenuKey, categories: []);

    test('should watch menu from repository', () {
      // arrange
      when(() => mockMenuRepository.watchMenu(any()))
          .thenAnswer((_) => Stream.value(tMenu));

      // act
      final result = menuService.watchMenu(tMenuKey);

      // assert
      expect(result, emits(tMenu));
      verify(() => mockMenuRepository.watchMenu(tMenuKey)).called(1);
    });

    test('should update category through repository', () async {
      // arrange
      final tCategory = Category(id: 'cat1', name: 'Test', displayOrder: 1, isActive: true, items: []);
      when(() => mockMenuRepository.updateCategory(any(), any()))
          .thenAnswer((_) => Future.value());

      // act
      await menuService.updateCategory(tMenuKey, tCategory);

      // assert
      verify(() => mockMenuRepository.updateCategory(tMenuKey, tCategory)).called(1);
    });

    test('should delete category through repository', () async {
      // arrange
      const tCategoryId = 'cat1';
      when(() => mockMenuRepository.deleteCategory(any(), any()))
          .thenAnswer((_) => Future.value());

      // act
      await menuService.deleteCategory(tMenuKey, tCategoryId);

      // assert
      verify(() => mockMenuRepository.deleteCategory(tMenuKey, tCategoryId)).called(1);
    });
  });
}
