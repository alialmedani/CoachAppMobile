import 'package:flutter/material.dart';
import '../../constant/app_size/app_size.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../../constant/text_styles/font_size.dart';
import 'custom_text_form_field.dart';

class TextFieldSection extends StatelessWidget {
  final String title;
  final TextInputType? textInputType;
  final bool isObscure;
  final String hintText;
  final Color color;
  final Color titleColor;
  final double? borderRadius;
  final String? initValue;
  final Widget? prefix;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function(String)? validator;
  const TextFieldSection({
    super.key,
    required this.title,
    required this.hintText,
    this.prefix,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.isObscure = false,
    this.initValue,
    this.textInputType,
    this.borderRadius,
    required this.color,
    this.controller,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            title,
            style: AppTextStyle.getSemiBoldStyle(
              color: titleColor,
              fontSize: AppFontSize.size_13,
            ),
          ),
        ),
        const SizedBox(height: AppSize.size_8),
        CustomTextFormField(
          borderRadius: borderRadius,
          fillColor: color,
          controller: controller,
          keyboardType: textInputType,
          initValue: initValue,
          isObscure: isObscure,
          suffixIcon: suffixIcon,
          validator: validator != null
              ? (value) => validator!(value ?? '')
              : null,
          onChanged: onChanged != null ? (value) => onChanged!(value) : null,
          prefixIcon: prefix,
          hintText: hintText,
        ),
        const SizedBox(height: AppSize.size_16),
      ],
    );
  }
}
