import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// Bootstrap-only splash. The native Android SplashActivity (Kotlin) plays
/// the full animated splash *before* Flutter renders, so this screen is
/// visually a bare-background gate that:
///
///   1. Triggers [AuthNotifier.bootstrap] in initState.
///   2. Enforces a 5-second hard timeout (forces Unauthenticated on hang).
///   3. Imperatively navigates to `/login` or `/home/habits` once the auth
///      state resolves.
///
/// Background color matches the native splash bg (`BLColors.lightBgTop`) so
/// the handoff between Kotlin and Flutter is visually invisible.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// Hard timeout on bootstrap() — protects against a hung Keystore.
  static const _kTimeout = Duration(seconds: 5);

  bool _navigated = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Defer past build phase — Riverpod prohibits state mutation during build.
    Future<void>(_runGate);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _runGate() async {
    final notifier = ref.read(authNotifierProvider.notifier);

    _timeoutTimer = Timer(_kTimeout, () {
      if (!mounted) return;
      notifier.markUnauthenticated();
    });

    await notifier.bootstrap();
    _timeoutTimer?.cancel();

    if (!mounted || _navigated) return;
    _navigated = true;

    final authState = ref.read(authNotifierProvider);
    try {
      if (authState is AuthAuthenticated) {
        context.goNamed(RouteNames.habits);
      } else {
        context.goNamed(RouteNames.login);
      }
    } catch (_) {
      // No GoRouter in context — expected in isolated widget tests.
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: BLColors.lightBgTop,
      body: SizedBox.expand(
        key: Key('bl_splash_root'),
      ),
    );
  }
}
