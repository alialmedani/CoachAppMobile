import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/cubit/nutrition_log_cubit.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/screen/nutrition_log_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_nutrition_plan_cubit.dart';
import 'my_nutrition_plan_detail_screen.dart';

/// Trainee's own nutrition plans (read-only). Unpaged summary list → tap a
/// plan to load its full tree + macro totals in the detail screen.
class MyNutritionPlansScreen extends StatelessWidget {
  /// Drops the top bar so the screen can sit directly inside the shell tab.
  final bool embedded;

  const MyNutritionPlansScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNutritionPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: embedded
          ? null
          : AppTopBar(
              title: 'my_nutrition_plans'.tr(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'nutrition_history'.tr(),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => getIt<NutritionLogCubit>(),
                        child: const NutritionLogHistoryScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: GetModel<List<NutritionPlanModel>>(
        useCaseCallBack: () => cubit.fetchMyNutritionPlans(),
        modelBuilder: (plans) {
          if (plans.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: AppDesignSystem.spacing4XL.h),
                AppEmptyState(
                  icon: Icons.restaurant_outlined,
                  title: 'no_my_nutrition_plans'.tr(),
                  subtitle: 'no_my_nutrition_plans_subtitle'.tr(),
                  iconColor: AppDesignSystem.primaryColor,
                ),
              ],
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
            itemCount: plans.length,
            itemBuilder: (context, index) => _MyNutritionPlanCard(
              plan: plans[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: MyNutritionPlanDetailScreen(
                      planId: plans[index].id ?? '',
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MyNutritionPlanCard extends StatelessWidget {
  final NutritionPlanModel plan;
  final VoidCallback onTap;

  const _MyNutritionPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: plan.isActive
                  ? AppDesignSystem.primarySurface
                  : AppDesignSystem.neutral100,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.restaurant_menu_outlined,
              color: plan.isActive
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral400,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name ?? '',
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.neutral900,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                if ((plan.description ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    plan.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignSystem.spacingXS.h),
                if (plan.isActive)
                  AppBadge(
                    text: 'active_plan'.tr(),
                    variant: AppBadgeVariant.success,
                    size: AppBadgeSize.small,
                    dot: true,
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}
