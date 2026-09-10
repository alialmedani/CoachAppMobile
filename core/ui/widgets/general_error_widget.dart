import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../../constant/text_styles/font_size.dart';
import '../screens/base_hens_state_screen.dart';

class GeneralErrorWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? body;
  final String? message;
  final String? buttonText;
  final double? height;
  final double? width;
  final bool showBackButton;
  const GeneralErrorWidget({
    super.key,
    this.onTap,
    this.message,
    this.buttonText,
    this.body,
    this.height,
    this.width,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showBackButton
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: Center(
        child: BaseHensStateScreen(
          width: 150.w,
          textWidget: Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyle.getRegularStyle(
              color: AppColors.grey9A,
              fontSize: AppFontSize.size_16,
            ),
          ),
          buttonText: "Try again",
          onTap: onTap,
          description: '',
        ),
      ),
    );
  }
}
