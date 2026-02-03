class RestaurantUser {
  final String id;
  final String email;
  final String? displayName;
  final List<String> relatedRestaurantsIds;
  final String? role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const RestaurantUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.relatedRestaurantsIds,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
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
}
