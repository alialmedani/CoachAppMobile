import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coachappmobile/core/constant/app_colors/app_colors.dart';

class AnimatedNotchNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<NavigationBarItemConfig> items;
  final Function(int index) onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;

  final VoidCallback? onCenterTap;
  final IconData centerIcon;
  final Color? centerColor;

  const AnimatedNotchNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.onCenterTap,
    this.centerIcon = Icons.qr_code_scanner_rounded,
    this.centerColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color accent = selectedColor ?? colorScheme.appPrimary;
    final Color muted = unselectedColor ?? colorScheme.appIconMuted;
    final Color surface = backgroundColor ?? colorScheme.appCard;

    final List<Widget> rowChildren;
    if (onCenterTap != null) {
      final int leftCount = items.length ~/ 2;
      rowChildren = [
        for (int i = 0; i < leftCount; i++)
          _buildItem(context, i, accent, muted),
        _buildCenterButton(context, accent),
        for (int i = leftCount; i < items.length; i++)
          _buildItem(context, i, accent, muted),
      ];
    } else {
      rowChildren = [
        for (int i = 0; i < items.length; i++)
          _buildItem(context, i, accent, muted),
      ];
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: colorScheme.appBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.appShadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Color accent,
    Color muted,
  ) {
    final isSelected = currentIndex == index;
    final item = items[index];
    final Color fg = isSelected ? accent : muted;

    String safeTranslate(String keyOrValue) {
      final isKey = RegExp(r'^[A-Za-z0-9_]+$').hasMatch(keyOrValue);
      return isKey ? keyOrValue.tr() : keyOrValue;
    }

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(14.r),
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.06),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Soft "accent" wash behind the active icon.
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  color: fg,
                  size: 21.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                safeTranslate(item.label),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.appTextTertiary,
                  fontSize: 9.5.sp,
                  height: 1.1,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              // Small animated indicator pill under the active item.
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 2.5.h,
                width: isSelected ? 16.w : 0,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, Color accent) {
    final Color color = centerColor ?? accent;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Soft outer ring for an elevated, premium look.
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
            ),
            child: Material(
              shape: const CircleBorder(),
              elevation: 5,
              shadowColor: color.withValues(alpha: 0.5),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onCenterTap,
                child: Container(
                  width: 52.r,
                  height: 52.r,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        Color.lerp(color, Colors.black, 0.12) ?? color,
                      ],
                    ),
                  ),
                  child: Icon(
                    centerIcon,
                    color: Theme.of(context).colorScheme.appOnPrimary,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationBarItemConfig {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavigationBarItemConfig({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
