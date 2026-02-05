import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../../features/menu/domain/entities/category.dart';
import '../../../../features/menu/application/services/menu_service.dart';

class CategoryReorderPage extends StatefulWidget {
  final List<Category> categories;
  final MenuService menuService;
  final String menuKey;

  const CategoryReorderPage({
    super.key,
    required this.categories,
    required this.menuService,
    required this.menuKey,
  });

  @override
  State<CategoryReorderPage> createState() => _CategoryReorderPageState();
}

class _CategoryReorderPageState extends State<CategoryReorderPage> {
  late List<Category> _localCategories;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _localCategories = List.from(widget.categories);
  }

  Future<void> _saveOrder() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedCategories = <Category>[];
      
      // Update displayOrder locally and collect modified categories
      for (int i = 0; i < _localCategories.length; i++) {
        final category = _localCategories[i];
        final newOrder = i + 1;
        
        if (category.displayOrder != newOrder) {
          updatedCategories.add(category.copyWith(displayOrder: newOrder));
        }
      }
      
      if (updatedCategories.isNotEmpty) {
        await widget.menuService.updateCategoriesOrder(
          widget.menuKey,
          updatedCategories,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sıralama güncellendi', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.brightBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          'Kategori Sıralaması',
          style: TextStyle(
            color: AppColors.navbarText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navbarBackground,
        iconTheme: const IconThemeData(color: AppColors.navbarText),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _localCategories.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _localCategories.removeAt(oldIndex);
                  _localCategories.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final category = _localCategories[index];
                return Card(
                  key: ValueKey(category.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator, color: AppColors.textSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.textSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Kaydet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
