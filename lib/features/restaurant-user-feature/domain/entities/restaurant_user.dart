import '../../../../utils/app_logger.dart';

class RestaurantUser {
  final String id;
  final String email;
  final String? displayName;
  final List<String> relatedRestaurantsIds;
  final String? role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final LogContext? context;

  const RestaurantUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.relatedRestaurantsIds,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.context,
  });

  factory RestaurantUser.empty() {
    return RestaurantUser(
      id: '',
      email: '',
      relatedRestaurantsIds: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: false,
    );
  }

  RestaurantUser copyWith({
    String? id,
    String? email,
    String? displayName,
    List<String>? relatedRestaurantsIds,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    LogContext? context,
  }) {
    return RestaurantUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      relatedRestaurantsIds: relatedRestaurantsIds ?? this.relatedRestaurantsIds,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      context: context ?? this.context,
    );
  }
}

