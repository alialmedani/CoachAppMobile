import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Typed-confirmation delete dialog: the coach must retype the plan name before
/// the destructive action is enabled. Returns `true` when confirmed.
Future<bool> confirmDeleteNutritionPlan(
  BuildContext context,
  String planName, {
  bool isActive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _DeleteNutritionPlanDialog(planName: planName, isActive: isActive),
  );
  return result ?? false;
}

class _DeleteNutritionPlanDialog extends StatefulWidget {
  final String planName;
  final bool isActive;

  const _DeleteNutritionPlanDialog({
    required this.planName,
    this.isActive = false,
  });

  @override
  State<_DeleteNutritionPlanDialog> createState() =>
      _DeleteNutritionPlanDialogState();
}

class _DeleteNutritionPlanDialogState
    extends State<_DeleteNutritionPlanDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _matches = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('delete_nutrition_plan'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // F11: deleting the trainee's ACTIVE plan strips their current program.
          if (widget.isActive) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.errorColor,
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: Text(
                    'delete_active_plan_warning'.tr(),
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.errorColor,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),
          ],
          Text(
            'delete_nutrition_plan_confirm'.tr(args: [widget.planName]),
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral700,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Text(
            'delete_nutrition_plan_type_name'.tr(),
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          AppTextField(
            hint: widget.planName,
            controller: _controller,
            onChanged: (v) {
              final matches = v.trim() == widget.planName.trim();
              if (matches != _matches) setState(() => _matches = matches);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          style: TextButton.styleFrom(
            foregroundColor: AppDesignSystem.errorColor,
          ),
          child: Text('delete'.tr()),
        ),
      ],
    );
  }
}
