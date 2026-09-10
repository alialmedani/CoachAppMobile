import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
 
import '../../classes/cashe_helper.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../utils/functions/app_logo_provider.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit? fit;
  final double? height;
  final double? radius;
  final double? placeHolderHeight;
  final double? width;
  final double? cacheWidth;
  final double? cacheHeight;
  final Color? color;
  final String? fallbackPlaceHolder;
  final bool removeOnDispose;
  final bool isZoomable;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.height,
    this.radius,
    this.placeHolderHeight,
    this.width,
    this.cacheHeight,
    this.cacheWidth,
    this.color,
    this.fallbackPlaceHolder,
    this.removeOnDispose = true,
    this.isZoomable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = ExtendedImage.network(
      headers: {'Authorization': 'Bearer ${CacheHelper.token}'},
      imageUrl ?? '',
      fit: fit,
      borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
      height: height,
      width: width,
      color: color,
      colorBlendMode: BlendMode.modulate,
      printError: false,
      cacheMaxAge: const Duration(days: 365),
      clearMemoryCacheWhenDispose: removeOnDispose,
      handleLoadingProgress: true,
      mode: isZoomable ? ExtendedImageMode.gesture : ExtendedImageMode.none,
      initGestureConfigHandler: isZoomable
          ? (_) => GestureConfig(
              minScale: 1.0,
              animationMinScale: 0.8,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              initialAlignment: InitialAlignment.center,
            )
          : null,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Center(
              child: SizedBox(
                width: cacheWidth ?? 200.w,
                height: cacheHeight ?? 100.h,
                child: Shimmer.fromColors(
                  baseColor: AppColors.primary,
                  highlightColor: AppColors.secoundPrimary,
                  child: Container(
                    height: placeHolderHeight ?? 100.h,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.transparent),
                  ),
                ),
              ),
            );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return Padding(
              padding: EdgeInsets.all(radius ?? 0.0),
              child: appLogo(),
            );
        }
      },
    );

    return imageWidget;
  }
}
