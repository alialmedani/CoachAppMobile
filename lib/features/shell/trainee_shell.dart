import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/animated_notch_navigation_bar.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/trainee/my_nutrition_plans/cubit/my_nutrition_plan_cubit.dart';
import 'package:coachappmobile/features/trainee/my_nutrition_plans/screen/my_nutrition_plans_screen.dart';
import 'package:coachappmobile/features/trainee/my_workout_plans/cubit/my_workout_plan_cubit.dart';
import 'package:coachappmobile/features/trainee/my_workout_plans/screen/my_workout_plans_screen.dart';
import 'package:coachappmobile/features/trainee/my_dashboard/cubit/my_dashboard_cubit.dart';
import 'package:coachappmobile/features/trainee/my_profile/cubit/my_profile_cubit.dart';
import 'package:coachappmobile/features/trainee/my_profile/screen/my_profile_screen.dart';
import 'package:coachappmobile/features/trainee/my_progress/cubit/my_progress_cubit.dart';
import 'package:coachappmobile/features/trainee/my_progress/screen/my_progress_screen.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/cubit/nutrition_log_cubit.dart';
import 'package:coachappmobile/features/trainee/today/cubit/my_today_cubit.dart';
import 'package:coachappmobile/features/trainee/today/screen/today_screen.dart';
import 'package:coachappmobile/features/trainee/workout_logs/cubit/workout_log_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/shell_account_screen.dart';
import 'widgets/shell_tab.dart';

/// Trainee (self-service) role home shell.
///
/// Same pattern as [CoachShell]: a bottom navigation bar over an [IndexedStack]
/// so each tab keeps its own state. Tabs are built from the trainee's granted
/// permissions; each content tab provides its own feature cubit via
/// `BlocProvider(create:)`. "Profile" is always present and hosts the profile
/// view + logout, so the bar is never empty.
///
// TODO(later): give each tab its own nested Navigator for deep push stacks.
class TraineeShell extends StatefulWidget {
  const TraineeShell({super.key});

  @override
  State<TraineeShell> createState() => _TraineeShellState();
}

class _TraineeShellState extends State<TraineeShell> {
  late final List<ShellTab> _tabs;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs(context.read<SessionCubit>());
  }

  /// Build the visible tab list from granted permissions. A tab the trainee
  /// can't access is skipped; if that leaves no content tab we still show Today
  /// so the bar is never reduced to just "Profile".
  List<ShellTab> _buildTabs(SessionCubit session) {
    final tabs = <ShellTab>[];

    // Today — the trainee's daily home (Phase 13).
    if (session.can(TraineePermissions.myToday)) {
      tabs.add(_todayTab());
    }

    // Workout — assigned workout plans (Phase 12).
    if (session.can(TraineePermissions.myWorkoutPlans)) {
      tabs.add(
        ShellTab(
          labelKey: 'tab_workout',
          activeIcon: Icons.fitness_center,
          inactiveIcon: Icons.fitness_center_outlined,
          body: BlocProvider(
            create: (_) => getIt<MyWorkoutPlanCubit>(),
            child: const MyWorkoutPlansScreen(),
          ),
        ),
      );
    }

    // Nutrition — assigned nutrition plans (Phase 12).
    if (session.can(TraineePermissions.myNutritionPlans)) {
      tabs.add(
        ShellTab(
          labelKey: 'tab_nutrition',
          activeIcon: Icons.restaurant,
          inactiveIcon: Icons.restaurant_outlined,
          body: BlocProvider(
            create: (_) => getIt<MyNutritionPlanCubit>(),
            child: const MyNutritionPlansScreen(),
          ),
        ),
      );
    }

    // Progress — the trainee's own dashboard + progress entries (Phase 16).
    if (session.can(TraineePermissions.myProgress) ||
        session.can(TraineePermissions.myDashboard)) {
      tabs.add(
        ShellTab(
          labelKey: 'tab_progress',
          activeIcon: Icons.insights,
          inactiveIcon: Icons.insights_outlined,
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<MyProgressCubit>()),
              BlocProvider(create: (_) => getIt<MyDashboardCubit>()),
            ],
            child: const MyProgressScreen(),
          ),
        ),
      );
    }

    // Guarantee at least one content tab even for a permission-less trainee.
    if (tabs.isEmpty) {
      tabs.add(_todayTab());
    }

    // Profile — always present; the trainee's own profile + notes / change
    // password / logout (Phase 16). Falls back to the shared account screen if
    // the trainee somehow lacks the MyProfile permission.
    tabs.add(
      session.can(TraineePermissions.myProfile)
          ? ShellTab(
              labelKey: 'tab_profile',
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outline,
              // Profile also surfaces the derived current weight + a quick
              // "record today's weight" action, both backed by MyProgressCubit.
              body: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<MyProfileCubit>()),
                  BlocProvider(create: (_) => getIt<MyProgressCubit>()),
                ],
                child: const MyProfileScreen(),
              ),
            )
          : const ShellTab(
              labelKey: 'tab_profile',
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outline,
              body: ShellAccountScreen(titleKey: 'tab_profile'),
            ),
    );

    return tabs;
  }

  ShellTab _todayTab() => ShellTab(
    labelKey: 'tab_today',
    activeIcon: Icons.today,
    inactiveIcon: Icons.today_outlined,
    // Today also drives the log flows, so it provides the log cubits alongside
    // MyTodayCubit (Phases 14–15).
    body: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<MyTodayCubit>()),
        BlocProvider(create: (_) => getIt<WorkoutLogCubit>()),
        BlocProvider(create: (_) => getIt<NutritionLogCubit>()),
      ],
      child: const TodayScreen(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final safeIndex = _index.clamp(0, _tabs.length - 1);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      body: IndexedStack(
        index: safeIndex,
        children: [for (final tab in _tabs) tab.body],
      ),
      bottomNavigationBar: AnimatedNotchNavigationBar(
        currentIndex: safeIndex,
        selectedColor: AppDesignSystem.primaryColor,
        unselectedColor: AppDesignSystem.neutral400,
        backgroundColor: AppDesignSystem.surfaceWhite,
        onTap: (i) => setState(() => _index = i),
        items: [
          for (final tab in _tabs)
            NavigationBarItemConfig(
              activeIcon: tab.activeIcon,
              inactiveIcon: tab.inactiveIcon,
              label: tab.labelKey,
            ),
        ],
      ),
    );
  }
}
