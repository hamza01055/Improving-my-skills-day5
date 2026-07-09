import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/home_screen.dart';
import '../services/local_storage_service.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuild redirects whenever auth status changes.
  final refresh = ValueNotifier<AuthStatus>(AuthStatus.unknown);
  ref
    ..onDispose(refresh.dispose)
    ..listen(
      authProvider.select((s) => s.status),
      (_, next) => refresh.value = next,
    );

  const authRoutes = {
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
    RouteNames.onboarding,
  };

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final AuthStatus status = ref.read(authProvider).status;
      final String location = state.matchedLocation;

      // Still restoring the session: stay on splash.
      if (status == AuthStatus.unknown) {
        return location == RouteNames.splash ? null : RouteNames.splash;
      }

      if (status == AuthStatus.unauthenticated) {
        if (authRoutes.contains(location)) return null;
        return LocalStorageService.hasSeenOnboarding
            ? RouteNames.login
            : RouteNames.onboarding;
      }

      // Authenticated: keep out of splash/auth screens.
      if (location == RouteNames.splash || authRoutes.contains(location)) {
        return RouteNames.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
