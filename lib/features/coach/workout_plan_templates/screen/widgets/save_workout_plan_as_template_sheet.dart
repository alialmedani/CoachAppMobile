import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/dialogs/dialogs.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../cubit/workout_plan_template_cubit.dart';

/// Snapshots an existing trainee workout plan into a new reusable template.
///
/// Opens a bottom sheet with a required name (prefilled from the source plan)
/// and an optional description, then calls
/// [WorkoutPlanTemplateCubit.saveAsTemplate] (a one-shot `Future<Result>`, no
/// cubit `emit`). On success it pops and toasts; on failure it toasts and stays
/// open. Returns `true` when a template was created.
Future<bool?> showSaveWorkoutPlanAsTemplateSheet(
  BuildContext context, {
  required String planId,
  required String planName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<WorkoutPlanTemplateCubit>(),
      child: _SaveWorkoutPlanAsTemplateSheet(
        planId: planId,
        planName: planName,
      ),
    ),
  );
}

class _SaveWorkoutPlanAsTemplateSheet extends StatefulWidget {
  final String planId;
  final String planName;

  const _SaveWorkoutPlanAsTemplateSheet({
    required this.planId,
    required this.planName,
  });

  @override
  State<_SaveWorkoutPlanAsTemplateSheet> createState() =>
      _SaveWorkoutPlanAsTemplateSheetState();
}

class _SaveWorkoutPlanAsTemplateSheetState
    extends State<_SaveWorkoutPlanAsTemplateSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.planName);
    _description = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final desc = _description.text.trim();
    final result = await context.read<WorkoutPlanTemplateCubit>().saveAsTemplate(
      widget.planId,
      _name.text.trim(),
      desc.isEmpty ? null : desc,
    );
    if (!mounted) return;

    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      Dialogs.showSuccess('saved_as_template'.tr());
    } else {
      setState(() => _saving = false);
      Dialogs.showError(result.error ?? 'something_went_wrong'.tr());
    }
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'field_required'.tr();
    if (value.length > 128) return 'template_name_max_error'.tr();
    return null;
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
                      'save_as_template'.tr(),
                      style: AppDesignSystem.h5.copyWith(
                        color: AppDesignSystem.neutral900,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'template_name'.tr(),
                      hint: 'template_name_hint'.tr(),
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      validator: _validateName,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'template_description'.tr(),
                      controller: _description,
                      maxLines: 3,
                      minLines: 2,
                      textInputAction: TextInputAction.newline,
                    ),
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'cancel'.tr(),
                            variant: AppButtonVariant.outline,
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        Expanded(
                          child: AppButton(
                            text: 'save_as_template'.tr(),
                            isLoading: _saving,
                            onPressed: _saving ? null : _save,
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
}
