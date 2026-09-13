import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../cubit/trainee_cubit.dart';

/// Opens the coach "reset trainee password" bottom sheet. The trainee's user
/// name is unchanged; only a new password is set.
Future<void> showResetPasswordSheet(
  BuildContext context, {
  required TraineeCubit cubit,
  required String traineeId,
  required String traineeName,
}) {
  cubit.prepareResetPassword(traineeId);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ResetPasswordSheet(traineeName: traineeName),
    ),
  );
}

class _ResetPasswordSheet extends StatefulWidget {
  final String traineeName;

  const _ResetPasswordSheet({required this.traineeName});

  @override
  State<_ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<_ResetPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingLG.w),
        decoration: BoxDecoration(
          color: AppDesignSystem.surfaceWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDesignSystem.radiusXL.r),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.neutral300,
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
                  ),
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              Text(
                'reset_password'.tr(),
                style: AppDesignSystem.h4.copyWith(color: AppDesignSystem.neutral900),
              ),
              SizedBox(height: AppDesignSystem.spacing2XS.h),
              Text(
                'reset_password_for'.tr(args: [widget.traineeName]),
                style: AppDesignSystem.bodySmall.copyWith(color: AppDesignSystem.neutral500),
              ),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              AppTextField(
                label: 'new_password'.tr(),
                hint: 'password_hint'.tr(),
                obscureText: _obscure,
                prefixIcon: Icon(
                  Icons.lock_reset_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.neutral500,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: AppDesignSystem.iconSizeSM.sp,
                    color: AppDesignSystem.neutral500,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                onChanged: (v) => cubit.resetPasswordParams.newPassword = v,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'password_min_length'.tr() : null,
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              AppTextField(
                label: 'confirm_password'.tr(),
                hint: 'password_hint'.tr(),
                controller: _confirm,
                obscureText: _obscure,
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.neutral500,
                ),
                validator: (v) => (v != cubit.resetPasswordParams.newPassword)
                    ? 'passwords_do_not_match'.tr()
                    : null,
              ),
              SizedBox(height: AppDesignSystem.spacingXL.h),
              CreateModel<String>(
                withValidation: true,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  return _formKey.currentState?.validate() ?? false;
                },
                useCaseCallBack: (_) => cubit.resetPassword(),
                onSuccess: (_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('password_reset_done'.tr()),
                      backgroundColor: AppDesignSystem.successColor,
                    ),
                  );
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
                    'reset_password'.tr(),
                    style: AppDesignSystem.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
            ],
          ),
        ),
      ),
    );
  }
}
