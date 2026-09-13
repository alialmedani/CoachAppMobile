import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/nutrition_plan_viewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_nutrition_plan_cubit.dart';

/// Read-only view of one of the trainee's nutrition plans: authoritative server
/// macro totals ([MacroSummaryCard]) + the meal → item tree
/// ([NutritionPlanViewer]). No coach actions.
class MyNutritionPlanDetailScreen extends StatelessWidget {
  final String planId;

  const MyNutritionPlanDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNutritionPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'nutrition_plan_details'.tr()),
      body: GetModel<NutritionPlanModel>(
        useCaseCallBack: () => cubit.fetchMyNutritionPlanById(planId),
        modelBuilder: (plan) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name ?? '',
                      style: AppDesignSystem.h4.copyWith(
                        color: AppDesignSystem.neutral900,
                      ),
                    ),
                    if ((plan.description ?? '').isNotEmpty) ...[
                      SizedBox(height: AppDesignSystem.spacingXS.h),
                      Text(
                        plan.description!,
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: AppDesignSystem.neutral600,
                          height: 1.5,
                        ),
                      ),
                    ],
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppBadge(
                      text: (plan.isActive ? 'active' : 'inactive').tr(),
                      variant: plan.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      dot: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              MacroSummaryCard(
                calories: plan.totalCalories,
                proteinG: plan.totalProteinG,
                carbsG: plan.totalCarbsG,
                fatG: plan.totalFatG,
                targetCalories: plan.targetCalories,
                targetProteinG: plan.targetProteinG,
                targetCarbsG: plan.targetCarbsG,
                targetFatG: plan.targetFatG,
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: AppDesignSystem.spacingXS.w,
                  bottom: AppDesignSystem.spacingXS.h,
                ),
                child: Text(
                  'meals'.tr(),
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ),
              NutritionPlanViewer(plan: plan),
              SizedBox(height: AppDesignSystem.spacingXL.h),
            ],
          ),
        ),
      ),
    );
  }
}
