import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/app/theme/app_colors.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'categories_page_widgets/category_reorder_page.dart';
import 'categories_page_widgets/category_details_page.dart';

/// Categories page component
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  Widget build(BuildContext context) {
    final menuKeyAsync = ref.watch(activeMenuKeyProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final menuService = ref.watch(menuServiceProvider);

    // If the user isn't in the database (or auth is missing), show warning immediately
    // This handles the "Signed in but not in restaurantUsers" case
    if (currentUserAsync is AsyncData<RestaurantUser?> && currentUserAsync.value == null) {
      return const _NoRestaurantAssignedWarning();
    }

    return menuKeyAsync.when(
      data: (menuKey) {
        if (menuKey == null) {
          return const _NoStoreSelected();
        }

        final menuAsync = ref.watch(menuProvider(menuKey));

        return menuAsync.when(
          data: (menu) {
            final categories = menu.categories;
            return Column(
              children: [
                _buildAppBar(categories, menuKey, menuService),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF2F2F2),
                    child: categories.isEmpty
                        ? const _EmptyCategories()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return _CategoryCard(
                                category: category,
                                onToggle: (isActive) {
                                  menuService.updateCategory(
                                    menuKey,
                                    category.copyWith(isActive: isActive),
                                  );
                                },
                                menuService: menuService,
                                menuKey: menuKey,
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brightBlue)),
          error: (error, stack) => _ErrorView(error: error),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brightBlue)),
      error: (error, stack) => _ErrorView(error: error),
    );
  }

  Widget _buildAppBar(List<Category> categories, String menuKey, MenuService menuService) {
    return Container(
      color: AppColors.navbarBackground,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kategoriler',
                style: TextStyle(
                  color: AppColors.navbarText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.navbarText),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'add_category') {
                    _showAddCategoryDialog(context, menuKey, menuService);
                  } else if (value == 'reorder_categories') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryReorderPage(
                          categories: categories,
                          menuService: menuService,
                          menuKey: menuKey,
                        ),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'add_category',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Text('Yeni Kategori Ekle', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'reorder_categories',
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Text('Kategori Sıralaması Düzenle', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context, String menuKey, MenuService menuService) async {
    String categoryName = '';
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _AddCategoryDialog(
          onCategoryNameChanged: (name) => categoryName = name,
          onAdd: () {
            if (categoryName.isNotEmpty) {
              _addNewCategory(categoryName, menuKey, menuService);
              Navigator.pop(dialogContext);
            }
          },
          onCancel: () => Navigator.pop(dialogContext),
        );
      },
    );
  }

  void _addNewCategory(String name, String menuKey, MenuService menuService) {
    final id = 'category_${DateTime.now().millisecondsSinceEpoch}';
    final newCategory = Category(
      id: id,
      name: name,
      displayOrder: 999,
      isActive: true,
    );
    menuService.updateCategory(menuKey, newCategory).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    });
  }


}

class _NoStoreSelected extends StatelessWidget {
  const _NoStoreSelected();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text("There is no Active Restaurant right now", style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 64),
          const SizedBox(height: 16),
          const Text('Henüz kategori eklenmemiş.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text('Bir hata oluştu', style: Theme.of(context).textTheme.titleMedium),
          Text('$error', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final ValueChanged<bool> onToggle;
  final MenuService menuService;
  final String menuKey;

  const _CategoryCard({
    required this.category,
    required this.onToggle,
    required this.menuService,
    required this.menuKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailsPage(
                initialCategory: category,
                menuService: menuService,
                menuKey: menuKey,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: category.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Switch(
                value: category.isActive,
                onChanged: onToggle,
                activeColor: AppColors.brightBlue,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  final ValueChanged<String> onCategoryNameChanged;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _AddCategoryDialog({
    required this.onCategoryNameChanged,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      widget.onCategoryNameChanged(_nameController.text.trim());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Yeni Kategori Ekle', style: TextStyle(color: AppColors.textPrimary)),
      content: TextField(
        controller: _nameController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Kategori Adı',
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('İptal')),
        TextButton(onPressed: widget.onAdd, child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class _NoRestaurantAssignedWarning extends StatelessWidget {
  const _NoRestaurantAssignedWarning();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No restaurant assigned!',
            style: TextStyle(
              color: AppColors.textSecondary, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please contact your administrator.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
