import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_design_system.dart';

/// Scrolling (non-pinned) counterpart to [AppTopBar].
///
/// Renders a [SliverAppBar] styled to match [AppTopBar] but that **scrolls away
/// with the content** instead of staying fixed — the app-wide "no pinned app
/// bar" behaviour. It `floating`+`snap`s back into view the moment the user
/// scrolls up, so the title/actions are always one small drag away.
///
/// Drop it in as the first sliver of a [CustomScrollView] (see
/// [SliverPaginatedList], which places it above its search/filter header and
/// list). On pushed routes (detail/edit screens) `automaticallyImplyLeading`
/// still yields the back button — it just scrolls with everything else.
class AppSliverTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  /// Reappear on scroll-up (`floating`) and animate fully in/out in one gesture
  /// (`snap`). Both default on; `pinned` stays false so nothing sticks.
  final bool floating;
  final bool snap;
  final bool pinned;

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Optional pinned sub-header (rarely used — the "everything scrolls" default
  /// puts sub-headers in the scroll body instead).
  final PreferredSizeWidget? bottom;

  const AppSliverTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.floating = true,
    this.snap = true,
    this.pinned = false,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppDesignSystem.neutral900;
    return SliverAppBar(
      backgroundColor: backgroundColor ?? AppDesignSystem.surfaceWhite,
      foregroundColor: fg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      floating: floating,
      snap: floating && snap,
      pinned: pinned,
      leading: leading,
      centerTitle: centerTitle,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: centerTitle
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppDesignSystem.h5.copyWith(color: fg)),
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: fg.withValues(alpha: 0.7),
                  ),
                ),
              ],
            )
          : Text(title, style: AppDesignSystem.h5.copyWith(color: fg)),
      actions: actions,
      bottom: bottom,
    );
  }
}
