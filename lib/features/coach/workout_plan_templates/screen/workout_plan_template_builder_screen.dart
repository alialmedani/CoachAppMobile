import 'dart:convert';

import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_day_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/data/model/workout_plan_model.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/widgets/day_editor_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_plan_template_cubit.dart';

/// Nested workout-template editor. Holds the whole template tree in **local form
/// state** (ephemeral — not API state) and, on save, serializes it once into the
/// cubit's [WorkoutPlanTemplateCubit.saveParams] and fires a single POST
/// (create) or PUT (edit, full-tree replace) driven by the [CreateModel]
/// boilerplate.
///
/// Unlike the plan builder, a template has **no trainee and no active flag** —
/// only a name/description and the day/exercise tree (reusing the plan
/// [DayEditorCard]). A [UnsavedChangesGuard] prompts before abandoning a dirty
/// draft; a successful save pops directly with `true` and bypasses the guard.
class WorkoutPlanTemplateBuilderScreen extends StatefulWidget {
  /// The template to edit; `null` for a create flow.
  final WorkoutPlanModel? template;

  const WorkoutPlanTemplateBuilderScreen({super.key, this.template});

  bool get isEdit => template != null;

  @override
  State<WorkoutPlanTemplateBuilderScreen> createState() =>
      _WorkoutPlanTemplateBuilderScreenState();
}

class _WorkoutPlanTemplateBuilderScreenState
    extends State<WorkoutPlanTemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;

  late List<WorkoutDayModel> _days;
  int _localSeq = 0;
  late String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _name = TextEditingController(text: template?.name ?? '');
    _description = TextEditingController(text: template?.description ?? '');
    _days = template != null
        ? List<WorkoutDayModel>.from(template.days)
        : <WorkoutDayModel>[];
    _initialSnapshot = _snapshot();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String _newLocalId() => 'local-${_localSeq++}';

  /// A stable JSON snapshot of the current draft; compared to the one captured
  /// at [initState] to decide whether the discard guard should fire.
  String _snapshot() {
    return jsonEncode({
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'days': [for (var i = 0; i < _days.length; i++) _days[i].toWriteJson(i)],
    });
  }

  bool _isDirty() => _snapshot() != _initialSnapshot;

  void _addDay() {
    setState(() {
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
    setState(() => _days[index] = day);
  }

  void _removeDay(int index) {
    setState(() => _days = [..._days]..removeAt(index));
  }

  void _reorderDays(int oldIndex, int newIndex) {
    // [ReorderableListView.onReorderItem] already adjusts [newIndex] for the
    // removed item, so no manual `newIndex -= 1` correction is needed here.
    setState(() {
      final list = [..._days];
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _days = list;
    });
  }

  /// Sync local state into the cubit params and validate. Returns the first
  /// validation error message, or `null` when the template is ready to submit.
  String? _syncAndValidate(WorkoutPlanTemplateCubit cubit) {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();

    final name = _name.text.trim();
    if (name.isEmpty) return 'field_required'.tr();
    if (name.length > 128) return 'template_name_max_error'.tr();
    for (final day in _days) {
      if (day.name.trim().isEmpty) return 'field_required'.tr();
      if (day.name.trim().length > 64) return 'day_name_max_error'.tr();
    }

    final params = cubit.saveParams;
    params.id = widget.template?.id ?? '';
    params.name = name;
    params.description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    params.days = _days;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutPlanTemplateCubit>();
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: widget.isEdit
              ? 'edit_template'.tr()
              : 'add_template'.tr(),
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
                  header: _TemplateHeader(
                    name: _name,
                    description: _description,
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
                  : 'create_template'.tr(),
              successMessage: widget.isEdit
                  ? 'template_updated'.tr()
                  : 'template_created'.tr(),
              onValidate: () => _syncAndValidate(cubit),
              onSubmit: () => widget.isEdit
                  ? cubit.updateTemplate()
                  : cubit.createTemplate(),
              onSuccess: () {
                // Direct pop bypasses the UnsavedChangesGuard (a saved draft is
                // no longer "unsaved"); `true` tells the list to refresh.
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateHeader extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController description;
  final VoidCallback onAddDay;

  const _TemplateHeader({
    required this.name,
    required this.description,
    required this.onAddDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('template-header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'template_name'.tr(),
          hint: 'template_name_hint'.tr(),
          controller: name,
          textInputAction: TextInputAction.next,
          validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) return 'field_required'.tr();
            if (t.length > 128) return 'template_name_max_error'.tr();
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
