import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_tinder/core/constants/app_theme_variant.dart';
import 'package:wedding_tinder/providers/theme_provider.dart';

const _key = 'app_theme_variant';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('ThemeNotifier', () {
    test('defaults to the rose variant', () {
      SharedPreferences.setMockInitialValues({});
      expect(container.read(themeProvider), AppThemeVariant.rose);
    });

    test('init restores a previously saved variant', () async {
      SharedPreferences.setMockInitialValues({_key: 'midnight'});
      await container.read(themeProvider.notifier).init();
      expect(container.read(themeProvider), AppThemeVariant.midnight);
    });

    test('init keeps the default when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      await container.read(themeProvider.notifier).init();
      expect(container.read(themeProvider), AppThemeVariant.rose);
    });

    test('init ignores an unknown saved value', () async {
      SharedPreferences.setMockInitialValues({_key: 'neon'});
      await container.read(themeProvider.notifier).init();
      expect(container.read(themeProvider), AppThemeVariant.rose);
    });

    test('setVariant updates state and persists the choice', () async {
      SharedPreferences.setMockInitialValues({});
      await container.read(themeProvider.notifier).setVariant(AppThemeVariant.sage);

      expect(container.read(themeProvider), AppThemeVariant.sage);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_key), 'sage');
    });

    test('a persisted choice survives into a new container', () async {
      SharedPreferences.setMockInitialValues({});
      await container
          .read(themeProvider.notifier)
          .setVariant(AppThemeVariant.midnight);

      final next = ProviderContainer();
      addTearDown(next.dispose);
      await next.read(themeProvider.notifier).init();
      expect(next.read(themeProvider), AppThemeVariant.midnight);
    });
  });

  group('AppThemeVariant.label', () {
    test('every variant has a human-readable label', () {
      expect(AppThemeVariant.rose.label, 'Romantic Rose');
      expect(AppThemeVariant.midnight.label, 'Midnight Velvet');
      expect(AppThemeVariant.sage.label, 'Sage Garden');
    });
  });
}
