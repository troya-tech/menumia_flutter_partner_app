class Restaurant {
  final String id;
  final String restaurantName;
  final String menuKey;
  final String openHour;
  final String closeHour;

  const Restaurant({
    required this.id,
    required this.restaurantName,
    required this.menuKey,
    required this.openHour,
    required this.closeHour,
  });

  factory Restaurant.empty() {
    return const Restaurant(
      id: '',
      restaurantName: '',
      menuKey: '',
      openHour: '',
      closeHour: '',
    );
  }
}
