import 'dart:convert';

import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/food_cubit.dart';
import '../data/model/food_model.dart';
import 'widgets/food_form.dart';

/// Create a new food, or edit an existing one when [food] is provided.
class SaveFoodScreen extends StatefulWidget {
  final FoodModel? food;

  const SaveFoodScreen({super.key, this.food});

  bool get isEdit => food != null;

  @override
  State<SaveFoodScreen> createState() => _SaveFoodScreenState();
}

class _SaveFoodScreenState extends State<SaveFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Snapshot of the draft taken once the params are populated; the guard
  /// compares against it to know whether the user has unsaved edits.
  late final String _initialJson;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<FoodCubit>();
    if (widget.isEdit) {
      cubit.prepareEdit(widget.food!);
    } else {
      cubit.prepareCreate();
    }
    _initialJson = jsonEncode(cubit.saveParams.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FoodCubit>();
    return UnsavedChangesGuard(
      isDirty: () => jsonEncode(cubit.saveParams.toJson()) != _initialJson,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: widget.isEdit ? 'edit_food'.tr() : 'add_food'.tr(),
          subtitle: widget.isEdit
              ? (widget.food!.name ?? '')
              : 'add_food_subtitle'.tr(),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: AppDesignSystem.spacingMD.h,
                ),
                child: Form(
                  key: _formKey,
                  child: FoodForm(params: cubit.saveParams),
                ),
              ),
            ),
            _SaveBar(
              formKey: _formKey,
              label: widget.isEdit ? 'save_changes'.tr() : 'create_food'.tr(),
              onSubmit: () =>
                  widget.isEdit ? cubit.updateFood() : cubit.createFood(),
              successMessage: widget.isEdit
                  ? 'food_updated'.tr()
                  : 'food_created'.tr(),
            ),
          ],
        ),
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
        child: CreateModel<FoodModel>(
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
