import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One point on a metric trend (already sorted oldest → newest by the caller).
class TrendPoint {
  final DateTime date;
  final double value;

  const TrendPoint(this.date, this.value);
}

/// A minimalist line chart of a single metric over time (weight, body-fat, …),
/// drawn with a [CustomPainter] so it needs no charting dependency. Shows the
/// latest value + the change since the first point, and handles 0 / 1 / many
/// points. Reusable by coach Progress (Phase 11) and trainee Progress (Phase 16).
class ProgressTrendChart extends StatelessWidget {
  final String title;
  final String unit;
  final List<TrendPoint> points;

  const ProgressTrendChart({
    super.key,
    required this.title,
    required this.unit,
    required this.points,
  });

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final latest = points.isNotEmpty ? points.last.value : null;
    final delta = points.length >= 2
        ? points.last.value - points.first.value
        : null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ),
              if (latest != null)
                Text(
                  '${_n(latest)} $unit',
                  style: AppDesignSystem.labelLarge.copyWith(
                    color: AppDesignSystem.primaryColor,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
            ],
          ),
          if (delta != null) ...[
            SizedBox(height: AppDesignSystem.spacing2XS.h),
            Row(
              children: [
                Icon(
                  delta > 0
                      ? Icons.trending_up
                      : (delta < 0 ? Icons.trending_down : Icons.trending_flat),
                  size: AppDesignSystem.iconSizeXS.sp,
                  color: AppDesignSystem.neutral500,
                ),
                SizedBox(width: AppDesignSystem.spacingXS.w),
                Text(
                  '${delta > 0 ? '+' : ''}${_n(delta)} $unit',
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingMD.h),
          if (points.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppDesignSystem.spacingLG.h,
              ),
              child: Center(
                child: Text(
                  'no_progress_points'.tr(),
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral400,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 120.h,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendPainter(
                  points: points,
                  lineColor: AppDesignSystem.primaryColor,
                  fillColor: AppDesignSystem.primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  gridColor: AppDesignSystem.neutral200,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<TrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _TrendPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    // Top & bottom guide lines.
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), grid);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      grid,
    );

    final values = points.map((p) => p.value).toList();
    double minV = values.reduce((a, b) => a < b ? a : b);
    double maxV = values.reduce((a, b) => a > b ? a : b);
    if (maxV == minV) {
      // Flat series (incl. a single point): pad so the line sits mid-height.
      minV -= 1;
      maxV += 1;
    }
    final range = maxV - minV;
    final n = points.length;

    Offset at(int i) {
      final x = n == 1 ? size.width / 2 : size.width * (i / (n - 1));
      final y = size.height - ((points[i].value - minV) / range) * size.height;
      return Offset(x, y);
    }

    final linePath = Path();
    for (var i = 0; i < n; i++) {
      final o = at(i);
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
      } else {
        linePath.lineTo(o.dx, o.dy);
      }
    }

    // Area fill under the line.
    final fillPath = Path.from(linePath)
      ..lineTo(at(n - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots.
    final dot = Paint()..color = lineColor;
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(at(i), 3, dot);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points ||
      old.lineColor != lineColor ||
      old.fillColor != fillColor;
}
