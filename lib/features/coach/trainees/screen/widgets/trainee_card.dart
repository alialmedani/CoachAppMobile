import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/trainee_model.dart';

/// A single trainee row in the coach's roster — the Apex roster card: a
/// chamfered Volt medallion, the athlete's name + handle, a goal chip and a live
/// status chip. Reused verbatim on the coach Dashboard's "Your Athletes" rail.
class TraineeCard extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onTap;

  const TraineeCard({super.key, required this.trainee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = trainee.isActive;
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Row(
        children: [
          _Medallion(initial: trainee.initial, active: active),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainee.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: AppDesignSystem.extraBold,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  '@${trainee.userName ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.textMuted,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingXS.h),
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacing2XS.h,
                  children: [
                    AppBadge(
                      text: trainee.goal.labelKey.tr(),
                      variant: AppBadgeVariant.info,
                      size: AppBadgeSize.small,
                      icon: Icons.flag_outlined,
                    ),
                    _StatusChip(active: active),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.textFaint,
            size: AppDesignSystem.iconSizeMD.sp,
          ),
        ],
      ),
    );
  }
}

/// The athlete's initial on a chamfered, Volt-tinted tile — the roster echo of
/// the credential's medallion. Dims to a neutral tile when inactive.
class _Medallion extends StatelessWidget {
  final String initial;
  final bool active;

  const _Medallion({required this.initial, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppDesignSystem.primaryColor.withValues(alpha: 0.18),
                  AppDesignSystem.primaryColor.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: active ? null : AppDesignSystem.surfaceSunken,
        shape: ChamferBorder(
          cut: 12,
          side: BorderSide(
            color: active
                ? AppDesignSystem.primaryColor.withValues(alpha: 0.45)
                : AppDesignSystem.borderColor,
            width: 1.1,
          ),
        ),
      ),
      child: Text(
        initial,
        style: AppDesignSystem.h5.copyWith(
          color: active
              ? AppDesignSystem.primaryStrong
              : AppDesignSystem.textFaint,
          fontWeight: AppDesignSystem.extraBold,
        ),
      ),
    );
  }
}

/// A compact static status chip (a live pulse is reserved for the single
/// credential on the profile; a list of pulsing dots would be noise).
class _StatusChip extends StatelessWidget {
  final bool active;
  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppDesignSystem.successColor : AppDesignSystem.textFaint;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignSystem.spacingXS.w,
        vertical: AppDesignSystem.spacing2XS.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: AppDesignSystem.spacing2XS.w),
          Text(
            (active ? 'active' : 'inactive').tr(),
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSizeXS.sp,
              fontWeight: AppDesignSystem.bold,
              letterSpacing: 0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
