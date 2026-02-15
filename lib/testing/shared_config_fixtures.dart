import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/dtos/shared_config_dto.dart';

class SharedConfigFixtures {
  /// Returns the millet bahcesi shared config fixture.
  static SharedConfig get milletBahcesi => _fromRaw('key_millet-bahcesi-lapseki-sosyal-tesisleri');

  /// Returns the tesis3 shared config fixture.
  static SharedConfig get tesis3 => _fromRaw('key_tesis3');

  /// Returns the forknife shared config fixture.
  static SharedConfig get forknife => _fromRaw('menuKey_forknife');

  /// Returns the NFC shared config fixture.
  static SharedConfig get nfc => _fromRaw('menuKey_nfc17');

  /// Returns the fake shared config fixture.
  static SharedConfig get fake => _fromRaw('key_fake');

  static SharedConfig _fromRaw(String key) {
    final data = rawData[key];
    if (data == null) throw Exception('Shared config fixture for key "$key" not found');
    return SharedConfigDto.fromJson(Map<String, dynamic>.from(data)).toDomain();
  }

  static final Map<String, dynamic> rawData = {
    "key_millet-bahcesi-lapseki-sosyal-tesisleri": {
      "planTiersPlanner": {
        "orderingEnabled": false
      },
      "themeSettingsPlanner": {
        "cardLogoBackgroundColor": "#132D2A",
        "logoUrlLink": "https://raw.githubusercontent.com/troya-tech/forknife-images/refs/heads/main/tesis3/tesis3_logo.png",
        "orderingEnabled": false,
        "primaryColor": "#132D2A",
        "titleColor": "#132D2A"
      }
    },
    "key_tesis3": {
      "planTiersPlanner": {
        "orderingEnabled": false
      },
      "themeSettingsPlanner": {
        "cardLogoBackgroundColor": "#132D2A",
        "logoUrlLink": "https://raw.githubusercontent.com/troya-tech/forknife-images/refs/heads/main/tesis3/tesis3_logo.png",
        "orderingEnabled": false,
        "primaryColor": "#132D2A",
        "titleColor": "#132D2A"
      }
    },
    "menuKey_forknife": {
      "planTiersPlanner": {
        "orderingEnabled": true
      },
      "themeSettingsPlanner": {
        "logoUrlLink": "https://raw.githubusercontent.com/troya-tech/forknife-images/refs/heads/main/forknifeYeniImageler/logo.png",
        "orderingEnabled": true,
        "primaryColor": "#1D2D46"
      }
    },
    "menuKey_nfc17": {
      "planTiersPlanner": {
        "orderingEnabled": true
      },
      "themeSettingsPlanner": {
        "logoUrlLink": "https://raw.githubusercontent.com/troya-tech/forknife-images/refs/heads/main/NFC_images/logo.png",
        "orderingEnabled": false,
        "primaryColor": "#B53322"
      }
    },
    "key_fake": {
      "planTiersPlanner": {
        "orderingEnabled": true
      },
      "themeSettingsPlanner": {
        "logoUrlLink": "",
        "orderingEnabled": true,
        "primaryColor": "#1D2D46",
        "titleColor": "#1D2D46"
      }
    }
  };
}
