import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/apex/control_bar_nav.dart';
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
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/shell_account_screen.dart';
import 'widgets/shell_tab.dart';

/// Coach role home shell.
///
/// The Apex [ControlBarNav] (chamfered floating bar + raised Volt center action)
/// over an [IndexedStack], on the ink canvas — matching [TraineeShell]. The
/// visible tabs are computed once from the coach's granted permissions (see
/// [_buildTabs]); a tab the coach can't access is skipped. "More" is always
/// present and hosts profile / settings / logout, so the bar is never empty.
/// The raised center action is the Dashboard (the coach's home base), mirroring
/// how Today anchors the trainee bar.
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
          navIcon: AppIcons.roster,
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
          navIcon: AppIcons.library,
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
          navIcon: AppIcons.plans,
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
        navIcon: AppIcons.profile,
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
    navIcon: AppIcons.gauge,
    // The Command Center previews the live roster, so it provides its own
    // TraineeCubit (a separate instance from the Trainees tab).
    body: BlocProvider(
      create: (_) => getIt<TraineeCubit>(),
      child: CoachDashboardScreen(onOpenTab: _openTabByLabel),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final safeIndex = _index.clamp(0, _tabs.length - 1);
    // Dashboard is the raised center "home base" action; fall back to the first
    // tab if a permission-less coach has no Dashboard tab.
    final dashboardIndex =
        _tabs.indexWhere((t) => t.labelKey == 'tab_dashboard');
    final primaryIndex = dashboardIndex < 0 ? 0 : dashboardIndex;
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      body: IndexedStack(
        index: safeIndex,
        children: [for (final tab in _tabs) tab.body],
      ),
      bottomNavigationBar: ControlBarNav(
        currentIndex: safeIndex,
        primaryIndex: primaryIndex,
        centerIcon: AppIcons.gauge,
        onTap: (i) => setState(() => _index = i),
        items: [
          for (final tab in _tabs)
            ControlBarItem(
              iconAsset: tab.navIcon ?? AppIcons.roster,
              label: tab.labelKey.tr(),
            ),
        ],
      ),
    );
  }
}
