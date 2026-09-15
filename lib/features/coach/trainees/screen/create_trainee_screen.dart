import 'dart:convert';

import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/trainee_cubit.dart';
import 'widgets/trainee_profile_form.dart';
import 'widgets/trainee_submit_bar.dart';

/// Create a new trainee: login credentials the coach hands over, plus the
/// coaching profile. Submit is driven by the [CreateModel] boilerplate widget.
class CreateTraineeScreen extends StatefulWidget {
  const CreateTraineeScreen({super.key});

  @override
  State<CreateTraineeScreen> createState() => _CreateTraineeScreenState();
}

class _CreateTraineeScreenState extends State<CreateTraineeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  /// Snapshot of the empty draft; the guard compares against it to know
  /// whether the coach has entered anything worth confirming before leaving.
  late final String _initialJson;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TraineeCubit>();
    cubit.prepareCreate();
    _initialJson = jsonEncode(cubit.createTraineeParams.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    return UnsavedChangesGuard(
      isDirty: () =>
          jsonEncode(cubit.createTraineeParams.toJson()) != _initialJson,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'add_trainee'.tr(),
          subtitle: 'add_trainee_subtitle'.tr(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormSection(
                        title: 'login_credentials'.tr(),
                        subtitle: 'login_credentials_hint'.tr(),
                        children: [
                          AppTextField(
                            label: 'username'.tr(),
                            hint: 'username_hint'.tr(),
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: AppDesignSystem.iconSizeSM.sp,
                              color: AppDesignSystem.neutral500,
                            ),
                            onChanged: (v) =>
                                cubit.createTraineeParams.userName = v.trim(),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'field_required'.tr()
                                : null,
                          ),
                          AppTextField(
                            label: 'password'.tr(),
                            hint: 'password_hint'.tr(),
                            obscureText: _obscure,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: AppDesignSystem.iconSizeSM.sp,
                              color: AppDesignSystem.neutral500,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: AppDesignSystem.iconSizeSM.sp,
                                color: AppDesignSystem.neutral500,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            onChanged: (v) =>
                                cubit.createTraineeParams.password = v,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'password_min_length'.tr()
                                : null,
                          ),
                        ],
                      ),
                      TraineeProfileForm(params: cubit.createTraineeParams),
                    ],
                  ),
                ),
              ),
            ),
            TraineeSubmitBar(
              formKey: _formKey,
              label: 'create_trainee'.tr(),
              useCaseCallBack: (_) => cubit.createTrainee(),
              successMessage: 'trainee_created'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
