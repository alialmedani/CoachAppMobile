import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/muscle_atlas/muscle_atlas.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/exercise_enums.dart';
import '../../data/usecase/create_exercise_usecase.dart';

/// Shared exercise create/edit form, editing [params] in place.
class ExerciseForm extends StatefulWidget {
  final SaveExerciseParams params;

  const ExerciseForm({super.key, required this.params});

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _instructions;
  late final TextEditingController _instructionsAr;
  late final TextEditingController _videoUrl;
  late final TextEditingController _imageUrl;

  SaveExerciseParams get p => widget.params;

  bool get _hasArOriginal =>
      (p.instructionsArOriginal ?? '').trim().isNotEmpty;

  bool get _hasAr => (p.instructionsAr ?? '').trim().isNotEmpty;

  /// Mirrors [ExerciseModel.isArAutoTranslated] against the live draft: the
  /// Arabic text still equals the untouched machine-translation snapshot.
  bool get _isArAutoTranslated =>
      _hasAr &&
      _hasArOriginal &&
      p.instructionsAr!.trim() == p.instructionsArOriginal!.trim();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: p.name);
    _description = TextEditingController(text: p.description ?? '');
    _instructions = TextEditingController(text: p.instructions ?? '');
    _instructionsAr = TextEditingController(text: p.instructionsAr ?? '');
    _videoUrl = TextEditingController(text: p.videoUrl ?? '');
    _imageUrl = TextEditingController(text: p.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _instructions.dispose();
    _instructionsAr.dispose();
    _videoUrl.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  void _restoreOriginalTranslation() {
    final original = p.instructionsArOriginal;
    if (original == null || original.trim().isEmpty) return;
    setState(() {
      p.instructionsAr = original;
      _instructionsAr.text = original;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('original_translation_restored'.tr()),
        backgroundColor: AppDesignSystem.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: 'basic_information'.tr(),
          children: [
            AppTextField(
              label: 'exercise_name'.tr(),
              hint: 'exercise_name_hint'.tr(),
              controller: _name,
              textInputAction: TextInputAction.next,
              onChanged: (v) => p.name = v,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr() : null,
            ),
            AppDropdownField<int>(
              label: 'target_muscle'.tr(),
              value: p.targetMuscle,
              items: [
                for (final m in MuscleGroup.values)
                  DropdownMenuItem(value: m.value, child: Text(m.labelKey.tr())),
              ],
              onChanged: (v) =>
                  setState(() => p.targetMuscle = v ?? MuscleGroup.other.value),
            ),
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Text(
              'tap_to_select_muscle'.tr(),
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXS.h),
            // Visual picker kept in sync with the dropdown above: tapping a
            // muscle sets [targetMuscle] and re-highlights.
            MuscleAtlas(
              selected: MuscleGroup.fromValue(p.targetMuscle),
              onSelected: (g) => setState(() => p.targetMuscle = g.value),
            ),
            AppDropdownField<int>(
              label: 'equipment'.tr(),
              value: p.equipment,
              items: [
                for (final e in Equipment.values)
                  DropdownMenuItem(value: e.value, child: Text(e.labelKey.tr())),
              ],
              onChanged: (v) =>
                  setState(() => p.equipment = v ?? Equipment.none.value),
            ),
          ],
        ),
        AppFormSection(
          title: 'details'.tr(),
          children: [
            AppTextField(
              label: 'description'.tr(),
              hint: 'exercise_description_hint'.tr(),
              controller: _description,
              maxLines: 3,
              onChanged: (v) => p.description = v.trim().isEmpty ? null : v,
            ),
            AppTextField(
              label: 'instructions'.tr(),
              hint: 'exercise_instructions_hint'.tr(),
              controller: _instructions,
              maxLines: 4,
              onChanged: (v) => p.instructions = v.trim().isEmpty ? null : v,
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),
            AppTextField(
              label: 'instructions_ar'.tr(),
              hint: 'instructions_ar_hint'.tr(),
              controller: _instructionsAr,
              maxLines: 4,
              // setState keeps the auto-translated/reviewed chip in sync as the
              // coach edits the Arabic text.
              onChanged: (v) =>
                  setState(() => p.instructionsAr = v.trim().isEmpty ? null : v),
            ),
            if (_hasAr || _hasArOriginal) ...[
              SizedBox(height: AppDesignSystem.spacingSM.h),
              Row(
                children: [
                  if (_hasAr)
                    AppBadge(
                      text: _isArAutoTranslated
                          ? 'ar_auto_translated'.tr()
                          : 'ar_reviewed'.tr(),
                      size: AppBadgeSize.small,
                      icon: _isArAutoTranslated
                          ? Icons.translate
                          : Icons.verified,
                      variant: _isArAutoTranslated
                          ? AppBadgeVariant.warning
                          : AppBadgeVariant.success,
                    ),
                  const Spacer(),
                  if (_hasArOriginal)
                    AppButton(
                      text: 'restore_original_translation'.tr(),
                      icon: Icons.restore,
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.small,
                      onPressed: _restoreOriginalTranslation,
                    ),
                ],
              ),
            ],
          ],
        ),
        AppFormSection(
          title: 'media_optional'.tr(),
          showDivider: false,
          children: [
            AppTextField(
              label: 'video_url'.tr(),
              hint: 'https://...',
              controller: _videoUrl,
              keyboardType: TextInputType.url,
              prefixIcon: Icon(
                Icons.play_circle_outline,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.neutral500,
              ),
              onChanged: (v) => p.videoUrl = v.trim().isEmpty ? null : v.trim(),
            ),
            AppTextField(
              label: 'image_url'.tr(),
              hint: 'https://...',
              controller: _imageUrl,
              keyboardType: TextInputType.url,
              prefixIcon: Icon(
                Icons.image_outlined,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.neutral500,
              ),
              onChanged: (v) => p.imageUrl = v.trim().isEmpty ? null : v.trim(),
            ),
            AppCheckboxField(
              label: 'active_exercise'.tr(),
              subtitle: 'active_exercise_hint'.tr(),
              value: p.isActive,
              onChanged: (v) => setState(() => p.isActive = v ?? true),
            ),
          ],
        ),
      ],
    );
  }
}
