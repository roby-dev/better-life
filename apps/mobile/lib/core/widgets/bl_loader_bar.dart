import 'package:flutter/material.dart';

import 'package:better_life_app/core/theme/bl_tokens.dart';

/// 120×3 pill-shaped loader bar with a sliding indicator.
///
/// Used on the Splash screen as the progress indicator.
/// Animation: 1600ms loop, [BLAnim.loader] easing,
/// indicator translates from -110% to +310% of track width.
class BLLoaderBar extends StatefulWidget {
  const BLLoaderBar({super.key});

  @override
  State<BLLoaderBar> createState() => _BLLoaderBarState();
}

class _BLLoaderBarState extends State<BLLoaderBar>
    with SingleTickerProviderStateMixin {
  static const _trackWidth = 120.0;
  static const _trackHeight = 3.0;
  static const _indicatorWidth = 40.0;

  late final AnimationController _controller;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: BLAnim.loaderSlide,
    )..repeat();

    // Translate from -110% (off left) to +310% (off right) of track width.
    _slide = Tween<double>(
      begin: -_indicatorWidth - _trackWidth * 0.1,
      end: _trackWidth * 3.1,
    ).animate(CurvedAnimation(parent: _controller, curve: BLAnim.loader));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BLRadius.pill),
      child: SizedBox(
        key: const Key('bl_loader_bar_track'),
        width: _trackWidth,
        height: _trackHeight,
        child: ColoredBox(
          color: BLColors.lightTrack,
          child: AnimatedBuilder(
            animation: _slide,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    left: _slide.value,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _indicatorWidth,
                      decoration: BoxDecoration(
                        color: BLColors.lightPrimaryBg,
                        borderRadius: BorderRadius.circular(BLRadius.pill),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
