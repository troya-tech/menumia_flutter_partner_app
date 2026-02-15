import '../../../../utils/app_logger.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantDto {
  final String id;
  final String menuKey;
  final String restaurantName;
  final String openHour;
  final String closeHour;

  RestaurantDto({
    required this.id,
    required this.menuKey,
    required this.restaurantName,
    required this.openHour,
    required this.closeHour,
  });

  factory RestaurantDto.fromJson(Map<String, dynamic> json, String id) {
    return RestaurantDto(
      id: id,
      menuKey: json['menuKey'] as String? ?? '',
      restaurantName: json['restaurantName'] as String? ?? 'Unknown',
      openHour: json['openHour'] as String? ?? '',
      closeHour: json['closeHour'] as String? ?? '',
    );
  }

  Restaurant toDomain([LogContext? context]) {
    return Restaurant(
      id: id,
      menuKey: menuKey,
      restaurantName: restaurantName,
      openHour: openHour,
      closeHour: closeHour,
      context: context,
    );
  }
}

