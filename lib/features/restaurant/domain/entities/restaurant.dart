class Restaurant {
  final String id;
  final String menuKey;
  final String restaurantName;
  final String openHour;
  final String closeHour;

  const Restaurant({
    required this.id,
    required this.menuKey,
    required this.restaurantName,
    required this.openHour,
    required this.closeHour,
  });

  factory Restaurant.empty() {
    return const Restaurant(
      id: '',
      menuKey: '',
      restaurantName: '',
      openHour: '',
      closeHour: '',
    );
  }

  Restaurant copyWith({
    String? id,
    String? menuKey,
    String? restaurantName,
    String? openHour,
    String? closeHour,
  }) {
    return Restaurant(
      id: id ?? this.id,
      menuKey: menuKey ?? this.menuKey,
      restaurantName: restaurantName ?? this.restaurantName,
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
    );
  }
}
