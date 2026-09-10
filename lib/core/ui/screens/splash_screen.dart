import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../classes/cashe_helper.dart';
import '../../constant/app_design_system.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../../utils/Navigation/navigation.dart';

/// CoachApp branded splash screen.
///
/// Shows the animated two-line app name + tagline, then routes on to the app.
/// It is **feature-agnostic**: pass [home] and [login] and, after the intro
/// animation, it navigates to [home] when a token is cached, otherwise to
/// [login]. When neither is wired yet (features still being built) it simply
/// stays on the splash and logs a hint in debug.
///
/// TODO(CoachApp): once auth + role resolution exist, decide the destination
/// from the current user (e.g. trainee home vs coach home) instead of a single
/// [home] widget, and add the app-version/update gate if the backend exposes one.
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
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _taglineController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _drawingController;
  late AnimationController _pulseController;

  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _taglineFadeAnimation;
  late Animation<Offset> _taglineSlideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _drawingAnimation;
  late Animation<double> _pulseAnimation;

  // Helper: is [char] an Arabic letter?
  bool _isArabicLetter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x0600 && code <= 0x06FF) || // Arabic
        (code >= 0x0750 && code <= 0x077F) || // Arabic Supplement
        (code >= 0xFB50 && code <= 0xFDFF) || // Arabic Presentation Forms-A
        (code >= 0xFE70 && code <= 0xFEFF); // Arabic Presentation Forms-B
  }

  // Helper: does [char] NOT connect to the following letter?
  bool _isNonConnecting(String char) {
    if (char.isEmpty) return true;
    final code = char.codeUnitAt(0);
    return code == 0x0627 || // ا Alef
        code == 0x0622 || // آ Alef with Madda
        code == 0x0623 || // أ Alef with Hamza above
        code == 0x0625 || // إ Alef with Hamza below
        code == 0x0624 || // ؤ Waw with Hamza
        code == 0x062F || // د Dal
        code == 0x0630 || // ذ Thal
        code == 0x0631 || // ر Ra
        code == 0x0632 || // ز Zain
        code == 0x0648; // و Waw
  }

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeInOut),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Cubic(0.25, 0.1, 0.25, 1.0),
          ),
        );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _taglineFadeAnimation = CurvedAnimation(
      parent: _taglineController,
      curve: const Cubic(0.33, 0.0, 0.2, 1.0),
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -2.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: const Cubic(0.68, -0.55, 0.265, 1.55),
          ),
        );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _drawingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _drawingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sequence the intro: letters → tagline → shimmer → gentle breathing pulse.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _drawingController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _taglineController.forward();
    });
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) _shimmerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });

    initializeApp();
  }

  Future<void> initializeApp() async {
    // Hold on the splash long enough for the intro animation to breathe.
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
    _textController.dispose();
    _taglineController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _drawingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.primaryColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // CoachApp teal animated gradient backdrop.
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppDesignSystem.primaryLight
                          .withValues(alpha: 0.92 + (_glowAnimation.value * 0.08)),
                      AppDesignSystem.primaryColor,
                      AppDesignSystem.primaryDark,
                      AppDesignSystem.primaryColor,
                      AppDesignSystem.primaryDark,
                      const Color(0xFF0A4A43)
                          .withValues(alpha: 0.88 + (_glowAnimation.value * 0.12)),
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                ),
              );
            },
          ),

          // Subtle floating particles.
          ...List.generate(6, (index) => _buildFloatingParticle(index)),

          // Main content.
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              _buildAnimatedLine(
                                'app_name_line1'.tr(),
                                fromTop: true,
                              ),
                              SizedBox(height: 8.h),
                              _buildAnimatedLine(
                                'app_name_line2'.tr(),
                                fromTop: false,
                              ),
                              SizedBox(height: 24.h),
                              _buildDecorativeLine(),
                              SizedBox(height: 20.h),
                              _buildTagline(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 5),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// One animated name line — letter-by-letter reveal with a stroke→fill
  /// "drawing" effect, with ZWJ handling so Arabic letters stay connected.
  Widget _buildAnimatedLine(String appName, {required bool fromTop}) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textController,
        _shimmerController,
        _drawingController,
      ]),
      builder: (context, child) {
        final totalLength = appName.length;
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalLength, (index) {
              final rawProgress =
                  (_textController.value * (totalLength + 3)) - index;
              final letterProgress = rawProgress.clamp(0.0, 1.0);

              final drawingProgress =
                  (_drawingAnimation.value * (totalLength + 2)) - index;
              final letterDrawProgress = drawingProgress.clamp(0.0, 1.0);

              final elasticProgress = letterProgress < 0.8
                  ? letterProgress / 0.8
                  : 1.0 + (letterProgress - 0.8) * 0.5;

              final opacity = (letterProgress * 1.2).clamp(0.0, 1.0);
              final scale = elasticProgress > 1.0
                  ? (2.0 - elasticProgress).clamp(0.8, 1.0)
                  : (elasticProgress * 0.5 + 0.5).clamp(0.0, 1.0);
              final slideOffset =
                  (fromTop ? -1 : 1) * (1.0 - letterProgress) * 35;
              final rotation = (1.0 - letterProgress) * 0.15;

              String displayChar = appName[index];
              if (_isArabicLetter(displayChar)) {
                if (index > 0) {
                  final prevChar = appName[index - 1];
                  if (_isArabicLetter(prevChar) && !_isNonConnecting(prevChar)) {
                    displayChar = '‍$displayChar';
                  }
                }
                if (index < totalLength - 1 && !_isNonConnecting(displayChar)) {
                  final nextChar = appName[index + 1];
                  if (_isArabicLetter(nextChar)) {
                    displayChar = '$displayChar‍';
                  }
                }
              }

              return Transform.translate(
                offset: Offset(0, slideOffset),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: ClipPath(
                        clipper: DrawingClipper(progress: letterDrawProgress),
                        child: Stack(
                          children: [
                            if (letterDrawProgress < 1.0)
                              Text(
                                displayChar,
                                style: AppTextStyle.getBoldStyle(
                                  color: Colors.transparent,
                                  fontSize: 72.sp,
                                ).copyWith(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2.5
                                    ..color = Colors.white.withValues(
                                      alpha: (1.0 - letterDrawProgress * 0.5)
                                          .clamp(0.5, 1.0),
                                    ),
                                ),
                              ),
                            Text(
                              displayChar,
                              style: AppTextStyle.getBoldStyle(
                                color: Colors.white.withValues(
                                  alpha: (letterDrawProgress * 0.7 + 0.3)
                                      .clamp(0.0, 1.0),
                                ),
                                fontSize: 72.sp,
                              ).copyWith(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDecorativeLine() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: (_textController.value * 1.5).clamp(0.0, 1.0),
          child: Container(
            width: 120.w,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white,
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    return SlideTransition(
      position: _taglineSlideAnimation,
      child: FadeTransition(
        opacity: _taglineFadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.16),
                  ],
                ),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 9.w),
                  Flexible(
                    child: Text(
                      'splash_tagline'.tr(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.getMediumStyle(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final leftPosition = (index * 18 % 100) / 100 * screenWidth;
    final delay = index * 0.16;
    final size = 38.0 + (index * 10.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_particleAnimation, _glowController]),
      builder: (context, child) {
        final progress = (_particleAnimation.value + delay) % 1.0;
        final yPosition = screenHeight * progress - size;
        final rotation = progress * 360 * (index.isEven ? 1 : -1);

        return Positioned(
          left: leftPosition,
          top: yPosition,
          child: Transform.rotate(
            angle: rotation * 0.0174533,
            child: Opacity(
              opacity: (0.10 - (progress * 0.06)) * _glowAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      index % 2 == 0 ? null : BorderRadius.circular(10.r),
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reveals a letter from bottom to top, giving the "drawing" effect.
class DrawingClipper extends CustomClipper<Path> {
  final double progress;

  DrawingClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();
    final revealHeight = size.height * progress;
    path.addRect(
      Rect.fromLTRB(0, size.height - revealHeight, size.width, size.height),
    );
    return path;
  }

  @override
  bool shouldReclip(DrawingClipper oldClipper) => oldClipper.progress != progress;
}
