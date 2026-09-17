import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';

/// The Apex "duotone hero" banner — a dark gradient surface with a Volt plate
/// motif and a corner glow, an optional oversized ghost watermark word, and
/// arbitrary content floating on top. The headline surface of the Today screen.
class DuotoneHero extends StatelessWidget {
  final Widget child;
  final String? ghostText;
  final EdgeInsetsGeometry? padding;

  /// Draw the decorative concentric "plate" rings in the backdrop. Turn OFF
  /// when the content already carries a circular focal element (e.g. a Gauge),
  /// so the two rings don't stack and clutter.
  final bool showPlate;

  const DuotoneHero({
    super.key,
    required this.child,
    this.ghostText,
    this.padding,
    this.showPlate = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppDesignSystem.surfaceRaised,
              AppDesignSystem.surfaceCanvas,
            ],
          ),
          border: Border.all(color: AppDesignSystem.borderColor),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _HeroBackdropPainter(showPlate: showPlate)),
            ),
            if (ghostText != null)
              PositionedDirectional(
                top: 6.h,
                start: 14.w,
                child: Text(
                  ghostText!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: 56.sp,
                    height: 0.9,
                    fontWeight: AppDesignSystem.extraBold,
                    letterSpacing: -2,
                    color: AppDesignSystem.textPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
            Padding(
              padding: padding ?? EdgeInsets.all(AppDesignSystem.spacingLG.w),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBackdropPainter extends CustomPainter {
  final bool showPlate;
  _HeroBackdropPainter({this.showPlate = true});

  @override
  void paint(Canvas canvas, Size size) {
    final lime = AppDesignSystem.primaryColor;
    // Corner glow (top-trailing).
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [lime.withValues(alpha: 0.20), lime.withValues(alpha: 0.0)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.1),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, glow);

    if (!showPlate) return;

    // Plate motif — two concentric rings offset off the trailing edge.
    final center = Offset(size.width * 1.02, size.height * 0.5);
    final r = size.height * 0.6;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = lime.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.03,
    );
    canvas.drawCircle(
      center,
      r * 0.62,
      Paint()
        ..color = lime.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * 0.018,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
