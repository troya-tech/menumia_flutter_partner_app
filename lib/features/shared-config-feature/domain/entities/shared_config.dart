class PlanTiersPlanner {
  final bool orderingEnabled;

  const PlanTiersPlanner({
    required this.orderingEnabled,
  });

  factory PlanTiersPlanner.empty() {
    return const PlanTiersPlanner(orderingEnabled: false);
  }
}

class ThemeSettingsPlanner {
  final String logoUrlLink;
  final String primaryColor;
  final String secondaryColor;
  final String titleColor;
  final String cardLogoBackgroundColor;

  const ThemeSettingsPlanner({
    required this.logoUrlLink,
    required this.primaryColor,
    required this.secondaryColor,
    required this.titleColor,
    required this.cardLogoBackgroundColor,
  });

  factory ThemeSettingsPlanner.empty() {
    return const ThemeSettingsPlanner(
      logoUrlLink: '',
      primaryColor: '#D3D3D3',
      secondaryColor: '#FF6B35',
      titleColor: '#1D2D46',
      cardLogoBackgroundColor: '#f8f9fa',
    );
  }
}

class SharedConfig {
  final PlanTiersPlanner planTiersPlanner;
  final ThemeSettingsPlanner themeSettingsPlanner;

  const SharedConfig({
    required this.planTiersPlanner,
    required this.themeSettingsPlanner,
  });

  factory SharedConfig.empty() {
    return SharedConfig(
      planTiersPlanner: PlanTiersPlanner.empty(),
      themeSettingsPlanner: ThemeSettingsPlanner.empty(),
    );
  }
}
