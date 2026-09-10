import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_design_system.dart';
import '../../utils/functions/app_logo_provider.dart';

/// Shared CoachApp home top bar: the app logo on the leading side and a pair of
/// soft, tinted icon buttons (profile + notifications) on the trailing side.
///
/// Presentational and **feature-agnostic** — it carries no cubit or feature
/// import. Pass [onProfileTap] / [onNotificationsTap] to show each action (a
/// button is hidden when its callback is null), and [unreadCount] to drive the
/// notifications badge. A screen with a notifications feature typically wraps
/// this in a `BlocBuilder` and feeds the live count in. Reads correctly under
/// RTL Arabic.
///
/// Slim, shadcn-styled header: a clean card surface with a crisp hairline bottom
/// border and soft tinted icon buttons.
class HomeTopBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationsTap;
  final int unreadCount;

  const HomeTopBar({
    super.key,
    this.onProfileTap,
    this.onNotificationsTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (onProfileTap != null)
        _SoftIconButton(
          icon: Icons.person_outline_rounded,
          onTap: onProfileTap!,
        ),
      if (onNotificationsTap != null)
        _SoftIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: unreadCount,
          tinted: true,
          onTap: onNotificationsTap!,
        ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingMD.w,
        vertical: AppDesignSystem.spacingSM.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.appCard,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.appBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          appLogo(height: 30.h),
          const Spacer(),
          for (int i = 0; i < actions.length; i++) ...[
            if (i != 0) SizedBox(width: AppDesignSystem.spacingSM.w),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// A refined, square-rounded icon button with a soft fill and a faint hairline,
/// matching the shadcn aesthetic. When [tinted] is set, it uses a subtle brand
/// teal wash to draw a touch more attention (used for notifications).
class _SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool tinted;

  const _SoftIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color fill = tinted
        ? AppDesignSystem.primaryColor.withValues(alpha: 0.08)
        : scheme.appSurfaceMuted;
    final Color border = tinted
        ? AppDesignSystem.primaryColor.withValues(alpha: 0.16)
        : scheme.appBorder;
    final Color iconColor =
        tinted ? AppDesignSystem.primaryColor : scheme.appText;

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        onTap: onTap,
        child: Container(
          width: 38.r,
          height: 38.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            border: Border.all(color: border, width: 1),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 21.sp, color: iconColor),
              if (badgeCount > 0)
                Positioned(
                  right: -7.w,
                  top: -7.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 0.5.h,
                    ),
                    constraints: BoxConstraints(minWidth: 15.w),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.errorColor,
                      borderRadius:
                          BorderRadius.circular(AppDesignSystem.radiusFull.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.appCard,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
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
