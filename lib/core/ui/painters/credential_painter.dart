import 'package:flutter/material.dart';

import '../../constant/app_design_system.dart';
import '../shapes/chamfer.dart';

/// Paints the backdrop of the [AthleteCredential] card: a diagonal gradient
/// fill, an engraved "guilloché" security texture (fine diagonal hatch + offset
/// concentric arcs, like a real ID/credit card), a Volt corner glow, and the
/// chamfer border — all confined to the Apex equipment-tag silhouette so the
/// texture never bleeds past the cut corners.
class CredentialPainter extends CustomPainter {
  final double cut;

  /// Drives the one-shot entrance: the engraved rings fade/scale in as t → 1.
  final double t;

  const CredentialPainter({required this.cut, this.t = 1});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = apexChamferPath(rect, cut: cut);

    // 1) Diagonal gradient fill.
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF191C21), // slightly lifted raised
            Color(0xFF0C0E11), // deep sink toward the far corner
          ],
          stops: [0.0, 1.0],
        ).createShader(rect),
    );

    // Everything textured is confined to the silhouette.
    canvas.save();
    canvas.clipPath(path);

    // 2a) Fine diagonal micro-hatch — the engraved paper feel.
    final hatch = Paint()
      ..color = AppDesignSystem.textPrimary.withValues(alpha: 0.022)
      ..strokeWidth = 1;
    const gap = 13.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        hatch,
      );
    }

    // 2b) Offset concentric guilloché arcs radiating from the trailing edge.
    final ringCenter = Offset(size.width * 0.99, size.height * 0.30);
    final maxR = size.width * 0.9;
    for (int i = 0; i < 7; i++) {
      final f = i / 6;
      final r = maxR * (0.30 + f * 0.72) * (0.85 + 0.15 * t);
      canvas.drawCircle(
        ringCenter,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = AppDesignSystem.primaryColor
              .withValues(alpha: (0.10 - f * 0.011) * t),
      );
    }

    // 3) Volt corner glow (top-trailing).
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppDesignSystem.primaryColor.withValues(alpha: 0.22),
            AppDesignSystem.primaryColor.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.92, size.height * 0.08),
            radius: size.width * 0.55,
          ),
        ),
    );

    canvas.restore();

    // 4) Border + a minted Volt hairline along the top-left chamfer.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppDesignSystem.borderStrong,
    );
    // Short Volt accent stroke across the top-left cut.
    final c = cut.clamp(0.0, size.shortestSide / 2);
    canvas.drawLine(
      Offset(0, c),
      Offset(c, 0),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = AppDesignSystem.primaryColor.withValues(alpha: 0.9 * t),
    );
  }

  @override
  bool shouldRepaint(covariant CredentialPainter old) =>
      old.cut != cut || old.t != t;
}
