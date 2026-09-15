import 'dart:convert';

import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/meal_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/data/model/nutrition_plan_model.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/macro_summary_card.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/widgets/meal_editor_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_plan_template_cubit.dart';

/// Nested nutrition-template editor. Holds the whole template tree in **local
/// form state** (ephemeral — not API state) and, on save, serializes it once
/// into the cubit's [NutritionPlanTemplateCubit.saveParams] and fires a single
/// POST (create) or PUT (edit, full-tree replace) driven by the [CreateModel]
/// boilerplate. A live client-side macro estimate is shown while editing; the
/// authoritative totals come back in the saved dto.
///
/// Unlike the plan builder, a template has **no trainee and no active flag** —
/// only a name/description, optional daily targets and the meal/item tree
/// (reusing the plan [MealEditorCard]). A [UnsavedChangesGuard] prompts before
/// abandoning a dirty draft; a successful save pops directly with `true` and
/// bypasses the guard.
class NutritionPlanTemplateBuilderScreen extends StatefulWidget {
  /// The template to edit; `null` for a create flow.
  final NutritionPlanModel? template;

  const NutritionPlanTemplateBuilderScreen({super.key, this.template});

  bool get isEdit => template != null;

  @override
  State<NutritionPlanTemplateBuilderScreen> createState() =>
      _NutritionPlanTemplateBuilderScreenState();
}

class _NutritionPlanTemplateBuilderScreenState
    extends State<NutritionPlanTemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _targetCalories;
  late final TextEditingController _targetProtein;
  late final TextEditingController _targetCarbs;
  late final TextEditingController _targetFat;

  late List<MealModel> _meals;
  int _localSeq = 0;
  late String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _name = TextEditingController(text: template?.name ?? '');
    _description = TextEditingController(text: template?.description ?? '');
    _targetCalories = TextEditingController(
      text: _fmtTarget(template?.targetCalories),
    );
    _targetProtein = TextEditingController(
      text: _fmtTarget(template?.targetProteinG),
    );
    _targetCarbs = TextEditingController(
      text: _fmtTarget(template?.targetCarbsG),
    );
    _targetFat = TextEditingController(text: _fmtTarget(template?.targetFatG));
    _meals = template != null
        ? List<MealModel>.from(template.meals)
        : <MealModel>[];
    _initialSnapshot = _snapshot();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _targetCalories.dispose();
    _targetProtein.dispose();
    _targetCarbs.dispose();
    _targetFat.dispose();
    super.dispose();
  }

  static String _fmtTarget(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  String _newLocalId() => 'local-${_localSeq++}';

  /// A stable JSON snapshot of the current draft; compared to the one captured
  /// at [initState] to decide whether the discard guard should fire.
  String _snapshot() {
    return jsonEncode({
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'targetCalories': _targetCalories.text.trim(),
      'targetProtein': _targetProtein.text.trim(),
      'targetCarbs': _targetCarbs.text.trim(),
      'targetFat': _targetFat.text.trim(),
      'meals': [for (var i = 0; i < _meals.length; i++) _meals[i].toWriteJson(i)],
    });
  }

  bool _isDirty() => _snapshot() != _initialSnapshot;

  // ---- live client-side estimate --------------------------------------------
  double get _estCalories =>
      _meals.fold(0.0, (sum, m) => sum + m.totalCalories);
  double get _estProtein => _meals.fold(0.0, (sum, m) => sum + m.totalProteinG);
  double get _estCarbs => _meals.fold(0.0, (sum, m) => sum + m.totalCarbsG);
  double get _estFat => _meals.fold(0.0, (sum, m) => sum + m.totalFatG);

  double? _parseTarget(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    final n = double.tryParse(t);
    if (n == null || n < 0 || n > 100000) return null;
    return n;
  }

  void _addMeal() {
    setState(() {
      _meals = [
        ..._meals,
        MealModel(id: _newLocalId(), name: '', order: _meals.length),
      ];
    });
  }

  void _onMealChanged(int index, MealModel meal) {
    setState(() => _meals[index] = meal);
  }

  void _removeMeal(int index) {
    setState(() => _meals = [..._meals]..removeAt(index));
  }

  void _reorderMeals(int oldIndex, int newIndex) {
    // [ReorderableListView.onReorderItem] already adjusts [newIndex] for the
    // removed item, so no manual `newIndex -= 1` correction is needed here.
    setState(() {
      final list = [..._meals];
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _meals = list;
    });
  }

  /// Sync local state into the cubit params and validate. Returns the first
  /// validation error message, or `null` when the template is ready to submit.
  String? _syncAndValidate(NutritionPlanTemplateCubit cubit) {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();

    final name = _name.text.trim();
    if (name.isEmpty) return 'field_required'.tr();
    if (name.length > 128) return 'template_name_max_error'.tr();
    for (final meal in _meals) {
      if (meal.name.trim().isEmpty) return 'field_required'.tr();
      if (meal.name.trim().length > 64) return 'meal_name_max_error'.tr();
    }
    // Targets are optional; validate range only when present.
    for (final c in [
      _targetCalories,
      _targetProtein,
      _targetCarbs,
      _targetFat,
    ]) {
      final raw = c.text.trim();
      if (raw.isEmpty) continue;
      final n = double.tryParse(raw);
      if (n == null || n < 0 || n > 100000) return 'target_range_error'.tr();
    }

    final params = cubit.saveParams;
    params.id = widget.template?.id ?? '';
    params.name = name;
    params.description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    params.targetCalories = _parseTarget(_targetCalories);
    params.targetProteinG = _parseTarget(_targetProtein);
    params.targetCarbsG = _parseTarget(_targetCarbs);
    params.targetFatG = _parseTarget(_targetFat);
    params.meals = _meals;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NutritionPlanTemplateCubit>();
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
                    targetCalories: _targetCalories,
                    targetProtein: _targetProtein,
                    targetCarbs: _targetCarbs,
                    targetFat: _targetFat,
                    estCalories: _estCalories,
                    estProtein: _estProtein,
                    estCarbs: _estCarbs,
                    estFat: _estFat,
                    parsedTargetCalories: _parseTarget(_targetCalories),
                    parsedTargetProtein: _parseTarget(_targetProtein),
                    parsedTargetCarbs: _parseTarget(_targetCarbs),
                    parsedTargetFat: _parseTarget(_targetFat),
                    onTargetsChanged: () => setState(() {}),
                    onAddMeal: _addMeal,
                  ),
                  itemCount: _meals.length,
                  onReorderItem: _reorderMeals,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return MealEditorCard(
                      key: ValueKey(meal.id ?? 'meal-$index'),
                      meal: meal,
                      index: index,
                      dragHandle: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_indicator,
                          size: AppDesignSystem.iconSizeSM.sp,
                          color: AppDesignSystem.neutral400,
                        ),
                      ),
                      onChanged: (m) => _onMealChanged(index, m),
                      onRemove: () => _removeMeal(index),
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
  final TextEditingController targetCalories;
  final TextEditingController targetProtein;
  final TextEditingController targetCarbs;
  final TextEditingController targetFat;
  final double estCalories;
  final double estProtein;
  final double estCarbs;
  final double estFat;
  final double? parsedTargetCalories;
  final double? parsedTargetProtein;
  final double? parsedTargetCarbs;
  final double? parsedTargetFat;
  final VoidCallback onTargetsChanged;
  final VoidCallback onAddMeal;

  const _TemplateHeader({
    required this.name,
    required this.description,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.estCalories,
    required this.estProtein,
    required this.estCarbs,
    required this.estFat,
    required this.parsedTargetCalories,
    required this.parsedTargetProtein,
    required this.parsedTargetCarbs,
    required this.parsedTargetFat,
    required this.onTargetsChanged,
    required this.onAddMeal,
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
        Text(
          'daily_targets'.tr(),
          style: AppDesignSystem.h5.copyWith(color: AppDesignSystem.neutral900),
        ),
        SizedBox(height: AppDesignSystem.spacing2XS.h),
        Text(
          'daily_targets_hint'.tr(),
          style: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.neutral500,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TargetField(
                label: 'target_calories'.tr(),
                controller: targetCalories,
                onChanged: onTargetsChanged,
              ),
            ),
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Expanded(
              child: _TargetField(
                label: 'target_protein'.tr(),
                controller: targetProtein,
                onChanged: onTargetsChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TargetField(
                label: 'target_carbs'.tr(),
                controller: targetCarbs,
                onChanged: onTargetsChanged,
              ),
            ),
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Expanded(
              child: _TargetField(
                label: 'target_fat'.tr(),
                controller: targetFat,
                onChanged: onTargetsChanged,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingLG.h),
        MacroSummaryCard(
          isEstimate: true,
          calories: estCalories,
          proteinG: estProtein,
          carbsG: estCarbs,
          fatG: estFat,
          targetCalories: parsedTargetCalories,
          targetProteinG: parsedTargetProtein,
          targetCarbsG: parsedTargetCarbs,
          targetFatG: parsedTargetFat,
        ),
        SizedBox(height: AppDesignSystem.spacingLG.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'meals'.tr(),
                style: AppDesignSystem.h5.copyWith(
                  color: AppDesignSystem.neutral900,
                ),
              ),
            ),
            AppButton(
              text: 'add_meal'.tr(),
              icon: Icons.add,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              onPressed: onAddMeal,
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingMD.h),
      ],
    );
  }
}

class _TargetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final TextInputAction textInputAction;

  const _TargetField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: 'optional'.tr(),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => onChanged(),
      validator: (v) {
        final raw = (v ?? '').trim();
        if (raw.isEmpty) return null;
        final n = double.tryParse(raw);
        if (n == null || n < 0 || n > 100000) return 'target_range_error'.tr();
        return null;
      },
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
        child: CreateModel<NutritionPlanModel>(
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
