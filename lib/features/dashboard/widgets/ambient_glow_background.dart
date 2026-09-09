import 'package:flutter/material.dart';

/// Ambient Radial Gradient Glow matching Pirsch Landing Page hero lighting.
/// Positioned at the top of the Dashboard behind the header and hero balance card.
class AmbientGlowBackground extends StatelessWidget {
  final Color glowColor;
  final double height;

  const AmbientGlowBackground({
    super.key,
    required this.glowColor,
    this.height = 460,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: -80,
      right: -80,
      height: height,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 0.9,
              colors: [
                glowColor,
                glowColor.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
