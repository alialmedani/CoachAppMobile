import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/exercise_cubit.dart';
import '../data/model/exercise_model.dart';
import 'widgets/exercise_form.dart';

/// Create a new exercise, or edit an existing one when [exercise] is provided.
class SaveExerciseScreen extends StatefulWidget {
  final ExerciseModel? exercise;

  const SaveExerciseScreen({super.key, this.exercise});

  bool get isEdit => exercise != null;

  @override
  State<SaveExerciseScreen> createState() => _SaveExerciseScreenState();
}

class _SaveExerciseScreenState extends State<SaveExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseCubit>();
    if (widget.isEdit) {
      cubit.prepareEdit(widget.exercise!);
    } else {
      cubit.prepareCreate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: widget.isEdit ? 'edit_exercise'.tr() : 'add_exercise'.tr(),
        subtitle: widget.isEdit
            ? (widget.exercise!.name ?? '')
            : 'add_exercise_subtitle'.tr(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(vertical: AppDesignSystem.spacingMD.h),
              child: Form(
                key: _formKey,
                child: ExerciseForm(params: cubit.saveParams),
              ),
            ),
          ),
          _SaveBar(
            formKey: _formKey,
            label: widget.isEdit ? 'save_changes'.tr() : 'create_exercise'.tr(),
            onSubmit: () =>
                widget.isEdit ? cubit.updateExercise() : cubit.createExercise(),
            successMessage:
                widget.isEdit ? 'exercise_updated'.tr() : 'exercise_created'.tr(),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String label;
  final Future<Result> Function() onSubmit;
  final String successMessage;

  const _SaveBar({
    required this.formKey,
    required this.label,
    required this.onSubmit,
    required this.successMessage,
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
        child: CreateModel<ExerciseModel>(
          withValidation: true,
          onTap: () async {
            FocusScope.of(context).unfocus();
            return formKey.currentState?.validate() ?? false;
          },
          useCaseCallBack: (_) => onSubmit(),
          onSuccess: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: AppDesignSystem.successColor,
              ),
            );
            Navigator.pop(context, true);
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
