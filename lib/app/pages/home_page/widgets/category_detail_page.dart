import 'package:flutter/material.dart';
import 'product_reorder_page.dart';
import '../../../theme/app_colors.dart';
import '../../../../features/menu/domain/entities/category.dart';
import '../../../../features/menu/domain/entities/menu.dart';
import '../../../../features/menu/domain/entities/product.dart';
import '../../../../features/menu/application/services/menu_service.dart';

class CategoryDetailPage extends StatefulWidget {
  final Category initialCategory;
  final MenuService menuService;

  const CategoryDetailPage({
    super.key, 
    required this.initialCategory,
    required this.menuService,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final Stream<Menu> _menuStream;

  @override
  void initState() {
    super.initState();
    _menuStream = widget.menuService.watchMenu('menuKey_forknife');
  }

  // Helper to find the current version of the category from the stream
  Category _getCurrentCategory(Menu menu) {
    return menu.categories.firstWhere(
      (c) => c.id == widget.initialCategory.id,
      orElse: () => widget.initialCategory,
    );
  }

  Future<void> _editCategoryName(BuildContext context, Category category) async {
    await showDialog(
      context: context,
      builder: (context) {
        return _EditCategoryNameDialog(
          category: category, 
          onSave: (newName) {
             widget.menuService.updateCategory(
              'menuKey_forknife', 
              category.copyWith(name: newName),
            );
          },
        );
      },
    );
  }

  Future<void> _createNewMenuItem(BuildContext context, Category category) async {
    await showDialog(
      context: context,
      builder: (context) {
        return _AddProductDialog(
          category: category, 
          onSave: (name, price, description) {
            final newProduct = Product(
              id: 'product_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              description: description,
              price: price,
              imageUrl: '', // TODO: Add image upload or URL input
              displayOrder: 999,
            );

            widget.menuService.updateProduct(
              'menuKey_forknife', 
              category.id, 
              newProduct
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Menu>(
      stream: _menuStream,
      initialData: Menu(menuKey: 'menuKey_forknife', categories: [widget.initialCategory]),
      builder: (context, snapshot) {
        final category = snapshot.hasData 
            ? _getCurrentCategory(snapshot.data!)
            : widget.initialCategory;

        // If category deleted remotely, handle it (optional: pop)
        // For now, we assume it exists.

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          appBar: AppBar(
            title: Text(
              category.name,
              style: const TextStyle(
                color: AppColors.navbarText,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.navbarBackground,
            iconTheme: const IconThemeData(color: AppColors.navbarText),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.navbarText),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'edit_name') {
                    _editCategoryName(context, category);
                  } else if (value == 'create_item') {
                    _createNewMenuItem(context, category);
                  } else if (value == 'rearrange_items') {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ProductReorderPage(
                           category: category,
                           menuService: widget.menuService,
                         ),
                       ),
                     );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit_name',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Text('Kategori Adını Düzenle', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'create_item',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Text('Yeni Ürün Ekle', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'rearrange_items',
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Text('Ürün Sıralaması', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: category.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.restaurant_menu, color: AppColors.textSecondary.withOpacity(0.5), size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Bu kategoride ürün bulunmuyor.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: category.items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: _ProductItem(product: category.items[index]),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _ProductImage(imageUrl: product.imageUrl),
          
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    color: AppColors.brightBlue, // Use brand color for price
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.restaurant, color: Colors.black26, size: 24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          color: Colors.black.withOpacity(0.05),
          child: const Icon(Icons.broken_image, color: Colors.black26, size: 20),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.black.withOpacity(0.05),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditCategoryNameDialog extends StatefulWidget {
  final Category category;
  final ValueChanged<String> onSave;

  const _EditCategoryNameDialog({
    required this.category,
    required this.onSave,
  });

  @override
  State<_EditCategoryNameDialog> createState() => _EditCategoryNameDialogState();
}

class _EditCategoryNameDialogState extends State<_EditCategoryNameDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    // Dispose controller safely when widget is unmounted
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Kategori Adını Düzenle', style: TextStyle(color: AppColors.textPrimary)),
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
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            final newName = _nameController.text.trim();
            if (newName.isNotEmpty && newName != widget.category.name) {
              widget.onSave(newName);
            }
            Navigator.pop(context);
          },
          child: const Text('Kaydet', style: TextStyle(color: AppColors.brightBlue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final Category category;
  final Function(String name, double price, String description) onSave;

  const _AddProductDialog({
    required this.category,
    required this.onSave,
  });

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      title: const Text(
        'Yeni Ürün Ekle', 
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              label: 'Ürün Adı',
              autoFocus: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _priceController,
              label: 'Fiyat (₺)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Açıklama (Opsiyonel)',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('İptal'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool autoFocus = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      keyboardType: keyboardType,
      autofocus: autoFocus,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brightBlue, width: 2),
        ),
      ),
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    
    final price = double.tryParse(priceText);

    if (name.isNotEmpty && price != null) {
      widget.onSave(name, price, description);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli isim ve fiyat giriniz'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
