import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/wedding_setup_screen.dart';
import '../features/dev/design_showcase_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/main/main_shell.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/wedding_edit_screen.dart';
import '../features/swipe/swipe_screen.dart';
import '../providers/session_provider.dart';

class AppRoutes {
  const AppRoutes._();
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String weddingSetup = '/wedding-setup';
  static const String home = '/home';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String swipe = '/swipe';
  static const String weddingEdit = '/profile/edit-wedding';
  static const String designShowcase = '/_dev/design';
}

class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(Ref ref) {
    ref.listen<SessionState>(sessionProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _SessionRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.signIn,
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (location == AppRoutes.designShowcase) return null;

      final isAuthRoute =
          location == AppRoutes.signIn || location == AppRoutes.signUp;
      final isSetupRoute = location == AppRoutes.weddingSetup;

      if (!session.isSignedIn) {
        return isAuthRoute ? null : AppRoutes.signIn;
      }
      if (!session.hasWedding) {
        return isSetupRoute ? null : AppRoutes.weddingSetup;
      }
      if (isAuthRoute || isSetupRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, _) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.weddingSetup,
        builder: (_, _) => const WeddingSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.designShowcase,
        builder: (_, _) => const DesignShowcaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.swipe,
        builder: (_, _) => const SwipeScreen(),
      ),
      GoRoute(
        path: AppRoutes.weddingEdit,
        builder: (_, _) => const WeddingEditScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (_, _) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
