import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/animated_notch_navigation_bar.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/dashboard/screen/coach_dashboard_screen.dart';
import 'package:coachappmobile/features/coach/exercises/cubit/exercise_cubit.dart';
import 'package:coachappmobile/features/coach/foods/cubit/food_cubit.dart';
import 'package:coachappmobile/features/coach/library/library_screen.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/cubit/nutrition_plan_cubit.dart';
import 'package:coachappmobile/features/coach/plans/plans_screen.dart';
import 'package:coachappmobile/features/coach/trainees/cubit/trainee_cubit.dart';
import 'package:coachappmobile/features/coach/trainees/screen/trainees_list_screen.dart';
import 'package:coachappmobile/features/coach/workout_plans/cubit/workout_plan_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/shell_account_screen.dart';
import 'widgets/shell_tab.dart';

/// Coach role home shell.
///
/// A bottom navigation bar over an [IndexedStack] so every tab keeps its own
/// scroll position and state while the coach switches between them. The visible
/// tabs are computed once from the coach's granted permissions (see
/// [_buildTabs]); a tab the coach can't access is skipped. "More" is always
/// present and hosts profile / settings / logout, so the bar is never empty.
///
// TODO(later): give each tab its own nested Navigator so pushes stay within the
// tab. IndexedStack alone preserves tab state, which is enough for this phase.
class CoachShell extends StatefulWidget {
  const CoachShell({super.key});

  @override
  State<CoachShell> createState() => _CoachShellState();
}

class _CoachShellState extends State<CoachShell> {
  late final List<ShellTab> _tabs;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabs = _buildTabs(context.read<SessionCubit>());
  }

  /// Build the visible tab list from granted permissions. A tab the coach can't
  /// access is skipped; if that leaves no content tab we still show Dashboard so
  /// the bar is never reduced to just "More".
  List<ShellTab> _buildTabs(SessionCubit session) {
    final tabs = <ShellTab>[];

    // Dashboard — coach overview / quick-access landing.
    if (session.can(CoachPermissions.tracking)) {
      tabs.add(_buildDashboardTab());
    }

    // Trainees list.
    if (session.can(CoachPermissions.trainees)) {
      tabs.add(
        ShellTab(
          labelKey: 'tab_trainees',
          activeIcon: Icons.people,
          inactiveIcon: Icons.people_outline,
          body: BlocProvider(
            create: (_) => getIt<TraineeCubit>(),
            child: const TraineesListScreen(),
          ),
        ),
      );
    }

    // Library — exercises and foods.
    if (session.can(CoachPermissions.exercises) ||
        session.can(CoachPermissions.foods)) {
      tabs.add(
        ShellTab(
          labelKey: 'tab_library',
          activeIcon: Icons.menu_book,
          inactiveIcon: Icons.menu_book_outlined,
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<ExerciseCubit>()),
              BlocProvider(create: (_) => getIt<FoodCubit>()),
            ],
            child: const LibraryScreen(),
          ),
        ),
      );
    }

    // Plans — a segmented host over the Workout and Nutrition plan lists, each
    // gated by its own permission (templates land in later phases).
    final canWorkoutPlans = session.can(CoachPermissions.workoutPlans);
    final canNutritionPlans = session.can(CoachPermissions.nutritionPlans);
    if (canWorkoutPlans ||
        canNutritionPlans ||
        session.can(CoachPermissions.workoutPlanTemplates) ||
        session.can(CoachPermissions.nutritionPlanTemplates)) {
      // With plan perms: the full segmented plan lists (cubits provided here).
      // Templates-only (no plan perms but a template perm): render PlansScreen
      // collapsed — it surfaces an "Open Templates" entry instead of a dead
      // placeholder (F6). No plan cubits are needed since no plan list renders.
      final Widget plansBody = (canWorkoutPlans || canNutritionPlans)
          ? MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<WorkoutPlanCubit>()),
                BlocProvider(create: (_) => getIt<NutritionPlanCubit>()),
              ],
              child: PlansScreen(
                showWorkout: canWorkoutPlans,
                showNutrition: canNutritionPlans,
              ),
            )
          : const PlansScreen(showWorkout: false, showNutrition: false);
      tabs.add(
        ShellTab(
          labelKey: 'tab_plans',
          activeIcon: Icons.assignment,
          inactiveIcon: Icons.assignment_outlined,
          body: plansBody,
        ),
      );
    }

    // Guarantee at least one content tab even for a permission-less coach.
    if (tabs.isEmpty) {
      tabs.add(_buildDashboardTab());
    }

    // More — always present; holds profile / settings / logout.
    tabs.add(
      const ShellTab(
        labelKey: 'tab_more',
        activeIcon: Icons.more_horiz,
        inactiveIcon: Icons.more_horiz,
        body: ShellAccountScreen(titleKey: 'tab_more'),
      ),
    );

    return tabs;
  }

  /// Switch to the tab whose [ShellTab.labelKey] matches — used by the coach
  /// dashboard's quick-access cards to jump into a sibling tab.
  void _openTabByLabel(String labelKey) {
    final i = _tabs.indexWhere((t) => t.labelKey == labelKey);
    if (i >= 0 && mounted) setState(() => _index = i);
  }

  ShellTab _buildDashboardTab() => ShellTab(
    labelKey: 'tab_dashboard',
    activeIcon: Icons.dashboard,
    inactiveIcon: Icons.dashboard_outlined,
    body: CoachDashboardScreen(onOpenTab: _openTabByLabel),
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
