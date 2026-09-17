import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constant/app_design_system.dart';

/// Renders an Apex bespoke SVG icon (see [AppIcons]) tinted to a design-system
/// colour and sized via ScreenUtil. Replaces emoji + Material glyphs across the
/// app so nothing looks stock.
///
/// ```dart
/// AppIcon(AppIcons.barbell, size: AppDesignSystem.iconSizeSM, color: AppDesignSystem.primaryStrong)
/// ```
class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const AppIcon(
    this.asset, {
    super.key,
    this.size = AppDesignSystem.iconSizeMD,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size.sp,
      height: size.sp,
      colorFilter: ColorFilter.mode(
        color ?? AppDesignSystem.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
