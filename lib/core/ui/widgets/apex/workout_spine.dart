import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';
import '../app_icon.dart';
import '../../../constant/app_icons/app_icons.dart';

enum SpineNodeState { done, current, upcoming, rest }

/// One node on the workout [WorkoutSpine].
class SpineNodeData {
  final String title;
  final String? subtitle;

  /// 2-digit order label (e.g. "03" / "٠٣"); localised digits are the caller's
  /// job. Ignored for [SpineNodeState.done] (shows a check) and `rest`.
  final String? indexLabel;
  final SpineNodeState state;
  final int pipsDone;
  final int pipsTotal;

  const SpineNodeData({
    required this.title,
    this.subtitle,
    this.indexLabel,
    this.state = SpineNodeState.upcoming,
    this.pipsDone = 0,
    this.pipsTotal = 0,
  });
}

/// The Apex "spine" — the session rendered as a vertical circuit: a rail with
/// numbered node markers, per-exercise set pips and inline rest nodes. Progress
/// climbs the rail in Volt. RTL-aware (the rail sits on the start edge).
class WorkoutSpine extends StatelessWidget {
  final List<SpineNodeData> nodes;
  const WorkoutSpine({super.key, required this.nodes});

  bool _reached(int i) =>
      nodes[i].state == SpineNodeState.done ||
      nodes[i].state == SpineNodeState.current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < nodes.length; i++)
          _SpineRow(
            data: nodes[i],
            isFirst: i == 0,
            isLast: i == nodes.length - 1,
            topLit: i > 0 && _reached(i),
            bottomLit: nodes[i].state == SpineNodeState.done,
          ),
      ],
    );
  }
}

class _SpineRow extends StatelessWidget {
  final SpineNodeData data;
  final bool isFirst;
  final bool isLast;
  final bool topLit;
  final bool bottomLit;

  const _SpineRow({
    required this.data,
    required this.isFirst,
    required this.isLast,
    required this.topLit,
    required this.bottomLit,
  });

  @override
  Widget build(BuildContext context) {
    final lit = AppDesignSystem.primaryColor;
    final dim = AppDesignSystem.borderColor;
    final rest = data.state == SpineNodeState.rest;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- rail + dot ----
          SizedBox(
            width: 34.w,
            child: Column(
              children: [
                // stub above the dot (aligns dot with the card's first line)
                SizedBox(
                  height: 13.h,
                  child: Center(
                    child: Container(
                      width: 2.w,
                      color: isFirst ? Colors.transparent : (topLit ? lit : dim),
                    ),
                  ),
                ),
                _Dot(state: data.state, indexLabel: data.indexLabel),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 2.w,
                      color: isLast ? Colors.transparent : (bottomLit ? lit : dim),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingSM.w),
          // ---- body ----
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
              child: rest ? _restBody() : _card(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restBody() => Padding(
    padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
    child: Text(
      data.title,
      style: TextStyle(
        fontFamily: AppDesignSystem.fontFamily,
        fontSize: AppDesignSystem.fontSizeSM.sp,
        fontWeight: AppDesignSystem.bold,
        letterSpacing: 1,
        color: AppDesignSystem.textMuted,
      ),
    ),
  );

  Widget _card() {
    final current = data.state == SpineNodeState.current;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingMD.w,
        vertical: AppDesignSystem.spacingSM.h,
      ),
      decoration: BoxDecoration(
        color: current
            ? Color.alphaBlend(
                AppDesignSystem.primaryColor.withValues(alpha: 0.07),
                AppDesignSystem.surfaceCard,
              )
            : AppDesignSystem.surfaceCard,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(
          color: current
              ? AppDesignSystem.primaryColor.withValues(alpha: 0.55)
              : AppDesignSystem.borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontFamily: AppDesignSystem.fontFamily,
                    fontSize: AppDesignSystem.fontSizeBase.sp,
                    fontWeight: AppDesignSystem.bold,
                    color: AppDesignSystem.textPrimary,
                  ),
                ),
                if (data.subtitle != null) ...[
                  SizedBox(height: 2.h),
                  // Subtitle is a technical "sets × reps · rest" string — force
                  // LTR so the numbers/×/· don't visually reorder in Arabic.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      data.subtitle!,
                      style: TextStyle(
                        fontFamily: AppDesignSystem.fontFamily,
                        fontSize: AppDesignSystem.fontSizeXS.sp,
                        fontWeight: AppDesignSystem.medium,
                        color: AppDesignSystem.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (data.pipsTotal > 0) _Pips(done: data.pipsDone, total: data.pipsTotal),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final SpineNodeState state;
  final String? indexLabel;
  const _Dot({required this.state, this.indexLabel});

  @override
  Widget build(BuildContext context) {
    final lit = AppDesignSystem.primaryColor;
    final size = 30.w;
    switch (state) {
      case SpineNodeState.done:
        return _base(
          size,
          fill: lit,
          border: lit,
          child: Icon(Icons.check_rounded,
              size: 16.sp, color: AppDesignSystem.onPrimary),
        );
      case SpineNodeState.current:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: lit.withValues(alpha: 0.35),
                blurRadius: 0,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _base(
            size,
            fill: lit,
            border: lit,
            child: _num(indexLabel, AppDesignSystem.onPrimary),
          ),
        );
      case SpineNodeState.rest:
        return _base(
          size,
          fill: Colors.transparent,
          border: AppDesignSystem.borderStrong,
          child: AppIcon(AppIcons.timer,
              size: 13, color: AppDesignSystem.textMuted),
        );
      case SpineNodeState.upcoming:
        return _base(
          size,
          fill: AppDesignSystem.surfaceSunken,
          border: AppDesignSystem.borderColor,
          child: _num(indexLabel, AppDesignSystem.textMuted),
        );
    }
  }

  Widget _num(String? label, Color color) => Text(
    label ?? '',
    style: TextStyle(
      fontFamily: AppDesignSystem.fontFamily,
      fontSize: 11.sp,
      fontWeight: AppDesignSystem.bold,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );

  Widget _base(double size,
          {required Color fill, required Color border, required Widget child}) =>
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: border, width: 2),
        ),
        child: child,
      );
}

class _Pips extends StatelessWidget {
  final int done;
  final int total;
  const _Pips({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 12.w,
            height: 5.h,
            margin: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 3.w),
            decoration: BoxDecoration(
              color: i < done
                  ? AppDesignSystem.primaryColor
                  : AppDesignSystem.surfaceSunken,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
      ],
    );
  }
}
