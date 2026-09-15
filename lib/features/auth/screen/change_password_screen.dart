import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/params/change_password_params.dart';
import '../data/repository/auth_repository.dart';
import '../data/usecase/change_password_usecase.dart';

/// Self change-password (both roles). Wraps the Phase-1 auth
/// [ChangePasswordUsecase] (`POST /api/account/my-profile/change-password`).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _repository = AuthRepository();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_current.text.isEmpty || _next.text.isEmpty) {
      return 'field_required'.tr();
    }
    if (_next.text.length < 6) return 'password_too_short'.tr();
    if (_next.text != _confirm.text) return 'passwords_do_not_match'.tr();
    return null;
  }

  Future<Result> _submit() => ChangePasswordUsecase(_repository).call(
    params: ChangePasswordParams(
      currentPassword: _current.text,
      newPassword: _next.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'change_password'.tr()),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
              children: [
                AppTextField(
                  label: 'current_password'.tr(),
                  controller: _current,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppTextField(
                  label: 'new_password'.tr(),
                  controller: _next,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppTextField(
                  label: 'confirm_new_password'.tr(),
                  controller: _confirm,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          Container(
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
              child: CreateModel<Object>(
                withValidation: true,
                onTap: () async {
                  final error = _validate();
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
                useCaseCallBack: (_) => _submit(),
                onSuccess: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('password_changed'.tr()),
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
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMD.r,
                    ),
                  ),
                  child: Text(
                    'change_password'.tr(),
                    style: AppDesignSystem.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
