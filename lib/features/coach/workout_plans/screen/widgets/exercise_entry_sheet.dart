import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/workout_exercise_model.dart';
import 'exercise_picker_sheet.dart';

/// Opens a bottom sheet to add or edit a single [WorkoutExerciseModel] entry.
/// Pass [initial] to edit; returns the built entry, or `null` if dismissed.
Future<WorkoutExerciseModel?> showExerciseEntrySheet(
  BuildContext context, {
  WorkoutExerciseModel? initial,
}) {
  return showModalBottomSheet<WorkoutExerciseModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => _ExerciseEntrySheet(initial: initial),
  );
}

class _ExerciseEntrySheet extends StatefulWidget {
  final WorkoutExerciseModel? initial;

  const _ExerciseEntrySheet({this.initial});

  @override
  State<_ExerciseEntrySheet> createState() => _ExerciseEntrySheetState();
}

class _ExerciseEntrySheetState extends State<_ExerciseEntrySheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _sets;
  late final TextEditingController _reps;
  late final TextEditingController _weight;
  late final TextEditingController _rest;
  late final TextEditingController _notes;

  String? _exerciseId;
  String? _exerciseName;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _exerciseId = e?.exerciseId;
    _exerciseName = e?.exerciseName;
    _sets = TextEditingController(text: (e?.sets ?? 1).toString());
    _reps = TextEditingController(text: e?.reps ?? '');
    _weight = TextEditingController(
      text: e?.weightKg != null ? _trimNum(e!.weightKg!) : '',
    );
    _rest = TextEditingController(text: e?.restSeconds?.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    _rest.dispose();
    _notes.dispose();
    super.dispose();
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _pickExercise() async {
    final picked = await showExercisePickerSheet(context);
    if (picked != null) {
      setState(() {
        _exerciseId = picked.id;
        _exerciseName = picked.name;
      });
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final validForm = _formKey.currentState?.validate() ?? false;
    if (_exerciseId == null || _exerciseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pick_exercise_first'.tr()),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
      return;
    }
    if (!validForm) return;

    final entry = WorkoutExerciseModel(
      id: widget.initial?.id,
      exerciseId: _exerciseId,
      exerciseName: _exerciseName,
      order: widget.initial?.order ?? 0,
      sets: int.tryParse(_sets.text.trim()) ?? 1,
      reps: _reps.text.trim().isEmpty ? null : _reps.text.trim(),
      weightKg: _weight.text.trim().isEmpty
          ? null
          : double.tryParse(_weight.text.trim()),
      restSeconds: _rest.text.trim().isEmpty
          ? null
          : int.tryParse(_rest.text.trim()),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral300,
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusFull.r,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'exercise_entry'.tr(),
                      style: AppDesignSystem.h5.copyWith(
                        color: AppDesignSystem.neutral900,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    _ExerciseSelectTile(
                      name: _exerciseName,
                      onTap: _pickExercise,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'sets'.tr(),
                            controller: _sets,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateSets,
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        Expanded(
                          child: AppTextField(
                            label: 'reps'.tr(),
                            hint: 'reps_hint'.tr(),
                            controller: _reps,
                            textInputAction: TextInputAction.next,
                            validator: _validateReps,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'weight_kg'.tr(),
                            controller: _weight,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validateWeight,
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        Expanded(
                          child: AppTextField(
                            label: 'rest_seconds'.tr(),
                            controller: _rest,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateRest,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'exercise_notes'.tr(),
                      hint: 'exercise_notes_hint'.tr(),
                      controller: _notes,
                      maxLines: 2,
                      validator: _validateNotes,
                    ),
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'cancel'.tr(),
                            variant: AppButtonVariant.outline,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        Expanded(
                          child: AppButton(
                            text: 'save_exercise_entry'.tr(),
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDesignSystem.spacingSM.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateSets(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 100) return 'sets_range_error'.tr();
    return null;
  }

  String? _validateReps(String? v) {
    if ((v ?? '').trim().length > 32) return 'reps_max_error'.tr();
    return null;
  }

  String? _validateWeight(String? v) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return null;
    final n = double.tryParse(raw);
    if (n == null || n < 0 || n > 1000) return 'weight_range_error'.tr();
    return null;
  }

  String? _validateRest(String? v) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return null;
    final n = int.tryParse(raw);
    if (n == null || n < 0 || n > 3600) return 'rest_range_error'.tr();
    return null;
  }

  String? _validateNotes(String? v) {
    if ((v ?? '').trim().length > 512) return 'notes_max_error'.tr();
    return null;
  }
}

class _ExerciseSelectTile extends StatelessWidget {
  final String? name;
  final VoidCallback onTap;

  const _ExerciseSelectTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasExercise = name != null && name!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasExercise
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: hasExercise ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: hasExercise
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Icon(
              Icons.fitness_center,
              size: AppDesignSystem.iconSizeSM.sp,
              color: hasExercise
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral500,
            ),
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Expanded(
              child: Text(
                hasExercise ? name! : 'select_exercise'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: hasExercise
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
