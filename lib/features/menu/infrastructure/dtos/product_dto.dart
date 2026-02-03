import '../../domain/entities/product.dart';

class ProductDto {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int displayOrder;

  ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json, String key) {
    return ProductDto(
      id: key,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      displayOrder: displayOrder,
    );
  }
}
