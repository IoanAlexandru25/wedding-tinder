import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_theme_variant.dart';

const _kThemeKey = 'app_theme_variant';

class ThemeNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() => AppThemeVariant.rose;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    if (saved != null) {
      final variant = AppThemeVariant.values
          .where((v) => v.name == saved)
          .firstOrNull;
      if (variant != null) state = variant;
    }
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, variant.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeVariant>(
  ThemeNotifier.new,
);
