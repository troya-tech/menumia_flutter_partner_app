import 'package:menumia_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';

class PlanTiersPlannerDto {
  final bool? orderingEnabled;

  PlanTiersPlannerDto({this.orderingEnabled});

  factory PlanTiersPlannerDto.fromJson(Map<String, dynamic> json) {
    return PlanTiersPlannerDto(
      orderingEnabled: json['orderingEnabled'] as bool?,
    );
  }

  PlanTiersPlanner toDomain() {
    return PlanTiersPlanner(
      orderingEnabled: orderingEnabled ?? false,
    );
  }
}

class ThemeSettingsPlannerDto {
  final String? logoUrlLink;
  final String? primaryColor;
  final String? secondaryColor;
  final String? titleColor;
  final String? cardLogoBackgroundColor;

  ThemeSettingsPlannerDto({
    this.logoUrlLink,
    this.primaryColor,
    this.secondaryColor,
    this.titleColor,
    this.cardLogoBackgroundColor,
  });

  factory ThemeSettingsPlannerDto.fromJson(Map<String, dynamic> json) {
    return ThemeSettingsPlannerDto(
      logoUrlLink: json['logoUrlLink'] as String?,
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      titleColor: json['titleColor'] as String?,
      cardLogoBackgroundColor: json['cardLogoBackgroundColor'] as String?,
    );
  }

  ThemeSettingsPlanner toDomain() {
    return ThemeSettingsPlanner(
      logoUrlLink: logoUrlLink ?? '',
      primaryColor: primaryColor ?? '#D3D3D3',
      secondaryColor: secondaryColor ?? '#FF6B35',
      titleColor: titleColor ?? '#1D2D46',
      cardLogoBackgroundColor: cardLogoBackgroundColor ?? '#f8f9fa',
    );
  }
}

class SharedConfigDto {
  final PlanTiersPlannerDto? planTiersPlanner;
  final ThemeSettingsPlannerDto? themeSettingsPlanner;

  SharedConfigDto({
    this.planTiersPlanner,
    this.themeSettingsPlanner,
  });

  factory SharedConfigDto.fromJson(Map<String, dynamic> json) {
    // Check for nested structure or fallback to flat structure
    var planTiersPlannerJson = json['planTiersPlanner'] as Map?;
    
    // Fallback: if PlanTiersPlanner is missing but orderingEnabled is at root
    if (planTiersPlannerJson == null && json.containsKey('orderingEnabled')) {
      planTiersPlannerJson = {'orderingEnabled': json['orderingEnabled']};
    }

    return SharedConfigDto(
      planTiersPlanner: planTiersPlannerJson != null
          ? PlanTiersPlannerDto.fromJson(
              Map<String, dynamic>.from(planTiersPlannerJson))
          : null,
      themeSettingsPlanner: json['themeSettingsPlanner'] != null
          ? ThemeSettingsPlannerDto.fromJson(
              Map<String, dynamic>.from(json['themeSettingsPlanner'] as Map))
          : null,
    );
  }

  SharedConfig toDomain() {
    return SharedConfig(
      planTiersPlanner:
          planTiersPlanner?.toDomain() ?? PlanTiersPlanner.empty(),
      themeSettingsPlanner:
          themeSettingsPlanner?.toDomain() ?? ThemeSettingsPlanner.empty(),
    );
  }
}
