import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/templates/templates_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lightweight coach home / landing screen.
///
/// A greeting header plus a permission-gated grid of entry-point cards into the
/// existing coach areas. It holds no state of its own and makes no API call —
/// it reads the signed-in coach from [SessionCubit] and either switches shell
/// tabs (via [onOpenTab]) or pushes the self-providing [TemplatesScreen].
///
/// Deliberately carries **no counts/summary numbers** (the shared
/// `PaginatedResult` discards `totalCount`, so clean counts aren't available)
/// and **no FloatingActionButton** (keeps the landing Hero-collision-free).
class CoachDashboardScreen extends StatelessWidget {
  /// Switch the enclosing shell to the tab with this label key. The shell owns
  /// the tab list, so the dashboard just names the target and lets it resolve.
  final void Function(String labelKey)? onOpenTab;

  const CoachDashboardScreen({super.key, this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final userName = session.session?.userName;

    final cards = <_QuickAccessCard>[
      if (session.can(CoachPermissions.trainees))
        _QuickAccessCard(
          labelKey: 'trainees',
          icon: Icons.people_outline,
          onTap: () => onOpenTab?.call('tab_trainees'),
        ),
      if (session.can(CoachPermissions.exercises))
        _QuickAccessCard(
          labelKey: 'exercise_library',
          icon: Icons.fitness_center,
          onTap: () => onOpenTab?.call('tab_library'),
        ),
      if (session.can(CoachPermissions.foods))
        _QuickAccessCard(
          labelKey: 'food_library',
          icon: Icons.restaurant_outlined,
          onTap: () => onOpenTab?.call('tab_library'),
        ),
      if (session.can(CoachPermissions.workoutPlans))
        _QuickAccessCard(
          labelKey: 'workout_plans',
          icon: Icons.assignment_outlined,
          onTap: () => onOpenTab?.call('tab_plans'),
        ),
      if (session.can(CoachPermissions.nutritionPlans))
        _QuickAccessCard(
          labelKey: 'nutrition_plans',
          icon: Icons.restaurant_menu_outlined,
          onTap: () => onOpenTab?.call('tab_plans'),
        ),
      if (session.can(CoachPermissions.workoutPlanTemplates) ||
          session.can(CoachPermissions.nutritionPlanTemplates))
        _QuickAccessCard(
          labelKey: 'templates',
          icon: Icons.bookmarks_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TemplatesScreen()),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'dashboard'.tr()),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppDesignSystem.spacingMD.w,
          AppDesignSystem.spacingMD.h,
          AppDesignSystem.spacingMD.w,
          AppDesignSystem.spacing4XL.h,
        ),
        children: [
          _GreetingHeader(userName: userName),
          if (cards.isNotEmpty) ...[
            SizedBox(height: AppDesignSystem.spacingLG.h),
            Text(
              'quick_access'.tr(),
              style: AppDesignSystem.h6.copyWith(
                color: AppDesignSystem.neutral900,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDesignSystem.spacingSM.h,
              crossAxisSpacing: AppDesignSystem.spacingSM.w,
              childAspectRatio: 1.35,
              children: [for (final card in cards) card],
            ),
          ],
        ],
      ),
    );
  }
}

/// Greeting card: a welcome line plus the coach's name when available.
class _GreetingHeader extends StatelessWidget {
  final String? userName;

  const _GreetingHeader({this.userName});

  @override
  Widget build(BuildContext context) {
    final hasName = (userName ?? '').isNotEmpty;
    return AppCard(
      backgroundColor: AppDesignSystem.primaryColor,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.surfaceWhite.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.waving_hand_outlined,
              color: AppDesignSystem.surfaceWhite,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back'.tr(),
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.surfaceWhite.withValues(alpha: 0.85),
                  ),
                ),
                if (hasName) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    userName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.h5.copyWith(
                      color: AppDesignSystem.surfaceWhite,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single tappable quick-access tile: an icon over a label.
class _QuickAccessCard extends StatelessWidget {
  final String labelKey;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.labelKey,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primarySurface,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              icon,
              color: AppDesignSystem.primaryDark,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Text(
            labelKey.tr(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppDesignSystem.labelLarge.copyWith(
              color: AppDesignSystem.neutral900,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
