import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_design_system.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral700,
              fontWeight: AppDesignSystem.medium,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          readOnly: readOnly,
          onChanged: onChanged,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? AppDesignSystem.surfaceWhite
                : AppDesignSystem.neutral100,
            hintStyle: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral400,
            ),
            helperStyle: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutral500,
            ),
            errorStyle: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.errorColor,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.spacingMD.w,
              vertical: AppDesignSystem.spacingSM.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.neutral300,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.neutral300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              borderSide: BorderSide(
                color: AppDesignSystem.neutral200,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
