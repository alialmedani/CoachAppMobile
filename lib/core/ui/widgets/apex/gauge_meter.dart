import 'package:flutter/material.dart';

import '../../../constant/app_design_system.dart';
import '../../painters/gauge_painter.dart';

/// The Apex readiness gauge — a tachometer instrument with an animated needle
/// sweep and a count-up numeric readout. Drives the readiness / adherence
/// figure on the Today header and coach dashboards.
class GaugeMeter extends StatelessWidget {
  /// 0..1
  final double value;
  final double size;

  /// Small uppercase caption under the number (e.g. "READY").
  final String? caption;

  /// Optional word shown instead of the numeric percent (e.g. "PRIMED").
  final String? centerLabel;
  final bool animate;

  const GaugeMeter({
    super.key,
    required this.value,
    this.size = 160,
    this.caption,
    this.centerLabel,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: animate
          ? AppDesignSystem.durationSlow + const Duration(milliseconds: 700)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: GaugePainter(
                progress: t,
                trackColor: AppDesignSystem.surfaceSunken,
                arcStart: AppDesignSystem.primaryColor,
                arcEnd: AppDesignSystem.accentColor,
                redline: AppDesignSystem.accentColor,
                tick: AppDesignSystem.borderStrong,
                needleColor: AppDesignSystem.primaryColor,
                hubColor: AppDesignSystem.surfaceCanvas,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerLabel ?? '${(t * 100).round()}',
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: size * (centerLabel != null ? 0.17 : 0.26),
                    fontWeight: AppDesignSystem.extraBold,
                    height: 1,
                    letterSpacing: -1,
                    color: AppDesignSystem.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (caption != null)
                  Padding(
                    padding: EdgeInsets.only(top: size * 0.02),
                    child: Text(
                      caption!.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: size * 0.075,
                        fontWeight: AppDesignSystem.bold,
                        letterSpacing: 1.5,
                        color: AppDesignSystem.primaryStrong,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
