import 'product.dart';

class Category {
  final String id;
  final String name;
  final int displayOrder;
  final bool isActive;
  final List<Product> items;

  const Category({
    required this.id,
    required this.name,
    this.displayOrder = 0,
    this.isActive = true,
    this.items = const [],
  });

  Category copyWith({
    String? id,
    String? name,
    int? displayOrder,
    bool? isActive,
    List<Product>? items,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
    );
  }
}
