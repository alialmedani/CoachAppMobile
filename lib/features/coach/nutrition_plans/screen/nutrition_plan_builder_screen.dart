import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/widgets/trainee_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/nutrition_plan_cubit.dart';
import '../data/model/meal_model.dart';
import '../data/model/nutrition_plan_model.dart';
import 'widgets/macro_summary_card.dart';
import 'widgets/meal_editor_card.dart';

/// Nested nutrition-plan editor. Holds the whole plan tree in **local form
/// state** (ephemeral — not API state) and, on save, serializes it once into the
/// cubit's [NutritionPlanCubit.saveParams] and fires a single POST (create) or
/// PUT (edit, full-tree replace) driven by the [CreateModel] boilerplate. A live
/// client-side macro estimate is shown while editing; the authoritative totals
/// come back in the saved dto.
class NutritionPlanBuilderScreen extends StatefulWidget {
  /// The plan to edit; `null` for a create flow.
  final NutritionPlanModel? plan;

  /// Seed trainee for a scoped create (ignored when [plan] is provided).
  final String? traineeId;
  final String? traineeName;

  const NutritionPlanBuilderScreen({
    super.key,
    this.plan,
    this.traineeId,
    this.traineeName,
  });

  bool get isEdit => plan != null;

  @override
  State<NutritionPlanBuilderScreen> createState() =>
      _NutritionPlanBuilderScreenState();
}

class _NutritionPlanBuilderScreenState
    extends State<NutritionPlanBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _targetCalories;
  late final TextEditingController _targetProtein;
  late final TextEditingController _targetCarbs;
  late final TextEditingController _targetFat;

  late List<MealModel> _meals;
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
    _targetCalories = TextEditingController(
      text: _fmtTarget(plan?.targetCalories),
    );
    _targetProtein = TextEditingController(
      text: _fmtTarget(plan?.targetProteinG),
    );
    _targetCarbs = TextEditingController(text: _fmtTarget(plan?.targetCarbsG));
    _targetFat = TextEditingController(text: _fmtTarget(plan?.targetFatG));
    _meals = plan != null ? List<MealModel>.from(plan.meals) : <MealModel>[];
    _traineeId = plan?.traineeId ?? widget.traineeId;
    _traineeName = widget.traineeName;
    _isActive = plan?.isActive ?? false;
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

  void _markDirty() {
    if (!_dirty) _dirty = true;
  }

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
      _markDirty();
      _meals = [
        ..._meals,
        MealModel(id: _newLocalId(), name: '', order: _meals.length),
      ];
    });
  }

  void _onMealChanged(int index, MealModel meal) {
    setState(() {
      _markDirty();
      _meals[index] = meal;
    });
  }

  void _removeMeal(int index) {
    setState(() {
      _markDirty();
      _meals = [..._meals]..removeAt(index);
    });
  }

  void _reorderMeals(int oldIndex, int newIndex) {
    setState(() {
      _markDirty();
      final list = [..._meals];
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _meals = list;
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
  String? _syncAndValidate(NutritionPlanCubit cubit) {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.validate();

    final name = _name.text.trim();
    if (name.isEmpty) return 'field_required'.tr();
    if (name.length > 128) return 'plan_name_max_error'.tr();
    if (_traineeId == null || _traineeId!.isEmpty) {
      return 'trainee_required'.tr();
    }
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
    params.id = widget.plan?.id ?? '';
    params.traineeId = _traineeId!;
    params.name = name;
    params.description = _description.text.trim().isEmpty
        ? null
        : _description.text.trim();
    params.isActive = _isActive;
    params.targetCalories = _parseTarget(_targetCalories);
    params.targetProteinG = _parseTarget(_targetProtein);
    params.targetCarbsG = _parseTarget(_targetCarbs);
    params.targetFatG = _parseTarget(_targetFat);
    params.meals = _meals;
    return null;
  }

  /// F11: warn (don't block) before deactivating the trainee's active plan,
  /// which would leave them with no active nutrition program.
  Future<bool> _confirmBeforeSave() async {
    if (widget.isEdit && (widget.plan?.isActive ?? false) && !_isActive) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('deactivate_active_plan_title'.tr()),
          content: Text('deactivate_active_plan_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('continue_anyway'.tr()),
            ),
          ],
        ),
      );
      return proceed ?? false;
    }
    return true;
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
    final cubit = context.read<NutritionPlanCubit>();
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
              ? 'edit_nutrition_plan'.tr()
              : 'add_nutrition_plan'.tr(),
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
                    onPickTrainee: _pickTrainee,
                    onActiveChanged: (v) => setState(() {
                      _markDirty();
                      _isActive = v;
                    }),
                    onTargetsChanged: () => setState(_markDirty),
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
                  : 'create_nutrition_plan'.tr(),
              successMessage: widget.isEdit
                  ? 'nutrition_plan_updated'.tr()
                  : 'nutrition_plan_created'.tr(),
              onValidate: () => _syncAndValidate(cubit),
              onConfirm: _confirmBeforeSave,
              onSubmit: () => widget.isEdit
                  ? cubit.updateNutritionPlan()
                  : cubit.createNutritionPlan(),
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
  final VoidCallback onPickTrainee;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onTargetsChanged;
  final VoidCallback onAddMeal;

  const _PlanHeader({
    required this.name,
    required this.description,
    required this.traineeName,
    required this.isActive,
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
    required this.onPickTrainee,
    required this.onActiveChanged,
    required this.onTargetsChanged,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('plan-header'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'nutrition_plan_name'.tr(),
          hint: 'nutrition_plan_name_hint'.tr(),
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

  /// Async confirmation after validation passes and before submit (F11 warning).
  /// Returns false to abort the save.
  final Future<bool> Function() onConfirm;
  final Future<Result> Function() onSubmit;
  final VoidCallback onSuccess;

  const _SaveBar({
    required this.label,
    required this.successMessage,
    required this.onValidate,
    required this.onConfirm,
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
            return await onConfirm();
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
