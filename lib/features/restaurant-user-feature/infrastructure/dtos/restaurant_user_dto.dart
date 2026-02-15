import '../../../../utils/app_logger.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';

class RestaurantUserDto {
  final String id;
  final String email;
  final String? displayName;
  final List<String>? relatedRestaurantsIds;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;

  RestaurantUserDto({
    required this.id,
    required this.email,
    this.displayName,
    this.relatedRestaurantsIds,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  factory RestaurantUserDto.fromJson(Map<String, dynamic> json, String id) {
    // Handle relatedRestaurantsIds which can be a List or a Map in Firebase
    List<String> relatedIds = [];
    if (json['relatedRestaurantsIds'] is List) {
      relatedIds = (json['relatedRestaurantsIds'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (json['relatedRestaurantsIds'] is Map) {
      relatedIds = (json['relatedRestaurantsIds'] as Map)
          .values
          .map((e) => e.toString())
          .toList();
    }

    return RestaurantUserDto(
      id: id, // ID is usually the key in Firebase
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      relatedRestaurantsIds: relatedIds,
      role: json['role'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  RestaurantUser toDomain([LogContext? context]) {
    return RestaurantUser(
      id: id,
      email: email,
      displayName: displayName,
      relatedRestaurantsIds: relatedRestaurantsIds ?? [],
      role: role,
      createdAt: createdAt != null 
          ? DateTime.tryParse(createdAt!) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: updatedAt != null 
          ? DateTime.tryParse(updatedAt!) ?? DateTime.now() 
          : DateTime.now(),
      isActive: isActive ?? false,
      context: context,
    );
  }
  
  // Helper to convert domain to Map for updates/creation
  static Map<String, dynamic> toMap(RestaurantUser user) {
    return {
      'email': user.email,
      'displayName': user.displayName,
      'relatedRestaurantsIds': user.relatedRestaurantsIds,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'isActive': user.isActive,
    };
  }
}
