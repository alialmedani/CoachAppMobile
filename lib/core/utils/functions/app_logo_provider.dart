// app_logo_widget.dart
import 'package:flutter/material.dart';
import '../../classes/cashe_helper.dart';
import '../../constant/app_images/app_images.dart';
import '../../ui/widgets/cached_image.dart';

// app_logo_widget.dart
Widget appLogo({
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  double? radius,
}) {
  final lp = CacheHelper.logoPath;
  if (lp != null && lp.isNotEmpty) {
    final url = '$logIimageUrl$lp';
    return CachedImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      radius: radius,
    );
  }
  return Image.asset(logoPngImage, width: width, height: height, fit: fit);
}
