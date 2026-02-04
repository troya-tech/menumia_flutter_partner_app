
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../../features/menu/domain/entities/menu.dart';
import '../../../../features/menu/domain/entities/category.dart';
import '../../../../features/menu/domain/entities/product.dart';
import '../../../../features/menu/application/services/menu_service.dart';
import '../../../../features/menu/infrastructure/repositories/firebase_menu_repository.dart';
import '../../../../services/auth_service.dart';
import 'category_reorder_page.dart';
import 'category_detail_page.dart';

/// Categories page component
/// Displays and manages menu categories
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // TODO: In production, inject this service via Riverpod or GetIt
  late final MenuService _menuService;
  late final Stream<Menu> _menuStream;

  @override
  void initState() {
    super.initState();
    // Initialize service and stream
    _menuService = MenuService(FirebaseMenuRepository());
    _menuStream = _menuService.watchMenu('menuKey_forknife');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Menu>(
      stream: _menuStream,
      builder: (context, snapshot) {
        // Handle Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Bir hata oluştu', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.navbarText),
                ),
                Text(
                  '${snapshot.error}', 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        // Handle Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show AppBar structure with loader or just loader
          // To keep UI stable, we might want to show the AppBar even while loading, 
          // but for simplicity, we'll show a centered loader for now.
          return const Center(child: CircularProgressIndicator(color: AppColors.brightBlue));
        }

        final categories = snapshot.data?.categories ?? [];

        return Column(
          children: [
            // Custom AppBar
            _buildAppBar(categories),
            
            // Content
            Expanded(
              child: Container(
                color: const Color(0xFFF2F2F2),
                child: categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Henüz kategori eklenmemiş.', 
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryCard(
                          category: category,
                          onToggle: (isActive) {
                            _menuService.updateCategory(
                              'menuKey_forknife', // TODO: Get from auth/context
                              category.copyWith(isActive: isActive),
                            );
                          },
                          menuService: _menuService,
                        );
                      },
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(List<Category> categories) {
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
                    _showAddCategoryDialog(context);
                  } else if (value == 'reorder_categories') {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryReorderPage(
                          categories: categories,
                          menuService: _menuService,
                        ),
                      ),
                    );
                  } else if (value == 'sign_out') {
                    _handleSignOut(context);
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
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'sign_out',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
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

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    String categoryName = '';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return _AddCategoryDialog(
          onCategoryNameChanged: (name) => categoryName = name,
          onAdd: () {
            if (categoryName.isNotEmpty) {
              _addNewCategory(categoryName);
              Navigator.pop(dialogContext);
            }
          },
          onCancel: () => Navigator.pop(dialogContext),
        );
      },
    );
  }

  void _addNewCategory(String name) {
    // Basic ID generation for demo purposes
    final id = 'category_${DateTime.now().millisecondsSinceEpoch}';
    final newCategory = Category(
      id: id, 
      name: name, 
      displayOrder: 999, // Append to end by default
      isActive: true,
    );
    
    _menuService.updateCategory('menuKey_forknife', newCategory).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    });
  }

  Future<void> _handleSignOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Çıkış Yap', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Çıkış yapmak istediğinizden emin misiniz?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true && mounted) {
      try {
        await AuthService().signOut();
        // Navigation is handled automatically by AuthGate
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yapılırken hata oluştu: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.navbarText),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final ValueChanged<bool> onToggle;
  final MenuService menuService;

  const _CategoryCard({
    required this.category,
    required this.onToggle,
    required this.menuService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2, // Slight elevation to match design language
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailPage(
                initialCategory: category,
                menuService: menuService,
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
                onChanged: (val) {
                  onToggle(val);
                },
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

/// A StatefulWidget dialog that properly manages TextEditingController lifecycle
/// This fixes the "TextEditingController was used after being disposed" error
/// that occurs when dismissing the dialog by tapping outside.
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
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brightBlue)),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: widget.onAdd,
          child: const Text('Ekle', style: TextStyle(color: AppColors.brightBlue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
