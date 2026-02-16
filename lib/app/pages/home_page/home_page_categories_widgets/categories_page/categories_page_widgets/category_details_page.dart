import 'package:flutter/material.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/product_reorder_page.dart';
import 'package:menumia_flutter_partner_app/app/theme/app_colors.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/product.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/edit_product_dialog.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/add_product_dialog.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page_categories_widgets/categories_page/categories_page_widgets/category_details_page_widgets/edit_category_name_dialog.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


class CategoryDetailsPage extends StatefulWidget {
  final Category initialCategory;
  final MenuService menuService;
  final String menuKey;

  const CategoryDetailsPage({
    super.key, 
    required this.initialCategory,
    required this.menuService,
    required this.menuKey,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  static final _logger = AppLogger('CategoryDetailsPage');
  late final Stream<Menu> _menuStream;


  @override
  void initState() {
    super.initState();
    final logCtx = _logger.createContext();
    _logger.debug('Initializing CategoryDetailsPage stream for ${widget.initialCategory.name}', logCtx);
    _menuStream = widget.menuService.watchMenu(widget.menuKey, logCtx);
  }


  // Helper to find the current version of the category from the stream
  Category _getCurrentCategory(Menu menu) {
    return menu.categories.firstWhere(
      (c) => c.id == widget.initialCategory.id,
      orElse: () => widget.initialCategory,
    );
  }

  Future<void> _editCategoryName(BuildContext context, Category category) async {
    final logCtx = _logger.createContext();
    _logger.debug('Opening EditCategoryNameDialog for: ${category.name}', logCtx);
    await showDialog(
      context: context,
      builder: (context) {
        return EditCategoryNameDialog(
          category: category, 
          onSave: (newName) {
            _logger.info('Saving new category name: $newName (ID: ${category.id})', logCtx);
             widget.menuService.updateCategory(
              widget.menuKey, 
              category.copyWith(name: newName),
              logCtx,
            );
          },
        );
      },
    );
  }


  Future<void> _createNewMenuItem(BuildContext context, Category category) async {
    final logCtx = _logger.createContext();
    _logger.debug('Opening AddProductDialog for category: ${category.name}', logCtx);
    await showDialog(
      context: context,
      builder: (context) {
        return AddProductDialog(
          category: category, 
          onSave: (name, price, description) {
            _logger.info('Saving new product: $name in category: ${category.name}', logCtx);
            final newProduct = Product(
              id: 'product_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              description: description,
              price: price,
              imageUrl: '', // TODO: Add image upload or URL input
              displayOrder: 999,
            );

            widget.menuService.updateProduct(
              widget.menuKey, 
              category.id, 
              newProduct,
              logCtx,
            );
          },
        );
      },
    );
  }


  Future<void> _editMenuItem(BuildContext context, Category category, Product product) async {
    final logCtx = _logger.createContext();
    _logger.debug('Opening EditProductDialog for product: ${product.name}', logCtx);
    await showDialog(
      context: context,
      builder: (context) {
        return EditProductDialog(
          product: product, 
          onSave: (name, price, description) {
            _logger.info('Updating product: $name (ID: ${product.id})', logCtx);
            final updatedProduct = product.copyWith(
              name: name,
              description: description,
              price: price,
            );

            widget.menuService.updateProduct(
              widget.menuKey, 
              category.id, 
              updatedProduct,
              logCtx,
            );
          },
          onDelete: () {
            _logger.info('Deleting product: ${product.name} (ID: ${product.id})', logCtx);
            widget.menuService.deleteProduct(widget.menuKey, category.id, product.id, logCtx);
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Menu>(
      stream: _menuStream,
      initialData: Menu(menuKey: widget.menuKey, categories: [widget.initialCategory]),
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
                           menuKey: widget.menuKey,
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
                        Flexible(child: Text('Kategori Adını Düzenle', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'create_item',
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Flexible(child: Text('Yeni Ürün Ekle', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'rearrange_items',
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: AppColors.brightBlue, size: 20),
                        SizedBox(width: 12),
                        Flexible(child: Text('Ürün Sıralaması', overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
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
                    return InkWell(
                      onTap: () => _editMenuItem(context, category, category.items[index]),
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: _ProductItem(product: category.items[index]),
                      ),
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

