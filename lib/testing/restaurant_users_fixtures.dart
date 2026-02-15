import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/dtos/restaurant_user_dto.dart';

class RestaurantUsersFixtures {
  /// Returns all restaurant users as a list.
  static List<RestaurantUser> get all => rawData.entries
      .map((e) => RestaurantUserDto.fromJson(Map<String, dynamic>.from(e.value), e.key).toDomain())
      .toList();

  /// Returns the admin user 'fake_foorcun'.
  static RestaurantUser get fake_foorcun => _fromRaw("-OjkEONRs7g0KrrYd7ED");

  /// Returns the admin user 'nurkan'.
  static RestaurantUser get nurkan => _fromRaw("-OjlMEmDrrTe_pypu0SQ");

  /// Returns the manager user 'troy'.
  static RestaurantUser get troy => _fromRaw("-OkjPPxaZe8NrQwBU5Z3");

  /// Returns the owner user 'nfcompany'.
  static RestaurantUser get nfcompany => _fromRaw("-OlDsxswQ6n4wAnFxTiQ");

  static RestaurantUser _fromRaw(String key) {
    final data = rawData[key];
    if (data == null) throw Exception('Restaurant user fixture for key "$key" not found');
    return RestaurantUserDto.fromJson(Map<String, dynamic>.from(data), key).toDomain();
  }

  static final Map<String, dynamic> rawData = {
    "-OjkEONRs7g0KrrYd7ED": {
      "createdAt": "2026-01-24T13:42:06.388Z",
      "displayName": "fake_foorcun",
      "email": "foorcun@gmail.com",
      "isActive": true,
      "relatedRestaurantsIds": [
        // "-OjkBierbH1EO2Gz7KEd",
        // "-OiyBNtvgZPQM6_Rv7K0",
        "-OlKaa_kkasdfsadfcrF"
      ],
      "role": "admin",
      "uid": "Kj8hLfo5jkb54HtJVXqpbQOJwuX2",
      "updatedAt": "2026-02-04T13:23:55.231Z"
    },
    "-OjlMEmDrrTe_pypu0SQ": {
      "createdAt": "2026-01-24T18:56:01.316Z",
      "displayName": "nurkan",
      "email": "gs.nurkan17@gmail.com",
      "isActive": true,
      "relatedRestaurantsIds": [
        "-OjkBierbH1EO2Gz7KEd",
        "-OjlwO-OSNp_YSag06QH"
      ],
      "role": "admin",
      "uid": "-OjlMEmDrrTe_pypu0SQ",
      "updatedAt": "2026-01-24T21:38:29.780Z"
    },
    "-OkjPPxaZe8NrQwBU5Z3": {
      "createdAt": "2026-02-05T20:06:17.208Z",
      "displayName": "troy",
      "email": "troyatech17@gmail.com",
      "isActive": true,
      "relatedRestaurantsIds": [
        "-OjkBierbH1EO2Gz7KEd"
      ],
      "role": "manager",
      "uid": "-OkjPPxaZe8NrQwBU5Z3",
      "updatedAt": "2026-02-05T20:06:17.208Z"
    },
    "-OlDsxswQ6n4wAnFxTiQ": {
      "createdAt": "2026-02-11T22:47:52.559Z",
      "email": "nfcompany17@gmail.com",
      "isActive": true,
      "relatedRestaurantsIds": [
        "-OjkBierbH1EO2Gz7KEd"
      ],
      "role": "owner",
      "uid": "-OlDsxswQ6n4wAnFxTiQ",
      "updatedAt": "2026-02-11T22:47:52.559Z"
    }
  };
}
