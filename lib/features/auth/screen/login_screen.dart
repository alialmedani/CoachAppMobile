import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/Navigation/navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/session_cubit.dart';
import 'post_login_router.dart';

/// Sign-in screen: gym/coach code + username + password.
///
/// The submit action is driven by [SessionCubit] (the app-level session state),
/// which orchestrates token → persist → bootstrap and emits Authenticated /
/// AuthError. On success we route on to the [PostLoginRouter] role gate.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<SessionCubit>().login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      body: SafeArea(
        child: BlocConsumer<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigation.pushAndRemoveUntil(const PostLoginRouter());
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppDesignSystem.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<SessionCubit>();
            final isLoading = state is Authenticating;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacingLG.w,
                vertical: AppDesignSystem.spacingXL.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppDesignSystem.spacing2XL.h),
                    _buildHeader(),
                    SizedBox(height: AppDesignSystem.spacing2XL.h),
                    AppTextField(
                      label: 'gym_code'.tr(),
                      hint: 'gym_code_hint'.tr(),
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.fitness_center_outlined,
                        size: AppDesignSystem.iconSizeSM.sp,
                        color: AppDesignSystem.neutral500,
                      ),
                      onChanged: (value) =>
                          cubit.loginParams.tenantCode = value.trim(),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'gym_code_required'.tr()
                          : null,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'username'.tr(),
                      hint: 'username_hint'.tr(),
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        size: AppDesignSystem.iconSizeSM.sp,
                        color: AppDesignSystem.neutral500,
                      ),
                      onChanged: (value) =>
                          cubit.loginParams.username = value.trim(),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'username_required'.tr()
                          : null,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'password'.tr(),
                      hint: 'password_hint'.tr(),
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        size: AppDesignSystem.iconSizeSM.sp,
                        color: AppDesignSystem.neutral500,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppDesignSystem.iconSizeSM.sp,
                          color: AppDesignSystem.neutral500,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      onChanged: (value) => cubit.loginParams.password = value,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'password_required'.tr()
                          : null,
                    ),
                    SizedBox(height: AppDesignSystem.spacing2XL.h),
                    AppButton(
                      text: 'login_button'.tr(),
                      fullWidth: true,
                      size: AppButtonSize.large,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDesignSystem.spacingLG.r),
          decoration: BoxDecoration(
            color: AppDesignSystem.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            size: AppDesignSystem.iconSizeXL.sp,
            color: AppDesignSystem.primaryColor,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingLG.h),
        Text(
          'login_title'.tr(),
          textAlign: TextAlign.center,
          style: AppDesignSystem.h3.copyWith(color: AppDesignSystem.neutral900),
        ),
        SizedBox(height: AppDesignSystem.spacingXS.h),
        Text(
          'login_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral500,
          ),
        ),
      ],
    );
  }
}
