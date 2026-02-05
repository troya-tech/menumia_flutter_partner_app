import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../../features/menu/domain/entities/category.dart';
import '../../../../features/menu/domain/entities/product.dart';
import '../../../../features/menu/application/services/menu_service.dart';

class ProductReorderPage extends StatefulWidget {
  final Category category;
  final MenuService menuService;
  final String menuKey;

  const ProductReorderPage({
    super.key,
    required this.category,
    required this.menuService,
    required this.menuKey,
  });

  @override
  State<ProductReorderPage> createState() => _ProductReorderPageState();
}

class _ProductReorderPageState extends State<ProductReorderPage> {
  late List<Product> _localProducts;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _localProducts = List.from(widget.category.items);
  }

  Future<void> _saveOrder() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProducts = <Product>[];
      
      // Update displayOrder locally and collect modified products
      for (int i = 0; i < _localProducts.length; i++) {
        final product = _localProducts[i];
        final newOrder = i + 1;
        
        if (product.displayOrder != newOrder) {
          updatedProducts.add(product.copyWith(displayOrder: newOrder));
        }
      }
      
      if (updatedProducts.isNotEmpty) {
        await widget.menuService.updateProductsOrder(
          widget.menuKey,
          widget.category.id,
          updatedProducts,
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
          'Ürün Sıralaması',
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
            child: widget.category.items.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.restaurant_menu, color: AppColors.textSecondary.withOpacity(0.5), size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Düzenlenecek ürün bulunmuyor.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _localProducts.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _localProducts.removeAt(oldIndex);
                      _localProducts.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final product = _localProducts[index];
                    return Card(
                      key: ValueKey(product.id),
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: product.imageUrl.isNotEmpty 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(product.imageUrl, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${product.price} ₺',
                          style: const TextStyle(color: AppColors.textSecondary),
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
