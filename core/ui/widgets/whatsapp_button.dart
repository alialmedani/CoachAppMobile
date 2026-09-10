import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/functions/whatsapp_launcher.dart';

/// A reusable "message on WhatsApp" button using the WhatsApp brand glyph.
///
/// - [labeled] = true → a filled green pill (icon + "WhatsApp"), for action bars.
/// - [labeled] = false → a filled green circle (icon only), for list cards.
class WhatsappButton extends StatelessWidget {
  final String? phone;
  final String? message;
  final bool labeled;

  /// Diameter (circle) / height (pill) in logical px before screenutil scaling.
  final double size;

  const WhatsappButton({
    super.key,
    required this.phone,
    this.message,
    this.labeled = false,
    this.size = 44,
  });

  static const Color _green = Color(0xFF25D366);

  void _open() => openWhatsApp(phone, message: message);

  Widget _glyph(double dimension) => SvgPicture.asset(
        'assets/icons/whatsapp.svg',
        width: dimension,
        height: dimension,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );

  @override
  Widget build(BuildContext context) {
    final boxShadow = [
      BoxShadow(
        color: _green.withValues(alpha: 0.35),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];

    if (labeled) {
      final radius = BorderRadius.circular(14.r);
      return DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: boxShadow),
        child: Material(
          color: _green,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: _open,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _glyph(20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'action_whatsapp'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final d = size.w;
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: boxShadow),
      child: Material(
        color: _green,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _open,
          child: SizedBox(
            width: d,
            height: d,
            child: Center(child: _glyph(size * 0.52)),
          ),
        ),
      ),
    );
  }
}
