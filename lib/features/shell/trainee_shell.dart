import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/animated_notch_navigation_bar.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/shell_account_screen.dart';
import 'widgets/shell_placeholder_screen.dart';
import 'widgets/shell_tab.dart';

/// Trainee (self-service) role home shell.
///
/// Same pattern as [CoachShell]: a bottom navigation bar over an [IndexedStack]
/// so each tab keeps its own state. Tabs are built from the trainee's granted
/// permissions; "Profile" is always present and hosts the profile view +
/// logout, so the bar is never empty.
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

    // Today — the trainee's daily home.
    // TODO(Phase 13): replace with the real "My Today" screen.
    if (session.can(TraineePermissions.myToday)) {
      tabs.add(_todayTab);
    }

    // Workout — assigned workout plans.
    // TODO(Phase 14): replace with the real "My Workout Plans" screen.
    if (session.can(TraineePermissions.myWorkoutPlans)) {
      tabs.add(
        const ShellTab(
          labelKey: 'tab_workout',
          activeIcon: Icons.fitness_center,
          inactiveIcon: Icons.fitness_center_outlined,
          body: ShellPlaceholderScreen(
            titleKey: 'tab_workout',
            icon: Icons.fitness_center_outlined,
          ),
        ),
      );
    }

    // Nutrition — assigned nutrition plans.
    // TODO(Phase 15): replace with the real "My Nutrition Plans" screen.
    if (session.can(TraineePermissions.myNutritionPlans)) {
      tabs.add(
        const ShellTab(
          labelKey: 'tab_nutrition',
          activeIcon: Icons.restaurant,
          inactiveIcon: Icons.restaurant_outlined,
          body: ShellPlaceholderScreen(
            titleKey: 'tab_nutrition',
            icon: Icons.restaurant_outlined,
          ),
        ),
      );
    }

    // Progress — progress entries and/or personal dashboard.
    // TODO(Phase 16): replace with the real "My Progress" screen.
    if (session.can(TraineePermissions.myProgress) ||
        session.can(TraineePermissions.myDashboard)) {
      tabs.add(
        const ShellTab(
          labelKey: 'tab_progress',
          activeIcon: Icons.insights,
          inactiveIcon: Icons.insights_outlined,
          body: ShellPlaceholderScreen(
            titleKey: 'tab_progress',
            icon: Icons.insights_outlined,
          ),
        ),
      );
    }

    // Guarantee at least one content tab even for a permission-less trainee.
    if (tabs.isEmpty) {
      tabs.add(_todayTab);
    }

    // Profile — always present; holds the profile view + logout.
    tabs.add(
      const ShellTab(
        labelKey: 'tab_profile',
        activeIcon: Icons.person,
        inactiveIcon: Icons.person_outline,
        body: ShellAccountScreen(titleKey: 'tab_profile'),
      ),
    );

    return tabs;
  }

  static const ShellTab _todayTab = ShellTab(
    labelKey: 'tab_today',
    activeIcon: Icons.today,
    inactiveIcon: Icons.today_outlined,
    body: ShellPlaceholderScreen(
      titleKey: 'tab_today',
      icon: Icons.today_outlined,
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
