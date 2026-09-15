import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_plan_cubit.dart';
import '../data/model/workout_day_model.dart';
import '../data/model/workout_enums.dart';
import '../data/model/workout_plan_model.dart';
import 'widgets/day_editor_card.dart';
import 'widgets/trainee_picker_sheet.dart';

/// Nested workout-plan editor. Holds the whole plan tree in **local form
/// state** (ephemeral — not API state) and, on save, serializes it once into
/// the cubit's [WorkoutPlanCubit.saveParams] and fires a single POST (create) or
/// PUT (edit, full-tree replace) driven by the [CreateModel] boilerplate.
class WorkoutPlanBuilderScreen extends StatefulWidget {
  /// The plan to edit; `null` for a create flow.
  final WorkoutPlanModel? plan;

  /// Seed trainee for a scoped create (ignored when [plan] is provided).
  final String? traineeId;
  final String? traineeName;

  const WorkoutPlanBuilderScreen({
    super.key,
    this.plan,
    this.traineeId,
    this.traineeName,
  });

  bool get isEdit => plan != null;

  @override
  State<WorkoutPlanBuilderScreen> createState() =>
      _WorkoutPlanBuilderScreenState();
}

class _WorkoutPlanBuilderScreenState extends State<WorkoutPlanBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;

  late List<WorkoutDayModel> _days;
  String? _traineeId;
  String? _traineeName;
  bool _isActive = false;
  bool _dirty = false;
  int _localSeq = 0;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _name = TextEditingController(text: plan?.name ?? '');
    _description = TextEditingController(text: plan?.description ?? '');
    _days = plan != null
        ? List<WorkoutDayModel>.from(plan.days)
        : <WorkoutDayModel>[];
    _traineeId = plan?.traineeId ?? widget.traineeId;
    _traineeName = widget.traineeName;
    _isActive = plan?.isActive ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String _newLocalId() => 'local-${_localSeq++}';

  void _markDirty() {
    if (!_dirty) _dirty = true;
  }

  void _addDay() {
    setState(() {
      _markDirty();
      _days = [
        ..._days,
        WorkoutDayModel(
          id: _newLocalId(),
          name: '',
          order: _days.length,
          exercises: const [],
        ),
      ];
    });
  }

  void _onDayChanged(int index, WorkoutDayModel day) {
    setState(() {
      _markDirty();
      _days[index] = day;
    });
  }

  void _removeDay(int index) {
    setState(() {
      _markDirty();
      _days = [..._days]..removeAt(index);
    });
  }

  /// Scheduled weekdays used by every day except [exceptIndex] — the disabled
  /// set for that day's weekday picker (F2/PD9: a weekday is unique per plan;
  /// unscheduled days are unconstrained).
  Set<Weekday> _weekdaysTakenByOthers(int exceptIndex) {
    final taken = <Weekday>{};
    for (var i = 0; i < _days.length; i++) {
      if (i == exceptIndex) continue;
      final wd = _days[i].scheduledDay;
      if (wd != null) taken.add(wd);
    }
    return taken;
  }

  void _reorderDays(int oldIndex, int newIndex) {
    // [ReorderableListView.onReorderItem] already adjusts [newIndex] for the
    // removed item, so no manual `newIndex -= 1` correction is needed here.
    setState(() {
      _markDirty();
      final list = [..._days];
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _days = list;
    });
  }

  Future<void> _pickTrainee() async {
    final picked = await showTraineePickerSheet(context);
    if (picked != null) {
      setState(() {
        _markDirty();
        _traineeId = picked.id;
        _traineeName = picked.fullName;
      });
    }
  }

  /// Sync local state into the cubit params and validate. Returns the first
  /// validation error message, or `null` when the plan is ready to submit.
  String? _syncAndValidate(WorkoutPlanCubit cubit) {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();

    final name = _name.text.trim();
    if (name.isEmpty) return 'field_required'.tr();
    if (name.length > 128) return 'plan_name_max_error'.tr();
    if (_traineeId == null || _traineeId!.isEmpty) {
      return 'trainee_required'.tr();
    }
    for (final day in _days) {
      if (day.name.trim().isEmpty) return 'field_required'.tr();
      if (day.name.trim().length > 64) return 'day_name_max_error'.tr();
    }

    final params = cubit.saveParams;
    params.id = widget.plan?.id ?? '';
    params.traineeId = _traineeId!;
    params.name = name;
    params.description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    params.isActive = _isActive;
    params.days = _days;
    return null;
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('unsaved_changes'.tr()),
        content: Text('unsaved_changes_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('keep_editing'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.errorColor,
            ),
            child: Text('discard'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutPlanCubit>();
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final ok = await _confirmDiscard();
        if (!context.mounted) return;
        if (ok) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: widget.isEdit
              ? 'edit_workout_plan'.tr()
              : 'add_workout_plan'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final ok = await _confirmDiscard();
              if (!context.mounted) return;
              if (ok) Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: EdgeInsets.fromLTRB(
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacingMD.h,
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacing4XL.h,
                  ),
                  header: _PlanHeader(
                    name: _name,
                    description: _description,
                    traineeName: _traineeName,
                    isActive: _isActive,
                    onPickTrainee: _pickTrainee,
                    onActiveChanged: (v) => setState(() {
                      _markDirty();
                      _isActive = v;
                    }),
                    onAddDay: _addDay,
                  ),
                  itemCount: _days.length,
                  onReorderItem: _reorderDays,
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    return DayEditorCard(
                      key: ValueKey(day.id ?? 'day-$index'),
                      day: day,
                      index: index,
                      // Weekdays already scheduled by other days — disabled in
                      // this day's picker so a weekday can't be used twice
                      // (F2/PD9). Unscheduled (null) days impose no constraint.
                      takenWeekdays: _weekdaysTakenByOthers(index),
                      dragHandle: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_indicator,
                          size: AppDesignSystem.iconSizeSM.sp,
                          color: AppDesignSystem.neutral400,
                        ),
                      ),
                      onChanged: (d) => _onDayChanged(index, d),
                      onRemove: () => _removeDay(index),
                    );
                  },
                ),
              ),
            ),
            _SaveBar(
              label: widget.isEdit
                  ? 'save_changes'.tr()
                  : 'create_workout_plan'.tr(),
              successMessage: widget.isEdit
                  ? 'workout_plan_updated'.tr()
                  : 'workout_plan_created'.tr(),
              onValidate: () => _syncAndValidate(cubit),
              onSubmit: () => widget.isEdit
                  ? cubit.updateWorkoutPlan()
                  : cubit.createWorkoutPlan(),
              onSuccess: () {
                _dirty = false;
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController description;
  final String? traineeName;
  final bool isActive;
  final VoidCallback onPickTrainee;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onAddDay;

  const _PlanHeader({
    required this.name,
    required this.description,
    required this.traineeName,
    required this.isActive,
    required this.onPickTrainee,
    required this.onActiveChanged,
    required this.onAddDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('plan-header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'workout_plan_name'.tr(),
          hint: 'workout_plan_name_hint'.tr(),
          controller: name,
          textInputAction: TextInputAction.next,
          validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) return 'field_required'.tr();
            if (t.length > 128) return 'plan_name_max_error'.tr();
            return null;
          },
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        AppTextField(
          label: 'description'.tr(),
          hint: 'plan_description_hint'.tr(),
          controller: description,
          maxLines: 2,
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Text(
          'trainee'.tr(),
          style: AppDesignSystem.labelMedium.copyWith(
            color: AppDesignSystem.neutral700,
            fontWeight: AppDesignSystem.medium,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingXS.h),
        _SelectTile(
          icon: Icons.person_outline,
          label: (traineeName != null && traineeName!.isNotEmpty)
              ? traineeName!
              : 'no_trainee_selected'.tr(),
          filled: traineeName != null && traineeName!.isNotEmpty,
          onTap: onPickTrainee,
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        AppCheckboxField(
          label: 'plan_active'.tr(),
          subtitle: 'plan_active_hint'.tr(),
          value: isActive,
          onChanged: (v) => onActiveChanged(v ?? false),
        ),
        SizedBox(height: AppDesignSystem.spacingLG.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'workout_days'.tr(),
                style: AppDesignSystem.h5.copyWith(
                  color: AppDesignSystem.neutral900,
                ),
              ),
            ),
            AppButton(
              text: 'add_day'.tr(),
              icon: Icons.add,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              onPressed: onAddDay,
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
      ],
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SelectTile({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: filled
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: filled ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: filled
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDesignSystem.iconSizeSM.sp,
              color: filled
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral500,
            ),
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: filled
                      ? AppDesignSystem.neutral900
                      : AppDesignSystem.neutral500,
                  fontWeight: AppDesignSystem.medium,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final String label;
  final String successMessage;
  final String? Function() onValidate;
  final Future<Result> Function() onSubmit;
  final VoidCallback onSuccess;

  const _SaveBar({
    required this.label,
    required this.successMessage,
    required this.onValidate,
    required this.onSubmit,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CreateModel<WorkoutPlanModel>(
          withValidation: true,
          onTap: () async {
            final error = onValidate();
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppDesignSystem.errorColor,
                ),
              );
              return false;
            }
            return true;
          },
          useCaseCallBack: (_) => onSubmit(),
          onSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: AppDesignSystem.successColor,
              ),
            );
            onSuccess();
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: AppDesignSystem.errorColor,
              ),
            );
          },
          child: Container(
            height: 52.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryColor,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Text(
              label,
              style: AppDesignSystem.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
