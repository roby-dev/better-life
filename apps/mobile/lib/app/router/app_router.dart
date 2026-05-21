import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/go_router_refresh_notifier.dart';
import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/screens/login_screen.dart';
import 'package:better_life_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:better_life_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';
import 'package:better_life_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:better_life_app/features/home/presentation/home_shell.dart';

/// Riverpod provider for the app's [GoRouter].
///
/// The router:
/// - Starts at [RoutePaths.splash].
/// - Uses [GoRouterRefreshNotifier] so route re-evaluation fires on every
///   [AuthState] change.
/// - The [redirect] function encodes the auth guard rules:
///   - [AuthInitial]         → stay on /splash (bootstrap in progress).
///   - [AuthLoading]         → no redirect (in-flight login/register).
///   - [AuthAuthenticated]   → if on splash or auth screens, go to habits.
///   - [AuthUnauthenticated] / [AuthError] → if on splash, go to login;
///                             if on protected home routes, go to login.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: _buildRedirect(ref),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, routeState) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, routeState) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutePaths.habits,
        name: RouteNames.habits,
        builder: (context, routeState) => const HomeShell(initialIndex: 0),
      ),
      GoRoute(
        path: RoutePaths.goals,
        name: RouteNames.goals,
        builder: (context, routeState) => const HomeShell(initialIndex: 1),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, routeState) => const HomeShell(initialIndex: 2),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, routeState) => const DashboardScreen(),
      ),
    ],
  );
});

// ── Redirect function ─────────────────────────────────────────────────────────

String? Function(BuildContext, GoRouterState) _buildRedirect(Ref ref) {
  return (context, routerState) {
    final auth = ref.read(authNotifierProvider);
    final loc = routerState.matchedLocation;

    final atSplash = loc == RoutePaths.splash;
    final atAuth   = loc == RoutePaths.login || loc == RoutePaths.register;

    return switch (auth) {
      // Bootstrap not yet started — keep /splash as-is.
      AuthInitial() => atSplash ? null : RoutePaths.splash,

      // In-flight login or register — hold current location.
      AuthLoading() => null,

      // Authenticated — if on splash or auth screens, forward to habits.
      AuthAuthenticated() => (atSplash || atAuth) ? RoutePaths.habits : null,

      // Unauthenticated or error — allow splash and auth screens; guard home.
      AuthUnauthenticated() || AuthError() =>
        atSplash
          ? RoutePaths.login
          : (atAuth ? null : RoutePaths.login),
    };
  };
}
