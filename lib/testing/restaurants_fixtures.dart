import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/infrastructure/dtos/restaurant_dto.dart';

class RestaurantsFixtures {
  /// Returns all restaurants as a list.
  static List<Restaurant> get all => rawData.entries
      .map((e) => RestaurantDto.fromJson(Map<String, dynamic>.from(e.value), e.key).toDomain())
      .toList();

  /// Returns the forknife restaurant fixture.
  static Restaurant get forknife => _fromRaw("-OiyBNtvgZPQM6_Rv7K0");

  /// Returns the NFC restaurant fixture.
  static Restaurant get nfc => _fromRaw("-OjkBierbH1EO2Gz7KEd");

  /// Returns the Wiki Wings restaurant fixture.
  static Restaurant get wikiWings => _fromRaw("-OjlwO-OSNp_YSag06QH");

  /// Returns the tesis3 restaurant fixture.
  static Restaurant get tesis3 => _fromRaw("-OkPqOF2wE0GwoMoqgFM");

  /// Returns the millet bahcesi restaurant fixture.
  static Restaurant get milletBahcesi => _fromRaw("-OkSuc7Xn1hpPmGyikqn");

  /// Returns the robot test restaurant fixture.
  static Restaurant get robotTest => _fromRaw("-OlKaa_kkRKIq2GCwcrE");

  /// Returns the fake restaurant fixture.
  static Restaurant get fake => _fromRaw("-OlKaa_kkasdfsadfcrF");

  static Restaurant _fromRaw(String key) {
    final data = rawData[key];
    if (data == null) throw Exception('Restaurant fixture for key "$key" not found');
    return RestaurantDto.fromJson(Map<String, dynamic>.from(data), key).toDomain();
  }

  static final Map<String, dynamic> rawData = {
    "-OiyBNtvgZPQM6_Rv7K0": {
      "closeHour": "02:00",
      "menuKey": "menuKey_forknife",
      "openHour": "08:00",
      "restaurantName": "forknife"
    },
    "-OjkBierbH1EO2Gz7KEd": {
      "closeHour": "03:00",
      "menuKey": "menuKey_nfc17",
      "openHour": "12:00",
      "restaurantName": "NFC"
    },
    "-OjlwO-OSNp_YSag06QH": {
      "closeHour": "03:00",
      "menuKey": "wiki-wings",
      "openHour": "12:00",
      "restaurantName": "Wiki Wings"
    },
    "-OkPqOF2wE0GwoMoqgFM": {
      "closeHour": "02:00",
      "menuKey": "key_tesis3",
      "openHour": "08:00",
      "restaurantName": "tesis3"
    },
    "-OkSuc7Xn1hpPmGyikqn": {
      "closeHour": "02:00",
      "menuKey": "key_millet-bahcesi-lapseki-sosyal-tesisleri",
      "openHour": "08:00",
      "restaurantName": "millet-bahcesi-lapseki-sosyal-tesisleri"
    },
    "-OlKaa_kkRKIq2GCwcrE": {
      "closeHour": "23:00",
      "menuKey": "robot-test-key",
      "openHour": "09:00",
      "restaurantName": "RobotTest_20260213_090508"
    },
    "-OlKaa_kkasdfsadfcrF": {
      "closeHour": "23:00",
      "menuKey": "key_fake",
      "openHour": "09:00",
      "restaurantName": "fake restaurant"
    }
  };
}
