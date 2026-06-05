import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

class WeddingTinderApp extends ConsumerStatefulWidget {
  const WeddingTinderApp({super.key});

  @override
  ConsumerState<WeddingTinderApp> createState() => _WeddingTinderAppState();
}

class _WeddingTinderAppState extends ConsumerState<WeddingTinderApp> {
  @override
  void initState() {
    super.initState();
    ref.read(themeProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    final variant = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Wedding tinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(variant),
      routerConfig: router,
    );
  }
}
