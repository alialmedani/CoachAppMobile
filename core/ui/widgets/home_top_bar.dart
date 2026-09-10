import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_design_system.dart';
import '../../services/realtime/realtime_service.dart';
import '../../utils/Navigation/navigation.dart';
import '../../utils/functions/app_logo_provider.dart';
// import '../../../features/Express/notifications/cubit/notification_cubit.dart';
// import '../../../features/Express/notifications/screen/notifications_screen.dart';
// import '../../../features/Express/user/profile/screen/profile_screen.dart';

/// Shared home top bar: Bakeet logo + profile + notifications bell (with a live
/// unread badge). Used on the merchant, driver and delivery home screens.
///
/// Slim, shadcn-styled header: a clean white surface with a crisp hairline
/// bottom border, the brand logo on the leading side, and a pair of soft
/// tinted icon buttons (profile + notifications) on the trailing side. Reads
/// correctly under RTL Arabic.
class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  // StreamSubscription<RealtimeNotification>? _sub;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) context.read<NotificationCubit>().refreshUnreadCount();
    // });
    // Keep the badge live: refresh the count whenever something arrives.
    // _sub = RealtimeService.instance.events.listen((_) {
    //   if (mounted) context.read<NotificationCubit>().refreshUnreadCount();
    // });
  }

  @override
  void dispose() {
    // _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _SoftIconButton(icon: Icons.person_outline_rounded, onTap: () {}),
          SizedBox(width: AppDesignSystem.spacingSM.w),
          // BlocBuilder<NotificationCubit, NotificationState>(
          //   builder: (context, state) {
          //     final count = context.read<NotificationCubit>().unreadCount;
          //     return _SoftIconButton(
          //       icon: Icons.notifications_none_rounded,
          //       badgeCount: count,
          //       tinted: true,
          //       onTap: () => Navigation.push(const NotificationsScreen()),
          //     );
          //   },
          // ),
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
    final Color iconColor = tinted
        ? AppDesignSystem.primaryColor
        : scheme.appText;

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
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusFull.r,
                      ),
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
