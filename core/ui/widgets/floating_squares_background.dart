import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constant/app_colors/app_colors.dart';

/// A subtle, premium animated background of slowly drifting rounded squares —
/// inspired by the Bakeet logo (which is built from small rounded tiles).
///
/// Designed as the BOTTOM layer of a (mostly white) auth screen: the squares
/// are rendered as light, low-opacity fills so they read as soft brand texture
/// without hurting the legibility of the form on top.
///
/// Performance notes:
///  * A single long-running [AnimationController] drives a [CustomPainter].
///  * Only the painter repaints each frame (via [CustomPaint.repaint]); the
///    widget tree itself is not rebuilt.
///  * The square layout is generated ONCE with a fixed seed, so it is
///    deterministic and stable across rebuilds (no re-rolling per build).
///
/// Reusable: defaults to the login look, but [squareCount] and the two colors
/// can be overridden so the same texture can later be reused on splash /
/// register for brand consistency.
class FloatingSquaresBackground extends StatefulWidget {
  const FloatingSquaresBackground({
    super.key,
    this.squareCount = 11,
    this.colorA, // logo purple   (defaults to AppColors.primary  #6C4CE5)
    this.colorB, // logo green    (defaults to AppColors.secoundPrimary #00CF9D)
    this.duration = const Duration(seconds: 24),
    this.seed = 42,
  });

  /// Number of squares to scatter (tasteful range ~8–14).
  final int squareCount;

  /// First brand color (purple by default).
  final Color? colorA;

  /// Second brand color (green by default).
  final Color? colorB;

  /// Full loop duration of the drift cycle. Longer = calmer.
  final Duration duration;

  /// Fixed seed → deterministic layout.
  final int seed;

  @override
  State<FloatingSquaresBackground> createState() =>
      _FloatingSquaresBackgroundState();
}

class _FloatingSquaresBackgroundState extends State<FloatingSquaresBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SquareSpec> _squares;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
    _squares = _buildSquares();
  }

  List<_SquareSpec> _buildSquares() {
    // Deterministic pseudo-random layout — generated once.
    final rng = math.Random(widget.seed);
    final colorA = widget.colorA ?? AppColors.primary;
    final colorB = widget.colorB ?? AppColors.secoundPrimary;

    return List<_SquareSpec>.generate(widget.squareCount, (i) {
      final color = i.isEven ? colorA : colorB;
      // Sizes as a fraction of the smaller canvas side (small → medium).
      final sizeFactor = 0.07 + rng.nextDouble() * 0.13; // 7%–20%
      return _SquareSpec(
        // Anchor positions as fractions of the canvas (0..1).
        baseX: rng.nextDouble(),
        baseY: rng.nextDouble(),
        sizeFactor: sizeFactor,
        // Light, low-opacity fills: ~6%–14% alpha, varied per square.
        opacity: 0.06 + rng.nextDouble() * 0.08,
        color: color,
        // Per-square phase so squares never move in lockstep.
        phase: rng.nextDouble() * math.pi * 2,
        // Gentle drift amplitudes (fractions of canvas).
        driftY: 0.04 + rng.nextDouble() * 0.06, // vertical drift
        swayX: 0.015 + rng.nextDouble() * 0.03, // slight horizontal sway
        // Slow rotation, randomly signed, plus a subtle scale pulse.
        rotationAmplitude:
            (0.10 + rng.nextDouble() * 0.18) * (rng.nextBool() ? 1 : -1),
        scalePulse: 0.03 + rng.nextDouble() * 0.05,
        // Slightly different speed multipliers for an organic feel.
        speed: 0.8 + rng.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _FloatingSquaresPainter(
          squares: _squares,
          progress: _controller, // repaint listenable
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SquareSpec {
  const _SquareSpec({
    required this.baseX,
    required this.baseY,
    required this.sizeFactor,
    required this.opacity,
    required this.color,
    required this.phase,
    required this.driftY,
    required this.swayX,
    required this.rotationAmplitude,
    required this.scalePulse,
    required this.speed,
  });

  final double baseX;
  final double baseY;
  final double sizeFactor;
  final double opacity;
  final Color color;
  final double phase;
  final double driftY;
  final double swayX;
  final double rotationAmplitude;
  final double scalePulse;
  final double speed;
}

class _FloatingSquaresPainter extends CustomPainter {
  _FloatingSquaresPainter({required this.squares, required this.progress})
    : super(repaint: progress);

  final List<_SquareSpec> squares;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value * 2 * math.pi; // 0..2π over the loop
    final minSide = math.min(size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final s in squares) {
      final angle = t * s.speed + s.phase;

      // Looping drift: vertical drift + slight horizontal sway (sin/cos).
      final dx = s.swayX * size.width * math.cos(angle);
      final dy = s.driftY * size.height * math.sin(angle);

      final cx = s.baseX * size.width + dx;
      final cy = s.baseY * size.height + dy;

      // Subtle scale pulse + slow rotation.
      final scale = 1.0 + s.scalePulse * math.sin(angle * 0.7);
      final rotation = s.rotationAmplitude * math.sin(angle * 0.5);

      final side = s.sizeFactor * minSide * scale;
      final radius = side * 0.28; // logo-tile-like rounded corners

      paint.color = s.color.withValues(alpha: s.opacity);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: side,
        height: side,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingSquaresPainter oldDelegate) {
    // Repaint is driven by the controller via `repaint:`; layout is stable.
    return oldDelegate.squares != squares;
  }
}
