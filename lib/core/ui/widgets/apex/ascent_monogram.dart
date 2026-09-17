import 'package:flutter/widgets.dart';

import '../../../constant/app_design_system.dart';
import '../../shapes/chamfer.dart';

/// The Apex brand mark — an ascending "A" built from two angled shapes (a Volt
/// upstroke + a light counter) set on a chamfered "equipment-tag" tile.
/// Used by the splash, login and top bars.
class AscentMonogram extends StatelessWidget {
  final double size;

  /// When true the mark sits on a chamfered tile; when false only the glyph
  /// is drawn (e.g. for an already-coloured surface).
  final bool tile;
  final Color? background;
  final Color? upstroke;
  final Color? counter;

  const AscentMonogram({
    super.key,
    this.size = 48,
    this.tile = true,
    this.background,
    this.upstroke,
    this.counter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MonogramPainter(
          tile: tile,
          background: background ?? AppDesignSystem.surfaceCanvas,
          upstroke: upstroke ?? AppDesignSystem.primaryColor,
          counter: counter ?? AppDesignSystem.textPrimary,
        ),
      ),
    );
  }
}

class _MonogramPainter extends CustomPainter {
  final bool tile;
  final Color background;
  final Color upstroke;
  final Color counter;

  _MonogramPainter({
    required this.tile,
    required this.background,
    required this.upstroke,
    required this.counter,
  });

  // Glyph geometry in a 0..32 design box.
  static const List<Offset> _up = [
    Offset(3, 5),
    Offset(13, 5),
    Offset(29, 27),
    Offset(19, 27),
  ];
  static const List<Offset> _counter = [
    Offset(3, 27),
    Offset(11, 15),
    Offset(16, 22),
    Offset(11, 27),
  ];

  Path _poly(List<Offset> pts, double scale, Offset origin) {
    final p = Path()
      ..moveTo(origin.dx + pts.first.dx * scale, origin.dy + pts.first.dy * scale);
    for (var i = 1; i < pts.length; i++) {
      p.lineTo(origin.dx + pts[i].dx * scale, origin.dy + pts[i].dy * scale);
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (tile) {
      final bg = Paint()..color = background;
      canvas.drawPath(
        ChamferBorder(cut: size.width * 0.22).getOuterPath(Offset.zero & size),
        bg,
      );
    }
    // Fit the 32-box glyph inside a padded area.
    final pad = size.width * (tile ? 0.20 : 0.06);
    final scale = (size.width - pad * 2) / 32;
    final origin = Offset(pad, pad);
    canvas.drawPath(_poly(_up, scale, origin), Paint()..color = upstroke);
    canvas.drawPath(_poly(_counter, scale, origin), Paint()..color = counter);
  }

  @override
  bool shouldRepaint(covariant _MonogramPainter old) =>
      old.tile != tile ||
      old.background != background ||
      old.upstroke != upstroke ||
      old.counter != counter;
}
