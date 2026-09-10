import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/app_colors/app_colors.dart';
import '../../constant/text_styles/app_text_style.dart';

/// Appearance settings row: same anatomy as the other settings tiles,
/// with a single morphing sun/moon glyph as the state control.
/// The whole row is the tap target.
///
/// UI-only — the parent owns the state ([isDark]) and reacts to taps
/// through [onChanged], so it can be reused by any screen regardless of
/// which cubit stores the theme.
class ThemeModeTile extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const ThemeModeTile({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  static const Duration _duration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      toggled: isDark,
      label: 'Theme'.tr(),
      value: isDark ? 'Dark'.tr() : 'Light'.tr(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isDark),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: scheme.appCard,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: Colors.orange,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme'.tr(),
                        style: AppTextStyle.getBoldStyle(
                          color: scheme.appText,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      AnimatedSwitcher(
                        duration: _duration,
                        layoutBuilder: (currentChild, previousChildren) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previousChildren, ?currentChild],
                        ),
                        child: Text(
                          isDark ? 'Dark'.tr() : 'Light'.tr(),
                          key: ValueKey<bool>(isDark),
                          style: AppTextStyle.getRegularStyle(
                            color: scheme.appTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _ThemeMorphGlyph(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Single morphing sun/moon indicator: the sun rotates and cross-fades
/// into the moon inside one softly tinted circle. Purely visual — the
/// enclosing row handles the tap.
class _ThemeMorphGlyph extends StatelessWidget {
  final bool isDark;

  const _ThemeMorphGlyph({required this.isDark});

  static const Duration _duration = Duration(milliseconds: 280);
  static const Color _sunColor = Color(0xFFF59E0B);
  static const Color _moonColor = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? _moonColor : _sunColor;

    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOutCubic,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
      ),
      child: AnimatedSwitcher(
        duration: _duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey<bool>(isDark),
          color: accent,
          size: 18.sp,
        ),
      ),
    );
  }
}
