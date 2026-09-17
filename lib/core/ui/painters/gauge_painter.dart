import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Paints the Apex "readiness gauge" — a tachometer: a tick ring with a redline
/// zone, a gradient progress arc with a soft glow, and a needle. Opening sits at
/// the bottom (270° sweep from 135°). Pure geometry; the numeric readout is an
/// overlaid widget (see GaugeMeter), so it stays crisp and LTR under RTL.
class GaugePainter extends CustomPainter {
  /// 0..1
  final double progress;
  final Color trackColor;
  final Color arcStart;
  final Color arcEnd;
  final Color redline;
  final Color tick;
  final Color needleColor;
  final Color hubColor;

  const GaugePainter({
    required this.progress,
    required this.trackColor,
    required this.arcStart,
    required this.arcEnd,
    required this.redline,
    required this.tick,
    required this.needleColor,
    required this.hubColor,
  });

  static const double _startDeg = 135;
  static const double _sweepDeg = 270;
  static const int _ticks = 40;

  double get _startRad => _startDeg * math.pi / 180;
  double get _sweepRad => _sweepDeg * math.pi / 180;

  Offset _polar(Offset c, double r, double angleRad) =>
      Offset(c.dx + r * math.cos(angleRad), c.dy + r * math.sin(angleRad));

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final sw = size.width * 0.075;
    final r = size.width / 2 - size.width * 0.13;
    final p = progress.clamp(0.0, 1.0);

    // --- ticks ---
    for (var i = 0; i <= _ticks; i++) {
      final a = _startRad + _sweepRad * i / _ticks;
      final major = i % 5 == 0;
      final inRed = i / _ticks > 0.85;
      final rOuter = r + sw * 0.75;
      final rInner = rOuter - (major ? size.width * 0.055 : size.width * 0.03);
      canvas.drawLine(
        _polar(c, rInner, a),
        _polar(c, rOuter, a),
        Paint()
          ..color = inRed ? redline : tick
          ..strokeCap = StrokeCap.round
          ..strokeWidth = major ? 2 : 1,
      );
    }

    final arcRect = Rect.fromCircle(center: c, radius: r);

    // --- track ---
    canvas.drawArc(
      arcRect,
      _startRad,
      _sweepRad,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = sw,
    );

    // --- progress arc (+ glow) ---
    final shader = SweepGradient(
      startAngle: _startRad,
      endAngle: _startRad + _sweepRad,
      colors: [arcStart, arcEnd],
      transform: GradientRotation(_startRad),
    ).createShader(arcRect);

    // glow underlay
    canvas.drawArc(
      arcRect,
      _startRad,
      _sweepRad * p,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = sw
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // crisp arc
    canvas.drawArc(
      arcRect,
      _startRad,
      _sweepRad * p,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = sw,
    );

    // --- needle ---
    final na = _startRad + _sweepRad * p;
    final tip = _polar(c, r - sw * 0.2, na);
    final b1 = _polar(c, size.width * 0.03, na + math.pi / 2);
    final b2 = _polar(c, size.width * 0.03, na - math.pi / 2);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(b1.dx, b1.dy)
        ..lineTo(b2.dx, b2.dy)
        ..close(),
      Paint()..color = needleColor,
    );
    // hub
    canvas.drawCircle(c, size.width * 0.055, Paint()..color = hubColor);
    canvas.drawCircle(
      c,
      size.width * 0.055,
      Paint()
        ..color = needleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter old) =>
      old.progress != progress ||
      old.arcStart != arcStart ||
      old.arcEnd != arcEnd;
}
