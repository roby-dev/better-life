import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';
import 'package:better_life_app/core/widgets/bl_wordmark.dart';

// ────────────────────────────────────────────────────────────────────────────
// Public painter — exported so tests can cast and inspect progress.
// ────────────────────────────────────────────────────────────────────────────

/// CustomPainter for the animated check-stroke inside BLAnimatedLogo.
///
/// Draws a stylised check mark whose visible portion is [progress] × totalLength.
/// [shouldRepaint] compares [progress] to avoid unnecessary redraws.
class BLCheckPainter extends CustomPainter {
  const BLCheckPainter({
    required this.progress,
    required this.size,
  });

  final double progress;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (progress <= 0) return;

    // Build the check path centred inside the logo circle.
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final r = size * 0.18; // check radius relative to logo

    final path = Path()
      ..moveTo(cx - r * 0.7, cy)
      ..lineTo(cx - r * 0.05, cy + r * 0.65)
      ..lineTo(cx + r * 0.9, cy - r * 0.7);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final drawLength = metric.length * progress.clamp(0.0, 1.0);
    final visiblePath = metric.extractPath(0, drawLength);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(visiblePath, paint);
  }

  @override
  bool shouldRepaint(BLCheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.size != size;
}

// ────────────────────────────────────────────────────────────────────────────
// Particle seed data (10 positions — fixed percentage offsets from centre)
// ────────────────────────────────────────────────────────────────────────────

const List<(double dx, double dy)> _particleSeeds = [
  (-0.55, -0.45),
  (0.50, -0.50),
  (0.60, 0.10),
  (-0.60, 0.20),
  (0.10, 0.65),
  (-0.20, 0.60),
  (0.45, 0.55),
  (-0.50, -0.10),
  (0.20, -0.60),
  (-0.15, -0.62),
];

// ────────────────────────────────────────────────────────────────────────────
// BLAnimatedLogo
// ────────────────────────────────────────────────────────────────────────────

/// Animated splash logo with the full animation stack from the design handoff.
///
/// Includes logo entry, check stroke, wordmark fade-in, tagline fade-in,
/// 3× halo loops, and 10× particle loops.
///
/// All [AnimationController]s and [Timer]s are disposed in [dispose].
/// Staggered delays use cancellable [Timer]s — safe when navigating away early.
class BLAnimatedLogo extends StatefulWidget {
  const BLAnimatedLogo({
    super.key,
    this.size = 170.0,
  });

  /// Diameter of the logo circle. Defaults to 170 px (splash usage).
  final double size;

  @override
  State<BLAnimatedLogo> createState() => _BLAnimatedLogoState();
}

class _BLAnimatedLogoState extends State<BLAnimatedLogo>
    with TickerProviderStateMixin {
  // ── entry ─────────────────────────────────────────────────────────────────
  late final AnimationController _entry;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryTranslateY;
  late final Animation<double> _entryBlur;

  // ── check stroke ──────────────────────────────────────────────────────────
  late final AnimationController _check;
  late final Animation<double> _checkProgress;

  // ── wordmark ──────────────────────────────────────────────────────────────
  late final AnimationController _wordmark;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _wordmarkTranslateY;

  // ── tagline ───────────────────────────────────────────────────────────────
  late final AnimationController _taglineCtrl;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineTranslateY;

  // ── halos (×3) ───────────────────────────────────────────────────────────
  late final List<AnimationController> _halos;
  late final List<Animation<double>> _haloScale;
  late final List<Animation<double>> _haloOpacity;

  // ── particles (×10) ──────────────────────────────────────────────────────
  late final List<AnimationController> _particles;
  late final List<Animation<double>> _particleOpacity;
  late final List<Animation<double>> _particleScale;
  late final List<Animation<Offset>> _particleTranslate;

  // ── cancellable delay timers ──────────────────────────────────────────────
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startSequence();
  }

  // ── controller initialisation ─────────────────────────────────────────────

  void _initControllers() {
    // Entry (1100ms, emphasized easing)
    _entry = AnimationController(vsync: this, duration: BLAnim.logoEntry);
    final entryCurved = CurvedAnimation(parent: _entry, curve: BLAnim.emphasized);
    _entryOpacity    = Tween<double>(begin: 0, end: 1).animate(entryCurved);
    _entryScale      = Tween<double>(begin: 0.6, end: 1.0).animate(entryCurved);
    _entryTranslateY = Tween<double>(begin: 20, end: 0).animate(entryCurved);
    _entryBlur       = Tween<double>(begin: 8, end: 0).animate(entryCurved);

    // Check stroke (700ms, check easing)
    _check = AnimationController(vsync: this, duration: BLAnim.checkDraw);
    _checkProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _check, curve: BLAnim.check),
    );

    // Wordmark (900ms, emphasized easing)
    _wordmark = AnimationController(vsync: this, duration: BLAnim.wordmarkIn);
    final wordmarkCurved = CurvedAnimation(parent: _wordmark, curve: BLAnim.emphasized);
    _wordmarkOpacity    = Tween<double>(begin: 0, end: 1).animate(wordmarkCurved);
    _wordmarkTranslateY = Tween<double>(begin: 14, end: 0).animate(wordmarkCurved);

    // Tagline (700ms, ease)
    _taglineCtrl = AnimationController(vsync: this, duration: BLAnim.taglineIn);
    final taglineCurved = CurvedAnimation(parent: _taglineCtrl, curve: Curves.ease);
    _taglineOpacity    = Tween<double>(begin: 0, end: 1).animate(taglineCurved);
    _taglineTranslateY = Tween<double>(begin: 6, end: 0).animate(taglineCurved);

    // Halos × 3 (4400ms loop, easeOut)
    _halos = List.generate(3, (_) => AnimationController(
      vsync: this,
      duration: BLAnim.haloPulse,
    ));
    _haloScale = _halos
        .map((c) => Tween<double>(begin: 0.6, end: 1.6)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _haloOpacity = _halos
        .map((c) => Tween<double>(begin: 0.5, end: 0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    // Particles × 10 (2400ms loop, easeInOut)
    _particles = List.generate(10, (_) => AnimationController(
      vsync: this,
      duration: BLAnim.particleFloat,
    ));
    _particleOpacity = _particles
        .map((c) => Tween<double>(begin: 1, end: 0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    _particleScale = _particles
        .map((c) => Tween<double>(begin: 1.0, end: 0.4)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    _particleTranslate = _particles
        .map((c) => Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(18, -22),
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  // ── staggered start sequence ──────────────────────────────────────────────

  void _startSequence() {
    // Entry — immediate
    _entry.forward();

    // Check — 400ms delay
    _addTimer(BLAnim.checkDelay, () {
      if (mounted) _check.forward();
    });

    // Wordmark — 350ms delay
    _addTimer(BLAnim.wordmarkDelay, () {
      if (mounted) _wordmark.forward();
    });

    // Tagline — 650ms delay
    _addTimer(BLAnim.taglineDelay, () {
      if (mounted) _taglineCtrl.forward();
    });

    // Halos — 600ms base, staggered by 1100ms each
    const haloBase = Duration(milliseconds: 600);
    for (var i = 0; i < 3; i++) {
      final idx = i;
      _addTimer(
        Duration(
          milliseconds:
              haloBase.inMilliseconds + BLAnim.haloStagger.inMilliseconds * idx,
        ),
        () {
          if (mounted) _halos[idx].repeat();
        },
      );
    }

    // Particles — 600ms base, staggered by 80ms each
    const particleBase = Duration(milliseconds: 600);
    for (var i = 0; i < 10; i++) {
      final idx = i;
      _addTimer(
        Duration(milliseconds: particleBase.inMilliseconds + 80 * idx),
        () {
          if (mounted) _particles[idx].repeat();
        },
      );
    }
  }

  void _addTimer(Duration delay, VoidCallback callback) {
    _timers.add(Timer(delay, callback));
  }

  // ── dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Cancel staggered timers first (prevents callbacks after dispose)
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();

    // Dispose all controllers
    _entry.dispose();
    _check.dispose();
    _wordmark.dispose();
    _taglineCtrl.dispose();
    for (final c in _halos) {
      c.dispose();
    }
    for (final c in _particles) {
      c.dispose();
    }

    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      key: const Key('bl_animated_logo_root'),
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Halo rings (behind logo) ──────────────────────────────────
          ..._buildHalos(s),

          // ── Logo entry (scale + translateY + blur + opacity) ──────────
          AnimatedBuilder(
            animation: _entry,
            builder: (context, child) {
              return FadeTransition(
                key: const Key('bl_logo_entry_fade'),
                opacity: _entryOpacity,
                child: Transform.translate(
                  offset: Offset(0, _entryTranslateY.value),
                  child: Transform.scale(
                    scale: _entryScale.value,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: _entryBlur.value,
                        sigmaY: _entryBlur.value,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/betterlife_logo.svg',
              width: s,
              height: s,
              fit: BoxFit.contain,
            ),
          ),

          // ── Check stroke (rendered over logo) ────────────────────────
          AnimatedBuilder(
            animation: _checkProgress,
            builder: (context, _) {
              return CustomPaint(
                key: const Key('bl_check_painter'),
                size: Size(s, s),
                painter: BLCheckPainter(
                  progress: _checkProgress.value,
                  size: s,
                ),
              );
            },
          ),

          // ── Wordmark (below logo, fades in separately) ────────────────
          Positioned(
            bottom: -48,
            child: AnimatedBuilder(
              animation: _wordmark,
              builder: (context, child) {
                return Opacity(
                  opacity: _wordmarkOpacity.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _wordmarkTranslateY.value),
                    child: child,
                  ),
                );
              },
              child: const BLWordmark(),
            ),
          ),

          // ── Tagline (below wordmark, fades in separately) ─────────────
          Positioned(
            bottom: -82,
            child: AnimatedBuilder(
              animation: _taglineCtrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _taglineTranslateY.value),
                    child: child,
                  ),
                );
              },
              child: Text(
                'HÁBITOS QUE TRANSFORMAN',
                style: BLType.tagline.copyWith(color: BLColors.lightTextMuted),
              ),
            ),
          ),

          // ── Particles (floating dots around logo) ─────────────────────
          ..._buildParticles(s),
        ],
      ),
    );
  }

  // ── sub-builders ─────────────────────────────────────────────────────────

  List<Widget> _buildHalos(double s) {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _halos[i],
        builder: (context, _) {
          return Opacity(
            key: Key('bl_halo_$i'),
            opacity: _haloOpacity[i].value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _haloScale[i].value,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: BLColors.lavender200,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildParticles(double s) {
    return List.generate(10, (i) {
      final seed = _particleSeeds[i];
      final baseX = seed.$1 * s * 0.4;
      final baseY = seed.$2 * s * 0.4;

      return AnimatedBuilder(
        animation: _particles[i],
        builder: (context, _) {
          final tx = _particleTranslate[i].value.dx;
          final ty = _particleTranslate[i].value.dy;
          return Positioned(
            key: Key('bl_particle_$i'),
            left: s / 2 + baseX + tx - 4,
            top: s / 2 + baseY + ty - 4,
            child: Opacity(
              opacity: _particleOpacity[i].value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _particleScale[i].value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: BLColors.lavender300,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
