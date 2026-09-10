import 'dart:io';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:coachappmobile/core/classes/cashe_helper.dart';
import 'package:coachappmobile/core/constant/app_colors/app_colors.dart';
import 'package:coachappmobile/core/constant/text_styles/app_text_style.dart';
import 'package:coachappmobile/features/Express/app_info/data/repository/app_info_repository.dart';
import 'package:coachappmobile/features/Express/app_info/screen/update_required_screen.dart';
import 'package:coachappmobile/features/Express/auth/cubit/auth_cubit.dart';
import 'package:coachappmobile/features/Express/delivery/screen/delivery_home_screen.dart';
import 'package:coachappmobile/features/Express/user/settlement/cubit/settlement_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../features/Express/auth/screen/login_screen.dart';
import '../../../features/Express/driver/screen/driver_home_screen.dart';
import '../../../features/Express/employee/screen/package_management_home_screen.dart';
import '../../../features/Express/user/home/screen/merchant_home_screen.dart';
import '../../utils/Navigation/navigation.dart';
import '../../utils/functions/location.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

  // ✅ خزن الـ cubits مرة وحدة
  late final AuthCubit authCubit;
  late final SettlementCubit settlementCubit;

  // Helper function to check if a character is Arabic
  bool _isArabicLetter(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x0600 && code <= 0x06FF) || // Arabic
        (code >= 0x0750 && code <= 0x077F) || // Arabic Supplement
        (code >= 0xFB50 && code <= 0xFDFF) || // Arabic Presentation Forms-A
        (code >= 0xFE70 && code <= 0xFEFF); // Arabic Presentation Forms-B
  }

  // Helper function to check if a character doesn't connect to the next letter
  bool _isNonConnecting(String char) {
    if (char.isEmpty) return true;
    final code = char.codeUnitAt(0);
    // Arabic letters that don't connect to the next letter:
    // Alef variants, Dal, Thal, Ra, Zain, Waw
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

    // ✅ لازم تكون قبل أي await وبـ initState
    authCubit = context.read<AuthCubit>();
    settlementCubit = context.read<SettlementCubit>();

    // Text animation with elegant smooth entrance
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

    // Tagline animation - slide from left with luxury effect
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _taglineFadeAnimation = CurvedAnimation(
      parent: _taglineController,
      curve: const Cubic(0.33, 0.0, 0.2, 1.0), // Luxury smooth fade
    );

    _taglineSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -2.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: const Cubic(0.68, -0.55, 0.265, 1.55), // Enhanced bounce
          ),
        );

    // Glow pulsing effect - more subtle and luxurious
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Elegant floating particles - slower for luxury feel
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Shimmer sweep animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Drawing/writing animation - like someone is writing the text
    _drawingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _drawingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawingController, curve: Curves.easeInOut),
    );

    // Pulse/Breathing animation - subtle professional effect after text completes
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations in elegant sequence - Letters → Tagline
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
        _drawingController.forward(); // Start drawing animation
      }
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _taglineController.forward();
    });

    // Start shimmer after text completes
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) _shimmerController.forward();
    });

    // Start subtle pulse/breathing effect after all animations complete
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });

    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      await GetLocation().getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) print("Location request timed out");
        },
      );
    } catch (e) {
      if (kDebugMode) print("Error initializing location: $e");
    }

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check for app updates
    final updateRequired = await _checkForUpdate();
    if (!mounted) return;

    // If update is required, stop here (user is already on update screen)
    if (updateRequired) {
      return;
    }

    // Check if user is logged in
    if (CacheHelper.token == null) {
      Navigation.pushAndRemoveUntil(const LoginScreen());
      return;
    }

    // Get app configuration and user info
    final appConfigResult = await authCubit.getAppConfig();
    if (!mounted) return;

    if (!appConfigResult.hasDataOnly) {
      Navigation.pushAndRemoveUntil(const LoginScreen());
      return;
    }

    final currentUser = appConfigResult.data;
    authCubit.currentUser = currentUser;

    // Get driver/delivery profile if needed
    if (currentUser?.isDriver == true || currentUser?.isDelivery == true) {
      final driverProfileResult = await authCubit.getDriverProfile();
      if (!mounted) return;

      if (driverProfileResult.hasDataOnly) {
        authCubit.driverId = driverProfileResult.data?.id;
      }
    }

    // Get merchant profile if needed
    if (currentUser?.isMerchant == true) {
      final merchantProfileResult = await settlementCubit
          .fetchMerchantProfile();
      if (!mounted) return;

      if (merchantProfileResult.hasDataOnly) {
        authCubit.merchantId = merchantProfileResult.data?.id;
        authCubit.merchantBusinessName =
            merchantProfileResult.data?.businessName;
        authCubit.merchantBusinessNameAr =
            merchantProfileResult.data?.businessNameAr;
      }
    }

    if (!mounted) return;

    // Navigate to appropriate home screen based on user type
    if (currentUser?.isMerchant == true) {
      Navigation.pushAndRemoveUntil(const MerchantHomeScreen());
    } else if (currentUser?.isDriver == true) {
      Navigation.pushAndRemoveUntil(const DriverHomeScreen());
    } else if (currentUser?.isEmployee == true) {
      Navigation.pushAndRemoveUntil(const PackageManagementHomeScreen());
    } else {
      Navigation.pushAndRemoveUntil(const DeliveryHomeScreen());
    }
  }

  Future<bool> _checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Define app name - update this based on the app type
      // Options: "BakeetCustomer", "BakeetMerchant", "BakeetDriver", etc.
      const String appName = "Noon Express";

      if (kDebugMode) {
        print("Current app version: $currentVersion");
        print("App name: $appName");
        print(
          "Platform: ${Platform.isIOS
              ? 'iOS'
              : Platform.isAndroid
              ? 'Android'
              : 'Unknown'}",
        );
      }

      // Try new endpoint first (with app name)
      final repository = AppInfoRepository();
      final result = await repository.getCurrentAppVersion(appName: appName);

      if (result.hasDataOnly && result.data != null) {
        final appVersion = result.data!;

        String? serverVersion;
        String? updateUrl;

        // Select the appropriate version and store link based on platform
        if (Platform.isIOS) {
          serverVersion = appVersion.iosVersion ?? appVersion.version;
          updateUrl = appVersion.appStoreLink;
          if (kDebugMode) {
            print("iOS - Latest version: $serverVersion");
            print("iOS - App Store link: $updateUrl");
          }
        } else if (Platform.isAndroid) {
          serverVersion = appVersion.version;
          updateUrl = appVersion.googlePlayLink;
          if (kDebugMode) {
            print("Android - Latest version: $serverVersion");
            print("Android - Google Play link: $updateUrl");
          }
        }

        if (serverVersion != null && serverVersion.trim().isNotEmpty) {
          final needsUpdate = _compareVersions(currentVersion, serverVersion);

          if (kDebugMode) {
            print("Update required: $needsUpdate");
          }

          if (needsUpdate) {
            if (!mounted) return false;

            Navigation.pushAndRemoveUntil(
              UpdateRequiredScreen(
                currentVersion: currentVersion,
                latestVersion: serverVersion,
                updateUrl: updateUrl,
              ),
            );
            return true;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error checking for updates: $e");
    }

    return false;
  }

  bool _compareVersions(String currentVersion, String latestVersion) {
    try {
      currentVersion = currentVersion.trim();
      latestVersion = latestVersion.trim();

      if (kDebugMode) {
        print(
          "Comparing versions - Current: $currentVersion, Latest: $latestVersion",
        );
      }

      List<int> current = currentVersion.split('.').map((e) {
        final parsed = int.tryParse(e);
        if (parsed == null && kDebugMode) {
          print("Warning: Could not parse current version segment: $e");
        }
        return parsed ?? 0;
      }).toList();

      List<int> latest = latestVersion.split('.').map((e) {
        final parsed = int.tryParse(e);
        if (parsed == null && kDebugMode) {
          print("Warning: Could not parse latest version segment: $e");
        }
        return parsed ?? 0;
      }).toList();

      while (current.length < latest.length) {
        current.add(0);
      }
      while (latest.length < current.length) {
        latest.add(0);
      }

      if (kDebugMode) {
        print("Parsed current: $current");
        print("Parsed latest: $latest");
      }

      for (int i = 0; i < current.length; i++) {
        if (latest[i] > current[i]) {
          if (kDebugMode) {
            print(
              "Update required: latest[$i] (${latest[i]}) > current[$i] (${current[i]})",
            );
          }
          return true;
        } else if (latest[i] < current[i]) {
          if (kDebugMode) {
            print(
              "Current version is newer: latest[$i] (${latest[i]}) < current[$i] (${current[i]})",
            );
          }
          return false;
        }
      }

      if (kDebugMode) print("Versions are equal - no update required");
      return false;
    } catch (e) {
      if (kDebugMode) print("Error comparing versions: $e");
      return false;
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
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Luxurious animated gradient background
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(
                        0xFFFF3F45,
                      ).withValues(alpha: 0.92 + (_glowAnimation.value * 0.08)),
                      const Color(0xFFE52028),
                      const Color(0xFFD40511),
                      AppColors.primary,
                      const Color(0xFFB00812),
                      const Color(
                        0xFF8B0A0E,
                      ).withValues(alpha: 0.88 + (_glowAnimation.value * 0.12)),
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                  ),
                ),
              );
            },
          ),

          // Subtle floating particles (only 6)
          ...List.generate(6, (index) => _buildFloatingParticle(index)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),

                // App name with two lines - Noon / Express
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
                              // App name with luxury letter-by-letter and shimmer animation
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _textController,
                                  _shimmerController,
                                  _drawingController,
                                ]),
                                builder: (context, child) {
                                  final appName = "app_name_line1".tr();
                                  final totalLength = appName.length;

                                  return Stack(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(totalLength, (
                                            index,
                                          ) {
                                            // Calculate progress for each letter with stagger effect
                                            final rawProgress =
                                                (_textController.value *
                                                    (totalLength + 3)) -
                                                index;
                                            final letterProgress = rawProgress
                                                .clamp(0.0, 1.0);

                                            // Drawing effect progress for each letter
                                            final drawingProgress =
                                                (_drawingAnimation.value *
                                                    (totalLength + 2)) -
                                                index;
                                            final letterDrawProgress =
                                                drawingProgress.clamp(0.0, 1.0);

                                            // Elastic bounce effect
                                            final elasticProgress =
                                                letterProgress < 0.8
                                                ? letterProgress / 0.8
                                                : 1.0 +
                                                      (letterProgress - 0.8) *
                                                          0.5;

                                            // Advanced animations
                                            final opacity =
                                                (letterProgress * 1.2).clamp(
                                                  0.0,
                                                  1.0,
                                                );
                                            final scale = elasticProgress > 1.0
                                                ? (2.0 - elasticProgress).clamp(
                                                    0.8,
                                                    1.0,
                                                  )
                                                : (elasticProgress * 0.5 + 0.5)
                                                      .clamp(0.0, 1.0);
                                            final slideOffset =
                                                -(1.0 - letterProgress) *
                                                35; // From top
                                            final rotation =
                                                (1.0 - letterProgress) * 0.15;

                                            // Prepare character with ZWJ for Arabic letters
                                            String displayChar = appName[index];
                                            if (_isArabicLetter(displayChar)) {
                                              // Add ZWJ before current letter only if previous letter connects
                                              if (index > 0) {
                                                final prevChar =
                                                    appName[index - 1];
                                                if (_isArabicLetter(prevChar) &&
                                                    !_isNonConnecting(
                                                      prevChar,
                                                    )) {
                                                  displayChar =
                                                      '\u200D$displayChar';
                                                }
                                              }
                                              // Add ZWJ after current letter if it connects and next is Arabic
                                              if (index < totalLength - 1 &&
                                                  !_isNonConnecting(
                                                    displayChar,
                                                  )) {
                                                final nextChar =
                                                    appName[index + 1];
                                                if (_isArabicLetter(nextChar)) {
                                                  displayChar =
                                                      '$displayChar\u200D';
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
                                                      clipper: DrawingClipper(
                                                        progress:
                                                            letterDrawProgress,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          // Stroke effect - outline
                                                          if (letterDrawProgress <
                                                              1.0)
                                                            Text(
                                                              displayChar,
                                                              style:
                                                                  AppTextStyle.getBoldStyle(
                                                                    color: Colors
                                                                        .transparent,
                                                                    fontSize:
                                                                        72.sp,
                                                                  ).copyWith(
                                                                    letterSpacing:
                                                                        0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    height:
                                                                        1.15,
                                                                    foreground: Paint()
                                                                      ..style =
                                                                          PaintingStyle
                                                                              .stroke
                                                                      ..strokeWidth =
                                                                          2.5
                                                                      ..color = Colors.white.withValues(
                                                                        alpha:
                                                                            (1.0 -
                                                                                    letterDrawProgress *
                                                                                        0.5)
                                                                                .clamp(
                                                                                  0.5,
                                                                                  1.0,
                                                                                ),
                                                                      ),
                                                                  ),
                                                            ),
                                                          // Fill effect
                                                          Text(
                                                            displayChar,
                                                            style:
                                                                AppTextStyle.getBoldStyle(
                                                                  color: Colors.white.withValues(
                                                                    alpha:
                                                                        (letterDrawProgress *
                                                                                    0.7 +
                                                                                0.3)
                                                                            .clamp(
                                                                              0.0,
                                                                              1.0,
                                                                            ),
                                                                  ),
                                                                  fontSize:
                                                                      72.sp,
                                                                ).copyWith(
                                                                  letterSpacing:
                                                                      0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
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
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: 8.h),

                              // Second line - Express
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _textController,
                                  _shimmerController,
                                  _drawingController,
                                ]),
                                builder: (context, child) {
                                  final appName = "app_name_line2".tr();
                                  final totalLength = appName.length;

                                  return Stack(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(totalLength, (
                                            index,
                                          ) {
                                            // Calculate progress for each letter with stagger effect
                                            final rawProgress =
                                                (_textController.value *
                                                    (totalLength + 3)) -
                                                index;
                                            final letterProgress = rawProgress
                                                .clamp(0.0, 1.0);

                                            // Drawing effect progress for each letter
                                            final drawingProgress =
                                                (_drawingAnimation.value *
                                                    (totalLength + 2)) -
                                                index;
                                            final letterDrawProgress =
                                                drawingProgress.clamp(0.0, 1.0);

                                            // Elastic bounce effect
                                            final elasticProgress =
                                                letterProgress < 0.8
                                                ? letterProgress / 0.8
                                                : 1.0 +
                                                      (letterProgress - 0.8) *
                                                          0.5;

                                            // Advanced animations
                                            final opacity =
                                                (letterProgress * 1.2).clamp(
                                                  0.0,
                                                  1.0,
                                                );
                                            final scale = elasticProgress > 1.0
                                                ? (2.0 - elasticProgress).clamp(
                                                    0.8,
                                                    1.0,
                                                  )
                                                : (elasticProgress * 0.5 + 0.5)
                                                      .clamp(0.0, 1.0);
                                            final slideOffset =
                                                (1.0 - letterProgress) *
                                                35; // From bottom
                                            final rotation =
                                                (1.0 - letterProgress) * 0.15;

                                            // Prepare character with ZWJ for Arabic letters
                                            String displayChar = appName[index];
                                            if (_isArabicLetter(displayChar)) {
                                              // Add ZWJ before current letter only if previous letter connects
                                              if (index > 0) {
                                                final prevChar =
                                                    appName[index - 1];
                                                if (_isArabicLetter(prevChar) &&
                                                    !_isNonConnecting(
                                                      prevChar,
                                                    )) {
                                                  displayChar =
                                                      '\u200D$displayChar';
                                                }
                                              }
                                              // Add ZWJ after current letter if it connects and next is Arabic
                                              if (index < totalLength - 1 &&
                                                  !_isNonConnecting(
                                                    displayChar,
                                                  )) {
                                                final nextChar =
                                                    appName[index + 1];
                                                if (_isArabicLetter(nextChar)) {
                                                  displayChar =
                                                      '$displayChar\u200D';
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
                                                      clipper: DrawingClipper(
                                                        progress:
                                                            letterDrawProgress,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          // Stroke effect - outline
                                                          if (letterDrawProgress <
                                                              1.0)
                                                            Text(
                                                              displayChar,
                                                              style:
                                                                  AppTextStyle.getBoldStyle(
                                                                    color: Colors
                                                                        .transparent,
                                                                    fontSize:
                                                                        72.sp,
                                                                  ).copyWith(
                                                                    letterSpacing:
                                                                        0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    height:
                                                                        1.15,
                                                                    foreground: Paint()
                                                                      ..style =
                                                                          PaintingStyle
                                                                              .stroke
                                                                      ..strokeWidth =
                                                                          2.5
                                                                      ..color = Colors.white.withValues(
                                                                        alpha:
                                                                            (1.0 -
                                                                                    letterDrawProgress *
                                                                                        0.5)
                                                                                .clamp(
                                                                                  0.5,
                                                                                  1.0,
                                                                                ),
                                                                      ),
                                                                  ),
                                                            ),
                                                          // Fill effect
                                                          Text(
                                                            displayChar,
                                                            style:
                                                                AppTextStyle.getBoldStyle(
                                                                  color: Colors.white.withValues(
                                                                    alpha:
                                                                        (letterDrawProgress *
                                                                                    0.7 +
                                                                                0.3)
                                                                            .clamp(
                                                                              0.0,
                                                                              1.0,
                                                                            ),
                                                                  ),
                                                                  fontSize:
                                                                      72.sp,
                                                                ).copyWith(
                                                                  letterSpacing:
                                                                      0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
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
                                      ),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: 24.h),

                              // Professional decorative line
                              AnimatedBuilder(
                                animation: _textController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: (_textController.value * 1.5)
                                        .clamp(0.0, 1.0),
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
                                          stops: const [
                                            0.0,
                                            0.25,
                                            0.5,
                                            0.75,
                                            1.0,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          2.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 20.h),

                              // Delivery tagline with slide from left animation
                              SlideTransition(
                                position: _taglineSlideAnimation,
                                child: FadeTransition(
                                  opacity: _taglineFadeAnimation,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.r),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 18.w,
                                          vertical: 9.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(
                                                alpha: 0.22,
                                              ),
                                              Colors.white.withValues(
                                                alpha: 0.16,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.12,
                                              ),
                                              blurRadius: 20,
                                              offset: const Offset(0, 4),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.08,
                                              ),
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
                                                color: Colors.white.withValues(
                                                  alpha: 0.28,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    blurRadius: 6,
                                                    spreadRadius: 0.5,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.local_shipping_rounded,
                                                color: Colors.white,
                                                size: 16.sp,
                                              ),
                                            ),
                                            SizedBox(width: 9.w),
                                            Flexible(
                                              child: Text(
                                                "splash_tagline".tr(),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    AppTextStyle.getMediumStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5.sp,
                                                    ).copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                              ),
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

  // Build elegant floating particles
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
            angle: rotation * 0.0174533, // Convert to radians
            child: Opacity(
              opacity: (0.10 - (progress * 0.06)) * _glowAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: index % 2 == 0
                      ? null
                      : BorderRadius.circular(10.r),
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

// Custom clipper to reveal text from bottom to top like drawing
class DrawingClipper extends CustomClipper<Path> {
  final double progress;

  DrawingClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();
    final revealHeight = size.height * progress;

    // Reveal from bottom to top
    path.addRect(
      Rect.fromLTRB(0, size.height - revealHeight, size.width, size.height),
    );

    return path;
  }

  @override
  bool shouldReclip(DrawingClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

// Custom painter for drawing text stroke by stroke
class DrawingTextPainter extends CustomPainter {
  final String text;
  final double progress;
  final TextStyle textStyle;
  final double glowIntensity;
  final double shimmerOpacity;

  DrawingTextPainter({
    required this.text,
    required this.progress,
    required this.textStyle,
    required this.glowIntensity,
    required this.shimmerOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create text painter to get the path
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();

    // Get text as path
    final textPath = _getTextPath(textPainter);

    if (textPath == null) return;

    // Calculate the total length of the path
    final pathMetrics = textPath.computeMetrics();
    double totalLength = 0;
    final metrics = pathMetrics.toList();

    for (final metric in metrics) {
      totalLength += metric.length;
    }

    // Draw only the portion based on progress
    final drawLength = totalLength * progress;

    // Create paint with glow effect
    final paint = Paint()
      ..color = textStyle.color ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Add glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: glowIntensity + shimmerOpacity * 0.4,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    double currentLength = 0;

    for (final metric in metrics) {
      final extractLength = (drawLength - currentLength).clamp(
        0.0,
        metric.length,
      );

      if (extractLength > 0) {
        final extractPath = metric.extractPath(0, extractLength);

        // Draw glow first
        canvas.drawPath(extractPath, glowPaint);
        // Draw main stroke
        canvas.drawPath(extractPath, paint);
      }

      currentLength += metric.length;
      if (currentLength >= drawLength) break;
    }

    // Fill the completed parts
    if (progress > 0.7) {
      final fillPaint = Paint()
        ..color = (textStyle.color ?? Colors.white).withValues(
          alpha: (progress - 0.7) / 0.3,
        )
        ..style = PaintingStyle.fill;
      canvas.drawPath(textPath, fillPaint);
    }
  }

  Path? _getTextPath(TextPainter textPainter) {
    try {
      // This is a workaround - we'll use the text outline approach
      final builder =
          ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: TextAlign.left,
                fontSize: textStyle.fontSize,
                fontWeight: textStyle.fontWeight,
                fontFamily: textStyle.fontFamily,
              ),
            )
            ..pushStyle(
              ui.TextStyle(
                color: textStyle.color,
                fontSize: textStyle.fontSize,
                fontWeight: textStyle.fontWeight,
                fontFamily: textStyle.fontFamily,
              ),
            )
            ..addText(text);

      final paragraph = builder.build();
      paragraph.layout(ui.ParagraphConstraints(width: double.infinity));

      // Create a simple rectangular path as fallback
      // In production, you'd use a proper text-to-path converter
      final path = Path();
      final width = paragraph.longestLine;
      final height = paragraph.height;

      // Draw outline of text bounds
      path.addRect(Rect.fromLTWH(0, 0, width, height));

      return path;
    } catch (e) {
      return null;
    }
  }

  @override
  bool shouldRepaint(DrawingTextPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.shimmerOpacity != shimmerOpacity;
  }
}
