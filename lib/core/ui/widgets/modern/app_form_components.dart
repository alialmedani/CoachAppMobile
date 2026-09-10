import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constant/app_design_system.dart';

/// A modern form section header to group related form fields
class AppFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacingMD.w,
                vertical: AppDesignSystem.spacingSM.h,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppDesignSystem.h5.copyWith(
                  color: AppDesignSystem.neutral900,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  subtitle!,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        ...children.map((child) {
          final index = children.indexOf(child);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < children.length - 1
                  ? AppDesignSystem.spacingMD.h
                  : 0,
            ),
            child: child,
          );
        }),
        if (showDivider) ...[
          SizedBox(height: AppDesignSystem.spacingXL.h),
          Divider(color: AppDesignSystem.neutral200, thickness: 1, height: 1),
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ],
    );
  }
}

/// A container for forms with consistent padding and background
class AppFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppFormContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        boxShadow: AppDesignSystem.shadowSM,
      ),
      child: child,
    );
  }
}

/// A sticky bottom bar for form actions (Save, Cancel, etc.)
class AppFormBottomBar extends StatelessWidget {
  final Widget primaryAction;
  final Widget? secondaryAction;
  final EdgeInsetsGeometry? padding;

  const AppFormBottomBar({
    super.key,
    required this.primaryAction,
    this.secondaryAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (secondaryAction != null) ...[
              Expanded(child: secondaryAction!),
              SizedBox(width: AppDesignSystem.spacingSM.w),
            ],
            Expanded(
              flex: secondaryAction != null ? 1 : 1,
              child: primaryAction,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown field that matches AppTextField styling
class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final Widget? prefixIcon;
  final bool enabled;

  const AppDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Validate and sanitize value
    T? effectiveValue = value;

    // If value is an empty string or doesn't exist in items, set to null
    if (value != null && items.isNotEmpty) {
      final matchingItems = items.where((item) => item.value == value).length;
      if (matchingItems == 0) {
        // Value doesn't exist in items, use null instead
        effectiveValue = null;
      } else if (matchingItems > 1) {
        // Duplicate values detected
        assert(
          false,
          'AppDropdownField: Value "$value" appears $matchingItems times in items. '
          'Each dropdown item must have a unique value.',
        );
      }
    }

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
        DropdownButtonFormField<T>(
          initialValue: effectiveValue,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled
                ? AppDesignSystem.surfaceWhite
                : AppDesignSystem.neutral100,
            hintStyle: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral400,
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
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral900,
          ),
        ),
      ],
    );
  }
}

/// Checkbox field with label
class AppCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? subtitle;
  final bool enabled;

  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: value
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: value
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: AppDesignSystem.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusXS.r),
              ),
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral900,
                      fontWeight: AppDesignSystem.medium,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppDesignSystem.spacing2XS.h),
                    Text(
                      subtitle!,
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radio field group
class AppRadioField<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? subtitle;
  final bool enabled;

  const AppRadioField({
    super.key,
    required this.label,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: enabled ? () => onChanged?.call(value) : null,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: isSelected
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: enabled ? onChanged : null,
              activeColor: AppDesignSystem.primaryColor,
            ),
            SizedBox(width: AppDesignSystem.spacingXS.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral900,
                      fontWeight: AppDesignSystem.medium,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppDesignSystem.spacing2XS.h),
                    Text(
                      subtitle!,
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
