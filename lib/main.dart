import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/classes/cashe_helper.dart';
import 'core/classes/keys.dart';
import 'core/classes/session_guard.dart';
import 'core/constant/app_theme/app_theme.dart';
import 'core/constant/app_theme/shad_theme.dart';
import 'core/constant/end_points/api_url.dart';
import 'core/di/injection.dart';
import 'core/ui/screens/splash_screen.dart';
import 'features/auth/cubit/session_cubit.dart';
import 'features/auth/screen/login_screen.dart';
import 'features/auth/screen/post_login_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast if a RELEASE build wasn't given a real (non-loopback, HTTPS) API
  // host, so a production build can never silently target the dev server.
  if (kReleaseMode && isInsecureReleaseBaseUrl(baseUrl)) {
    throw StateError(
      'Insecure API_BASE_URL for a release build: "$baseUrl". '
      'Pass --dart-define=API_BASE_URL=https://<prod-host>/ for release builds.',
    );
  }
  // Disable all debugPrint output in release so no request/token/PII data can
  // reach logcat/console in production.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Localization + local storage + DI must be ready before the first frame.
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();
  await setUp();

  // A mid-session 401 (a token the client still believed valid) invalidates the
  // session and routes back to login. Idempotent for concurrent 401s.
  SessionGuard.onUnauthorized = () => getIt<SessionCubit>().forceInvalidate();

  // NOTE: Firebase is intentionally NOT initialized yet — firebase_options.dart
  // still holds the JasimExpress project and there is no CoachApp
  // google-services.json / iOS plist. Wire Firebase.initializeApp() here once
  // `flutterfire configure` has been run for CoachApp (cleanup item #7).

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      // RTL-first: Arabic is the default and fallback language.
      fallbackLocale: const Locale('ar'),
      startLocale: Locale(CacheHelper.lang == 'en' ? 'en' : 'ar'),
      child: const CoachApp(),
    ),
  );
}

class CoachApp extends StatelessWidget {
  const CoachApp({super.key});

  ThemeMode get _themeMode =>
      CacheHelper.theme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // App-level cubits live above MaterialApp so every pushed route can
        // read them. SessionCubit is the auth/session holder (Phase 1).
        return MultiBlocProvider(
          providers: [
            BlocProvider<SessionCubit>(create: (_) => getIt<SessionCubit>()),
          ],
          // ShadApp provides the ShadTheme (+ ShadToaster) that the modern
          // components depend on: AppButton is backed by ShadButton and Dialogs
          // by ShadToaster, both of which require these ancestors. `.custom`
          // keeps the existing MaterialApp — with its EasyLocalization
          // delegates, navigatorKey and Material theme — intact underneath.
          child: ShadApp.custom(
            theme: buildShadLightTheme(),
            darkTheme: buildShadDarkTheme(),
            themeMode: _themeMode,
            appBuilder: (context) {
              return MaterialApp(
                title: 'CoachApp',
                debugShowCheckedModeBanner: false,
                navigatorKey: Keys.navigatorKey,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: appThemeData[AppTheme.light],
                darkTheme: appThemeData[AppTheme.dark],
                themeMode: _themeMode,
                // Provide the shadcn toaster above the Navigator so Dialogs
                // (used by the CreateModel boilerplate) can surface toasts.
                builder: (context, child) =>
                    ShadToaster(child: child ?? const SizedBox.shrink()),
                // Splash routes from the cached session: to the role gate when
                // a token exists, otherwise to login.
                home: const SplashScreen(
                  login: LoginScreen(),
                  home: PostLoginRouter(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
