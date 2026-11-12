import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/utils/functions/device_locale.dart';

/// In-app language switcher (Arabic / English) for the profile / settings
/// screens of both roles.
///
/// Tapping a language flips the app locale **live** via `easy_localization`
/// (`context.setLocale`) — every `.tr()` string, RTL/LTR direction, and the
/// locale-aware bits (e.g. the exercise instructions) rebuild without an app
/// restart — and **persists** the choice in [CacheHelper] so the app stops
/// following the device language until the user changes it again.
///
/// Language names are shown as endonyms (العربية / English), the usual
/// convention for a language picker, so they read the same regardless of the
/// current UI language.
class LanguageSwitcher extends StatelessWidget {
  /// Fired after the locale has been switched + persisted. The host screen uses
  /// it to rebuild the app content in the new language (e.g. re-route to the
  /// role shell) so cached tabs/screens pick up the change without a restart.
  final VoidCallback? onChanged;

  const LanguageSwitcher({super.key, this.onChanged});

  static const _options = <(String code, String label)>[
    ('ar', 'العربية'),
    ('en', 'English'),
  ];

  Future<void> _select(BuildContext context, String code) async {
    if (context.locale.languageCode == code) return;
    await CacheHelper.setLang(code); // persist the explicit choice
    if (!context.mounted) return;
    await context.setLocale(Locale(code)); // flip the locale singleton + RTL/LTR
    onChanged?.call(); // let the host rebuild cached content in the new language
  }

  /// Undo a manual override: drop the persisted choice, re-detect the device
  /// language, apply it live, and resume following the device going forward.
  Future<void> _resetToDevice(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context); // root — survives re-nav
    await CacheHelper.clearLang(); // back to follow-device mode
    final code = deviceFollowLanguageCode();
    if (!context.mounted) return;
    await context.setLocale(Locale(code)); // apply the device language live
    onChanged?.call(); // rebuild cached screens in the new language
    // Defer to the next frame so the confirmation itself renders in the newly
    // applied (device) language rather than the one we just left.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('language_reset_done'.tr()),
          backgroundColor: AppDesignSystem.successColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = context.locale.languageCode;
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceRaised,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: AppDesignSystem.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.primaryStrong,
              ),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Text(
                'language'.tr(),
                style: AppDesignSystem.h6.copyWith(
                  color: AppDesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Row(
            children: [
              for (var i = 0; i < _options.length; i++) ...[
                if (i > 0) SizedBox(width: AppDesignSystem.spacingSM.w),
                _Option(
                  label: _options[i].$2,
                  selected: current == _options[i].$1,
                  onTap: () => _select(context, _options[i].$1),
                ),
              ],
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Text(
            'language_hint'.tr(),
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.textMuted,
            ),
          ),
          // Shown only when a manual override is in effect — reverts to following
          // the device's system language.
          if (CacheHelper.langOrNull != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _resetToDevice(context),
                icon: Icon(
                  Icons.restart_alt,
                  size: AppDesignSystem.iconSizeSM.sp,
                ),
                label: Text('reset_to_device_language'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: AppDesignSystem.primaryStrong,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.spacingXS.w,
                  ),
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppDesignSystem.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            border: Border.all(
              color: selected
                  ? AppDesignSystem.primaryStrong
                  : AppDesignSystem.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                Icon(
                  Icons.check,
                  size: AppDesignSystem.iconSizeXS.sp,
                  color: AppDesignSystem.primaryDark,
                ),
                SizedBox(width: AppDesignSystem.spacingXS.w),
              ],
              Text(
                label,
                style: AppDesignSystem.labelLarge.copyWith(
                  color: selected
                      ? AppDesignSystem.primaryDark
                      : AppDesignSystem.textMuted,
                  fontWeight: AppDesignSystem.semiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
