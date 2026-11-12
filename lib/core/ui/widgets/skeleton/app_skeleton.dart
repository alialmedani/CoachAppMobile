import 'package:coachappmobile/core/constant/app_colors/app_colors.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Premium content-shaped skeleton loaders for the whole app.
///
/// Unlike a single global spinner, these mirror the *shape* of the screen that
/// is loading — card rows, a detail hero, a dashboard — so the placeholder reads
/// as "the content is arriving" and the swap to real data is seamless.
///
/// Design:
/// * **One cohesive shimmer sweep** wraps each loader (via [Skeleton]) rather
///   than one shimmer per box — the calm, premium look.
/// * **Theme-aware** — base/highlight are derived from the app colour scheme, so
///   the same widgets look right in light *and* dark.
/// * **RTL-safe** — directional insets + symmetric bones; ScreenUtil-sized.
///
/// [SkeletonBone] applies ScreenUtil internally, so pass **raw logical pixels**
/// (e.g. `height: 48`, not `48.h`). Spacing between bones still uses the design
/// tokens (`AppDesignSystem.spacingMD.h`) as elsewhere.
///
/// Wire the matching variant into a boilerplate loader's `loadingWidget`:
/// ```dart
/// PaginationList<Foo>(loadingWidget: AppSkeleton.list(), ...)
/// GetModel<Foo>(loadingWidget: AppSkeleton.detail(), ...)
/// ```
/// For a bespoke layout compose [SkeletonBone]s inside a [Skeleton] wrapper.
class AppSkeleton {
  const AppSkeleton._();

  /// Default list-screen loader: a column of card-row silhouettes matching the
  /// `*Card` widgets (leading square, title + meta lines, trailing chevron).
  static Widget list({
    int itemCount = 7,
    EdgeInsetsGeometry? padding,
    bool thumbnail = true,
    int lines = 2,
  }) {
    return Skeleton(
      child: ListView(
        padding: padding ??
            EdgeInsetsDirectional.fromSTEB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < itemCount; i++)
            Padding(
              padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
              child: _CardRowBones(thumbnail: thumbnail, lines: lines),
            ),
        ],
      ),
    );
  }

  /// Embedded card-row loader (no outer padding / no scroll view) — for a
  /// `GetModel` nested inside an already-scrolling screen (e.g. a dashboard
  /// preview rail).
  static Widget cards({
    int count = 3,
    bool thumbnail = true,
    int lines = 2,
  }) {
    return Skeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
              child: _CardRowBones(thumbnail: thumbnail, lines: lines),
            ),
        ],
      ),
    );
  }

  /// Detail-screen loader: a hero block, a title line, a meta-chip row, a short
  /// paragraph and a couple of section cards.
  static Widget detail({
    EdgeInsetsGeometry? padding,
    bool hero = true,
    int sections = 2,
  }) {
    return Skeleton(
      child: ListView(
        padding: padding ??
            EdgeInsetsDirectional.fromSTEB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          if (hero) ...[
            const SkeletonBone.box(height: 180, width: double.infinity),
            SizedBox(height: AppDesignSystem.spacingLG.h),
          ],
          const SkeletonBone.line(width: 220, height: 20),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          const Row(
            children: [
              SkeletonBone.pill(width: 84),
              SizedBox(width: 8),
              SkeletonBone.pill(width: 64),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          const _ParagraphBones(lines: 3),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          for (var i = 0; i < sections; i++) ...[
            const SkeletonBone.box(
              height: 96,
              width: double.infinity,
              radius: AppDesignSystem.radiusLG,
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),
          ],
        ],
      ),
    );
  }

  /// Dashboard / overview loader: an identity hero, a row of stat tiles, then a
  /// short list of card rows.
  static Widget dashboard({
    EdgeInsetsGeometry? padding,
    int tiles = 2,
    int rows = 3,
  }) {
    return Skeleton(
      child: ListView(
        padding: padding ??
            EdgeInsetsDirectional.fromSTEB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingMD.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacing4XL.h,
            ),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonBone.box(
            height: 96,
            width: double.infinity,
            radius: AppDesignSystem.radiusLG,
          ),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          Row(
            children: [
              for (var i = 0; i < tiles; i++) ...[
                if (i > 0) SizedBox(width: AppDesignSystem.spacingSM.w),
                const Expanded(
                  child: SkeletonBone.box(
                    height: 88,
                    radius: AppDesignSystem.radiusLG,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingLG.h),
          const SkeletonBone.line(width: 160, height: 16),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          for (var i = 0; i < rows; i++)
            Padding(
              padding: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
              child: const _CardRowBones(thumbnail: true, lines: 2),
            ),
        ],
      ),
    );
  }
}

/// Wraps [child] in the app's shimmer sweep with theme-aware colours. Use it
/// directly only for bespoke skeletons; the [AppSkeleton] variants apply it for
/// you.
class Skeleton extends StatelessWidget {
  final Widget child;

  const Skeleton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.appSurfaceMuted;
    // Sweep toward the card surface (lighter in light mode, a subtle lift in
    // dark) so the highlight reads on both themes.
    final highlight =
        Color.lerp(base, scheme.appCard, scheme.isDark ? 0.5 : 0.85)!;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// A single opaque placeholder shape. Fills with the theme's muted surface so it
/// reads correctly even outside a [Skeleton] wrapper; under a wrapper the
/// shimmer animates across it. Pass **raw logical pixels** — ScreenUtil is
/// applied here.
class SkeletonBone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final bool circle;

  const SkeletonBone.box({
    super.key,
    this.width,
    required this.height,
    this.radius = AppDesignSystem.radiusMD,
  }) : circle = false;

  /// A text-line bone (small corner radius, 12dp tall by default).
  const SkeletonBone.line({
    super.key,
    this.width,
    this.height = 12.0,
  })  : radius = AppDesignSystem.radiusSM,
        circle = false;

  /// A small pill (badge / chip placeholder).
  const SkeletonBone.pill({
    super.key,
    this.width,
    this.height = 20.0,
  })  : radius = 999,
        circle = false;

  const SkeletonBone.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        radius = 0,
        circle = true;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.appSurfaceMuted;
    if (circle) {
      return Container(
        width: width!.r,
        height: width!.r,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    final w = width == null
        ? null
        : (width == double.infinity ? double.infinity : width!.w);
    return Container(
      width: w,
      height: height.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// The recurring "list card" silhouette: leading square, stacked title + meta
/// lines, trailing chevron — matching the app's `*Card` row widgets.
class _CardRowBones extends StatelessWidget {
  final bool thumbnail;
  final int lines;

  const _CardRowBones({required this.thumbnail, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.appCard,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
        border: Border.all(color: Theme.of(context).colorScheme.appBorder),
      ),
      child: Row(
        children: [
          if (thumbnail) ...[
            const SkeletonBone.box(width: 48, height: 48),
            SizedBox(width: AppDesignSystem.spacingMD.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBone.line(width: 150, height: 14),
                if (lines > 1) ...[
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                  const Row(
                    children: [
                      SkeletonBone.pill(width: 60),
                      SizedBox(width: 8),
                      SkeletonBone.pill(width: 44),
                    ],
                  ),
                ],
                if (lines > 2) ...[
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                  const SkeletonBone.line(width: 200, height: 10),
                ],
              ],
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingSM.w),
          const SkeletonBone.box(
            width: 16,
            height: 16,
            radius: AppDesignSystem.radiusSM,
          ),
        ],
      ),
    );
  }
}

/// A few text lines of decreasing width — a paragraph placeholder.
class _ParagraphBones extends StatelessWidget {
  final int lines;

  const _ParagraphBones({required this.lines});

  @override
  Widget build(BuildContext context) {
    const widths = <double>[1.0, 0.9, 0.8, 0.6];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: AppDesignSystem.spacingSM.h),
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: widths[i % widths.length],
            child: const SkeletonBone.line(width: double.infinity, height: 12),
          ),
        ],
      ],
    );
  }
}
