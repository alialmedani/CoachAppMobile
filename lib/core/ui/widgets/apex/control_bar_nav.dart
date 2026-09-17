import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';
import '../../../constant/app_icons/app_icons.dart';
import '../../shapes/chamfer.dart';
import '../app_icon.dart';

/// One destination in the [ControlBarNav].
class ControlBarItem {
  final String iconAsset; // an AppIcons path
  final String label; // already-localized label
  const ControlBarItem({required this.iconAsset, required this.label});
}

/// The Apex signature navigation — a chamfered floating bar with bespoke icons
/// and a **raised, always-lime center action** (the "Log" shortcut) that breaks
/// the top edge. RTL-aware: the flank tabs follow reading direction; the raised
/// action stays centered.
///
/// [primaryIndex] is the destination rendered as the raised center button
/// (typically Today, the logging hub). [centerIcon] defaults to the bolt.
class ControlBarNav extends StatelessWidget {
  final List<ControlBarItem> items;
  final int currentIndex;
  final int primaryIndex;
  final String centerIcon;
  final ValueChanged<int> onTap;

  const ControlBarNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.primaryIndex,
    this.centerIcon = AppIcons.bolt,
  });

  static const double _barH = 62;
  static const double _raise = 20;
  static const double _cta = 56;

  @override
  Widget build(BuildContext context) {
    final flanks = <int>[
      for (var i = 0; i < items.length; i++)
        if (i != primaryIndex) i,
    ];
    final half = (flanks.length / 2).round();
    final left = flanks.sublist(0, half);
    final right = flanks.sublist(half);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: (_barH + _raise).h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ---- the floating bar ----
              PositionedDirectional(
                bottom: 0,
                start: 0,
                end: 0,
                child: Container(
                  height: _barH.h,
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                  decoration: ShapeDecoration(
                    color: AppDesignSystem.surfaceRaised,
                    shape: ChamferBorder(
                      cut: 20,
                      corners: const {ChamferCorner.topLeft, ChamferCorner.topRight},
                      side: BorderSide(color: AppDesignSystem.borderColor),
                    ),
                    shadows: AppDesignSystem.shadowMD,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [for (final i in left) Expanded(child: _Tab(
                            item: items[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          ))],
                        ),
                      ),
                      SizedBox(width: (_cta + 12).w),
                      Expanded(
                        child: Row(
                          children: [for (final i in right) Expanded(child: _Tab(
                            item: items[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          ))],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- raised center action ----
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _RaisedAction(
                    icon: centerIcon,
                    size: _cta.w,
                    onTap: () => onTap(primaryIndex),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final ControlBarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppDesignSystem.primaryStrong
        : AppDesignSystem.textFaint;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(item.iconAsset, size: 22, color: color),
            SizedBox(height: 3.h),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppDesignSystem.fontFamily,
                fontSize: 9.5.sp,
                fontWeight: AppDesignSystem.bold,
                letterSpacing: 0.2,
                color: selected
                    ? AppDesignSystem.textPrimary
                    : AppDesignSystem.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaisedAction extends StatelessWidget {
  final String icon;
  final double size;
  final VoidCallback onTap;

  const _RaisedAction({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Dark "moat" keeps the raised lime button crisp against any lime content
      // (e.g. a full-width log CTA) that scrolls up behind it.
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: ShapeDecoration(
          color: AppDesignSystem.surfaceCanvas,
          shape: ChamferBorder(cut: 20.w),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: ShapeDecoration(
            color: AppDesignSystem.primaryColor,
            shape: const ChamferBorder(cut: 16),
            shadows: [
              BoxShadow(
                color: AppDesignSystem.primaryColor.withValues(alpha: 0.40),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: AppIcon(icon, size: 26, color: AppDesignSystem.onPrimary),
          ),
        ),
      ),
    );
  }
}
