import 'package:flutter/material.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../../constant/text_styles/font_size.dart';

class CustomTextFormField extends StatefulWidget {
  final String? labelText;
  final Color? borderColor;
  final String? hintText;
  final String? errorText;
  final String? initValue;
  final Widget? prefixIcon;
  final Widget? labelWidget;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final bool isObscure;
  final bool? readOnly;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextInputType? keyboardType;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? paddingTop;
  final VoidCallback? onComplete;
  final Function(String? value)? validator;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final Function(String value)? onChanged;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final Color? focusedColor;

  const CustomTextFormField({
    super.key,
    this.borderRadius,
    this.labelWidget,
    this.validator,
    this.labelText,
    this.minLines,
    this.textAlign,
    this.labelStyle,
    this.textInputAction,
    this.errorText,
    this.paddingTop,
    this.borderColor,
    this.isObscure = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.initValue,
    this.keyboardType,
    this.height,
    this.readOnly,
    this.onComplete,
    this.onChanged,
    this.width,
    this.focusedColor,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextFormField(
        focusNode: _focusNode,
        initialValue: widget.initValue,
        validator: (widget.validator != null)
            ? (value) => widget.validator!(value)
            : null,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        textInputAction: widget.textInputAction ?? TextInputAction.next,
        textAlign: widget.textAlign ?? TextAlign.start,
        onChanged: (value) {
          if (widget.onChanged != null) widget.onChanged!(value);
        },
        onEditingComplete: widget.onComplete,
        readOnly: widget.readOnly ?? false,
        keyboardType: widget.keyboardType,
        style:
            widget.textStyle ??
            AppTextStyle.getMediumStyle(
              color: AppColors.black1c,
              fontSize: AppFontSize.size_14,
            ),
        obscureText: widget.isObscure,
        controller: widget.controller,
        cursorColor: Colors.deepOrange,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: widget.paddingTop ?? 12,
            bottom: 12,
          ),

          hintStyle:
              widget.hintStyle ??
              AppTextStyle.getMediumStyle(
                color: Theme.of(context).primaryColor,
                fontSize: AppFontSize.size_12,
              ),
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          filled: true,
          enabled: true,
          fillColor: widget.fillColor ?? Colors.transparent,
          border: InputBorder.none,
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius ?? 8),
            ),
            borderSide: BorderSide(
              color: widget.borderColor ?? AppColors.greyDD,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(
              color: widget.borderColor ?? AppColors.greyDD,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius ?? 8),
            ),
            borderSide: BorderSide(
              color: widget.borderColor ?? AppColors.greyDD,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius ?? 8),
            ),
            borderSide: BorderSide(
              color: isFocused
                  ? (widget.focusedColor ?? AppColors.primary)
                  : (widget.borderColor ?? AppColors.greyDD),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius ?? 8),
            ),
            borderSide: const BorderSide(color: Colors.red),
          ),
          labelText: widget.labelWidget == null ? widget.labelText : null,
          label: widget.labelWidget != null
              ? Center(child: Text(widget.labelText ?? ''))
              : null,
          labelStyle:
              widget.labelStyle ??
              AppTextStyle.getBoldStyle(
                color: Theme.of(context).colorScheme.primaryColor,
                fontSize: AppFontSize.size_14,
              ),
          errorText: widget.errorText,
          suffixIcon: widget.suffixIcon,
          errorStyle: AppTextStyle.getRegularStyle(
            fontSize: AppFontSize.size_14,
            color: Colors.red,
          ),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
