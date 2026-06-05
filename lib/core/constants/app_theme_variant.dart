enum AppThemeVariant { rose, midnight, sage }

extension AppThemeVariantLabel on AppThemeVariant {
  String get label => switch (this) {
        AppThemeVariant.rose => 'Romantic Rose',
        AppThemeVariant.midnight => 'Midnight Velvet',
        AppThemeVariant.sage => 'Sage Garden',
      };
}
