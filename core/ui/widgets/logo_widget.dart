import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../../constant/text_styles/font_size.dart';
import '../../utils/functions/app_logo_provider.dart';

class LogoWidget extends StatelessWidget {
  final double? height;
  final double? width;
  const LogoWidget({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        appLogo(height: height ?? 100, width: width ?? 100),
        const SizedBox(height: 16),
        Text(
          "AppName".tr(),
          style: AppTextStyle.getBoldStyle(
            color: AppColors.primary,
            fontSize: AppFontSize.size_16,
          ),
        ),
      ],
    );
  }
}
