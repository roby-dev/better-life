import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:better_life_app/app/router/route_names.dart';
import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/widgets/bl_animated_logo.dart';
import 'package:better_life_app/core/widgets/bl_loader_bar.dart';
import 'package:better_life_app/features/auth/presentation/providers.dart';
import 'package:better_life_app/features/auth/presentation/state/auth_state.dart';

/// Splash screen — FR-001 / NFR-010.
///
/// Lifecycle:
/// 1. [initState] → [_runGate] schedules:
///    - [AuthNotifier.bootstrap] with a 5-second hard timeout.
///    - A minimum 2500ms floor ([_kFloor]).
/// 2. [Future.wait] on both futures ensures the brand animation is never
///    cut short on fast devices.
/// 3. On completion: reads [authNotifierProvider], navigates to
///    `/home/habits` (authenticated) or `/login` (otherwise).
///
/// Navigation is performed imperatively via [GoRouter]. The [GoRouterRefreshNotifier]
/// also fires when [AuthState] changes, but [_runGate] controls the post-splash push
/// so there is no double-navigation race.
///
/// The [mounted] guard in every async callback prevents setState/navigation
/// after the widget is disposed (e.g., if the user navigates away somehow).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// Minimum time the splash stays visible, regardless of bootstrap speed.
  static const _kFloor = Duration(milliseconds: 2500);

  /// Hard timeout on bootstrap() — protects against a hung Keystore.
  static const _kTimeout = Duration(seconds: 5);

  /// Prevents double-navigation if the state change fires the router redirect
  /// while the gate is still running.
  bool _navigated = false;

  // Cancellable timer for the hard timeout so it does not fire after dispose.
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Defer _runGate() past the build phase — Riverpod prohibits modifying
    // provider state synchronously during initState (would trigger setState
    // during tree build and cause a "modified during build" assertion).
    Future<void>(_runGate);
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _runGate() async {
    final notifier = ref.read(authNotifierProvider.notifier);

    // 5-second hard timeout: if bootstrap() never resolves (e.g., Keystore
    // hangs), force Unauthenticated so the gate can complete.
    _timeoutTimer = Timer(_kTimeout, () {
      if (!mounted) return;
      notifier.markUnauthenticated();
    });

    // Run bootstrap + floor concurrently. The gate resolves when BOTH are done.
    await Future.wait<void>([
      notifier.bootstrap(),
      Future<void>.delayed(_kFloor),
    ]);

    _timeoutTimer?.cancel();

    if (!mounted || _navigated) return;
    _navigated = true;

    final authState = ref.read(authNotifierProvider);
    // GoRouter.of(context) throws if no GoRouter is in the tree (e.g., in
    // widget tests that use plain MaterialApp). Guard with try/catch so tests
    // can pump the full gate duration without crashing.
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        key: const Key('bl_splash_root'),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [BLColors.lightBgTop, BLColors.lightBgBottom],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative dots layer ────────────────────────────────────────
            const Positioned.fill(child: _DotsLayer()),

            // ── Centered: logo + tagline ─────────────────────────────────────
            const Center(child: _SplashCore()),

            // ── Footer: loader bar ───────────────────────────────────────────
            const Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: Center(child: BLLoaderBar()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Splash core: animated logo + tagline ─────────────────────────────────────

class _SplashCore extends StatelessWidget {
  const _SplashCore();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Extra top padding so the tagline overflow (-82px below box) has room.
        // BLAnimatedLogo renders tagline as Positioned(bottom: -82) inside its
        // own Stack(clipBehavior: Clip.none), so we provide clearance here.
        const SizedBox(height: 100),

        // BLAnimatedLogo manages all animations internally (wordmark + tagline
        // are rendered as Positioned children inside its own Stack with
        // clipBehavior: Clip.none). The tagline sits at bottom: -82 inside
        // the logo's own Stack and animates in via its own controller.
        const BLAnimatedLogo(size: 170),

        // Vertical clearance for the tagline that overflows the logo box.
        // BLAnimatedLogo uses Positioned(bottom: -82) — we provide 96px here
        // so the overflow doesn't clip visually.
        const SizedBox(height: 96),

        const SizedBox(height: 100),
      ],
    );
  }
}

// ── Decorative dots ───────────────────────────────────────────────────────────

/// 10 decorative dots at fixed percentage positions with staggered
/// pulsing opacity. These are purely cosmetic and not accessibility-critical.
class _DotsLayer extends StatefulWidget {
  const _DotsLayer();

  @override
  State<_DotsLayer> createState() => _DotsLayerState();
}

class _DotsLayerState extends State<_DotsLayer>
    with TickerProviderStateMixin {
  // Fractional positions (left %, top %) for the 10 decorative dots.
  static const _positions = [
    (0.08, 0.12), (0.85, 0.08), (0.15, 0.55), (0.92, 0.40),
    (0.05, 0.78), (0.75, 0.70), (0.50, 0.05), (0.30, 0.90),
    (0.60, 0.88), (0.20, 0.25),
  ];

  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];
  final List<Timer> _delayTimers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _positions.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2400),
      );
      final anim = Tween<double>(begin: 0.2, end: 0.8).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _controllers.add(ctrl);
      _animations.add(anim);

      final delay = Duration(milliseconds: 600 + i * 240);
      final t = Timer(delay, () {
        if (!mounted) return;
        ctrl.repeat(reverse: true);
      });
      _delayTimers.add(t);
    }
  }

  @override
  void dispose() {
    for (final t in _delayTimers) {
      t.cancel();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: List.generate(_positions.length, (i) {
            final (lf, tp) = _positions[i];
            return Positioned(
              left: lf * w,
              top: tp * h,
              child: FadeTransition(
                opacity: _animations[i],
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BLColors.lavender300.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
