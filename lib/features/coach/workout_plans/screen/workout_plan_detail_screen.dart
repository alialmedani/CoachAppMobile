import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_plan_cubit.dart';
import '../data/model/workout_plan_model.dart';
import 'widgets/plan_viewer.dart';
import 'workout_plan_builder_screen.dart';

/// Full read-only view of one workout plan (days → exercises) with coach
/// actions: edit and set-active.
class WorkoutPlanDetailScreen extends StatefulWidget {
  final String planId;

  const WorkoutPlanDetailScreen({super.key, required this.planId});

  @override
  State<WorkoutPlanDetailScreen> createState() =>
      _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutPlanCubit>();
    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after a set-active/edit;
    // a plain implicit pop returns null and would leave the list stale.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'workout_plan_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<WorkoutPlanModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchWorkoutPlanById(widget.planId),
          modelBuilder: (plan) => _Body(
            plan: plan,
            onEdit: () => _edit(cubit, plan),
            onSetActive: () => _setActive(cubit, plan),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(WorkoutPlanCubit cubit, WorkoutPlanModel plan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutPlanBuilderScreen(plan: plan),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _setActive(WorkoutPlanCubit cubit, WorkoutPlanModel plan) async {
    final result = await cubit.setActiveWorkoutPlan(plan.id ?? widget.planId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      _changed = true;
      _getModel?.getModel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('plan_set_active'.tr()),
          backgroundColor: AppDesignSystem.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'something_went_wrong'.tr()),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
    }
  }
}

class _Body extends StatelessWidget {
  final WorkoutPlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onSetActive;

  const _Body({
    required this.plan,
    required this.onEdit,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacingXS.h,
                  children: [
                    AppBadge(
                      text: (plan.isActive ? 'active' : 'inactive').tr(),
                      variant: plan.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      dot: true,
                    ),
                    AppBadge(
                      text: 'plan_days_count'.tr(args: ['${plan.dayCount}']),
                      variant: AppBadgeVariant.info,
                      icon: Icons.event_note_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppDesignSystem.spacingXS.w,
              bottom: AppDesignSystem.spacingXS.h,
            ),
            child: Text(
              'workout_days'.tr(),
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ),
          PlanViewer(plan: plan),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          AppButton(
            text: 'edit_workout_plan'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: onEdit,
          ),
          if (!plan.isActive) ...[
            SizedBox(height: AppDesignSystem.spacingSM.h),
            AppButton(
              text: 'set_active'.tr(),
              icon: Icons.flag_outlined,
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: onSetActive,
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }
}
