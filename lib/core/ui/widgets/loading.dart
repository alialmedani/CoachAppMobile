import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/apex/ascent_monogram.dart';

/// Apex "Orbit" loader — the app's branded loading state (used by the get_model
/// and pagination_list boilerplate). A single Volt comet with a tapering
/// sweep-gradient tail circles a still Ascent monogram over a hairline track and
/// a faint watch-dial tick bezel, with a soft glow that breathes at the centre.
/// Replaces the legacy ported (NOON) logo loader.
class LoadingWidget extends StatefulWidget {
  final double? width;
  final double? height;

  const LoadingWidget({super.key, this.width, this.height});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2900),
    )..repeat();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotation.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.width ?? widget.height ?? 132.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_rotation, _breath]),
                  builder: (context, _) => CustomPaint(
                    painter: _OrbitPainter(
                      t: _rotation.value,
                      breathe: Curves.easeInOut.transform(_breath.value),
                      volt: AppDesignSystem.primaryColor,
                      head: Color.lerp(
                        AppDesignSystem.primaryColor,
                        Colors.white,
                        0.55,
                      )!,
                      track: AppDesignSystem.borderColor,
                      tick: AppDesignSystem.borderStrong,
                    ),
                  ),
                ),
              ),
              AscentMonogram(
                size: size * 0.42,
                background: AppDesignSystem.surfaceRaised,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double t; // rotation phase 0..1
  final double breathe; // eased 0..1
  final Color volt;
  final Color head;
  final Color track;
  final Color tick;

  _OrbitPainter({
    required this.t,
    required this.breathe,
    required this.volt,
    required this.head,
    required this.track,
    required this.tick,
  });

  static const double _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) / 2;
    final rTrack = r * 0.80;
    final cometWidth = r * 0.048;

    // --- centre glow (breathes) ---
    final glowR = r * 0.62;
    canvas.drawCircle(
      c,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            volt.withValues(alpha: 0.12 + 0.16 * breathe),
            volt.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: glowR)),
    );

    // --- watch-dial tick bezel ---
    const ticks = 60;
    final tickPaint = Paint()
      ..color = tick.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final rOuter = r * 0.99;
    final rInner = rOuter - r * 0.05;
    for (var i = 0; i < ticks; i++) {
      final a = _tau * i / ticks;
      final ct = math.cos(a), st = math.sin(a);
      canvas.drawLine(
        Offset(c.dx + ct * rInner, c.dy + st * rInner),
        Offset(c.dx + ct * rOuter, c.dy + st * rOuter),
        tickPaint,
      );
    }

    // --- hairline track ring ---
    canvas.drawCircle(
      c,
      rTrack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = track.withValues(alpha: 0.85),
    );

    // --- faint counter-bead (depth) ---
    final beadA = -_tau * t * 0.42 + math.pi;
    canvas.drawCircle(
      Offset(c.dx + math.cos(beadA) * rTrack, c.dy + math.sin(beadA) * rTrack),
      r * 0.018,
      Paint()
        ..color = volt.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // --- the comet (tapering sweep-gradient tail + glowing head) ---
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_tau * t);
    final rect = Rect.fromCircle(center: Offset.zero, radius: rTrack);
    final comet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cometWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          volt.withValues(alpha: 0),
          volt.withValues(alpha: 0),
          volt.withValues(alpha: 0.12),
          volt.withValues(alpha: 0.5),
          volt,
          head,
        ],
        stops: const [0.0, 0.55, 0.72, 0.90, 0.98, 1.0],
      ).createShader(rect);
    canvas.drawArc(rect, 0, _tau * 0.999, false, comet);

    // glowing head at the leading end (local angle 0)
    final headC = Offset(rTrack, 0);
    canvas.drawCircle(
      headC,
      r * 0.055,
      Paint()
        ..color = volt.withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
    );
    canvas.drawCircle(headC, r * 0.036, Paint()..color = head);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) =>
      old.t != t || old.breathe != breathe;
}
