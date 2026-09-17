import 'package:flutter/material.dart';
import '../../classes/cashe_helper.dart';
import '../../constant/app_images/app_images.dart';
import '../../ui/widgets/apex/ascent_monogram.dart';
import '../../ui/widgets/cached_image.dart';

/// The app's brand mark. Prefers a tenant-supplied logo (from the backend, via
/// [CacheHelper.logoPath]); when none is set it falls back to the Apex
/// **Ascent monogram** — replacing the legacy ported (NOON) logo asset.
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
  return AscentMonogram(size: height ?? width ?? 56, tile: false);
}
