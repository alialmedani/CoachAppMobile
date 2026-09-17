import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../classes/cashe_helper.dart';
import '../../constant/app_design_system.dart';
import '../../utils/Navigation/navigation.dart';
import '../widgets/loading.dart';

/// CoachApp branded splash — the Apex "Orbit Ignition" moment.
///
/// A calm near-black frame with the Ascent monogram inside the Volt Orbit
/// (the very same [LoadingWidget] the app uses for loading, so the splash hands
/// off to the first loading state with no visual break), under the CoachApp
/// wordmark + tagline. Holds briefly for the intro, then routes: to [home] when
/// a token is cached, otherwise [login].
///
/// It is **feature-agnostic** — when neither destination is wired yet it simply
/// stays on the splash and logs a hint in debug.
class SplashScreen extends StatefulWidget {
  /// Where to go when the user is already signed in (a token is cached).
  final Widget? home;

  /// Where to go when there is no cached token.
  final Widget? login;

  const SplashScreen({super.key, this.home, this.login});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Let the Orbit settle, then rise the wordmark + tagline.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _reveal.forward();
    });
    initializeApp();
  }

  Future<void> initializeApp() async {
    // Hold on the splash long enough for the intro to breathe.
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final bool signedIn = (CacheHelper.token?.isNotEmpty ?? false);
    final Widget? next = signedIn ? widget.home : widget.login;

    if (next != null) {
      Navigation.pushAndRemoveUntil(next);
    } else if (kDebugMode) {
      debugPrint(
        'Splash: intro done but no destination wired yet — pass '
        'SplashScreen(home:, login:) once the CoachApp auth/home screens exist.',
      );
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppDesignSystem.surfaceCanvas,
      ),
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceCanvas,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.12),
              radius: 0.72,
              colors: [
                AppDesignSystem.primaryColor.withValues(alpha: 0.05),
                AppDesignSystem.surfaceCanvas,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                // The Orbit — same widget as the app's loader (seamless handoff).
                LoadingWidget(width: 150.w),
                SizedBox(height: AppDesignSystem.spacingXL.h),
                _Lockup(reveal: _reveal),
                const Spacer(flex: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The CoachApp wordmark (Coach in text, App in Volt) + tagline, entering on a
/// gentle fade + rise.
class _Lockup extends StatelessWidget {
  final Animation<double> reveal;
  const _Lockup({required this.reveal});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(reveal.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'app_name_line1'.tr(),
                  style: TextStyle(color: AppDesignSystem.textPrimary),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'app_name_line2'.tr(),
                  style: TextStyle(color: AppDesignSystem.primaryColor),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppDesignSystem.fontFamily,
              fontSize: AppDesignSystem.fontSize4XL.sp,
              fontWeight: AppDesignSystem.extraBold,
              letterSpacing: -0.5,
              height: 1.05,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.spacing2XL.w),
            child: Text(
              'splash_tagline'.tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
