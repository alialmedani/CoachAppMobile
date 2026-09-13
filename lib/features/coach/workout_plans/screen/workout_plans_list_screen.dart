import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_plan_cubit.dart';
import '../data/model/workout_plan_model.dart';
import 'widgets/delete_plan_dialog.dart';
import 'widgets/workout_plan_card.dart';
import 'workout_plan_builder_screen.dart';
import 'workout_plan_detail_screen.dart';

/// Coach workout-plan list. Optionally scoped to one trainee via [traineeId]
/// (new plans then inherit that trainee); when unscoped it lists plans across
/// the coach's trainees and the builder asks the coach to pick a trainee.
class WorkoutPlansListScreen extends StatefulWidget {
  final String? traineeId;
  final String? traineeName;

  /// Drops the top bar so the screen can sit inside the Plans tab's segmented
  /// host (which owns the title); standalone/scoped use keeps it.
  final bool embedded;

  const WorkoutPlansListScreen({
    super.key,
    this.traineeId,
    this.traineeName,
    this.embedded = false,
  });

  @override
  State<WorkoutPlansListScreen> createState() => _WorkoutPlansListScreenState();
}

class _WorkoutPlansListScreenState extends State<WorkoutPlansListScreen> {
  final TextEditingController _searchController = TextEditingController();
  PaginationCubit? _pagination;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutPlanCubit>().setScopeTrainee(widget.traineeId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => _pagination?.getList();

  Future<void> _openCreate(WorkoutPlanCubit cubit) async {
    cubit.prepareCreate(traineeId: widget.traineeId);
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutPlanBuilderScreen(
            traineeId: widget.traineeId,
            traineeName: widget.traineeName,
          ),
        ),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(
    WorkoutPlanCubit cubit,
    WorkoutPlanModel plan,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutPlanDetailScreen(planId: plan.id ?? ''),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _handleAction(
    WorkoutPlanCubit cubit,
    WorkoutPlanModel plan,
    WorkoutPlanCardAction action,
  ) async {
    switch (action) {
      case WorkoutPlanCardAction.setActive:
        await _setActive(cubit, plan);
        break;
      case WorkoutPlanCardAction.edit:
        await _openEdit(cubit, plan);
        break;
      case WorkoutPlanCardAction.delete:
        await _confirmDelete(cubit, plan);
        break;
    }
  }

  Future<void> _setActive(
    WorkoutPlanCubit cubit,
    WorkoutPlanModel plan,
  ) async {
    final result = await cubit.setActiveWorkoutPlan(plan.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      _refresh();
      _snack('plan_set_active'.tr(), AppDesignSystem.successColor);
    } else {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
    }
  }

  /// The list carries only summaries (no days), so a safe edit must first load
  /// the full plan tree before opening the builder — otherwise a PUT would
  /// replace the plan with an empty day list.
  Future<void> _openEdit(WorkoutPlanCubit cubit, WorkoutPlanModel plan) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CupertinoActivityIndicator()),
    );
    final result = await cubit.fetchWorkoutPlanById(plan.id ?? '');
    if (!mounted) return;
    Navigator.pop(context); // dismiss loading
    if (!result.hasDataOnly) {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
      return;
    }
    final full = result.data as WorkoutPlanModel;
    if (!mounted) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: WorkoutPlanBuilderScreen(plan: full),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _confirmDelete(
    WorkoutPlanCubit cubit,
    WorkoutPlanModel plan,
  ) async {
    final ok = await confirmDeletePlan(context, plan.name ?? '');
    if (!ok) return;
    final result = await cubit.deleteWorkoutPlan(plan.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      _refresh();
      _snack('workout_plan_deleted'.tr(), AppDesignSystem.successColor);
    } else {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutPlanCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: widget.embedded
          ? null
          : AppTopBar(
              title: 'workout_plans'.tr(),
              subtitle: widget.traineeName,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('add_workout_plan'.tr()),
      ),
      body: Column(
        children: [
          BlocBuilder<WorkoutPlanCubit, WorkoutPlanState>(
            builder: (context, state) => Container(
              color: AppDesignSystem.surfaceWhite,
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
              ),
              child: Column(
                children: [
                  AppTextField(
                    hint: 'search_workout_plans'.tr(),
                    controller: _searchController,
                    onChanged: (v) {
                      cubit.setSearchTerm(v);
                      _refresh();
                    },
                    prefixIcon: Icon(
                      Icons.search,
                      size: AppDesignSystem.iconSizeSM.sp,
                      color: AppDesignSystem.neutral400,
                    ),
                    suffixIcon: cubit.searchTerm.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: AppDesignSystem.iconSizeSM.sp,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              cubit.setSearchTerm('');
                              _refresh();
                            },
                          )
                        : null,
                  ),
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _StatusChip(
                            label: 'all'.tr(),
                            selected: cubit.filterActive == null,
                            onTap: () {
                              cubit.setFilterActive(null);
                              _refresh();
                            },
                          ),
                          _StatusChip(
                            label: 'active'.tr(),
                            selected: cubit.filterActive == true,
                            onTap: () {
                              cubit.setFilterActive(true);
                              _refresh();
                            },
                          ),
                          _StatusChip(
                            label: 'inactive'.tr(),
                            selected: cubit.filterActive == false,
                            onTap: () {
                              cubit.setFilterActive(false);
                              _refresh();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PaginationList<WorkoutPlanModel>(
              withPagination: true,
              onCubitCreated: (c) => _pagination = c,
              repositoryCallBack: (data) => cubit.fetchWorkoutPlanList(data),
              noDataWidget: AppEmptyState(
                icon: Icons.assignment_outlined,
                title: 'no_workout_plans'.tr(),
                subtitle: 'no_workout_plans_subtitle'.tr(),
                iconColor: AppDesignSystem.primaryColor,
              ),
              listBuilder: (list) => ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingSM.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) => WorkoutPlanCard(
                  plan: list[index],
                  onTap: () => _openDetail(cubit, list[index]),
                  onAction: (action) =>
                      _handleAction(cubit, list[index], action),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: AppDesignSystem.spacingXS.w),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: AppDesignSystem.labelMedium.copyWith(
          color: selected ? Colors.white : AppDesignSystem.neutral600,
        ),
        selectedColor: AppDesignSystem.primaryColor,
        backgroundColor: AppDesignSystem.neutral100,
        side: BorderSide.none,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
