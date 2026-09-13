import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/trainee_model.dart';

/// Sticky bottom submit bar backed by the [CreateModel] boilerplate (which owns
/// the Loading/Success/Error lifecycle). Used by the create and edit screens.
class TraineeSubmitBar extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String label;
  final Future<Result> Function(dynamic) useCaseCallBack;
  final String successMessage;

  const TraineeSubmitBar({
    super.key,
    required this.formKey,
    required this.label,
    required this.useCaseCallBack,
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
        child: CreateModel<TraineeModel>(
          withValidation: true,
          onTap: () async {
            FocusScope.of(context).unfocus();
            return formKey.currentState?.validate() ?? false;
          },
          useCaseCallBack: (data) => useCaseCallBack(data),
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
