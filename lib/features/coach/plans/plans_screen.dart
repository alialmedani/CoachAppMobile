import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/apex/apex_segmented.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/nutrition_plans_list_screen.dart';
import 'package:coachappmobile/features/coach/templates/templates_screen.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/workout_plans_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coach "Plans" tab: a segmented host over the Workout and Nutrition plan
/// lists (mirrors the Library tab's Exercises|Foods segmented host). Each
/// segment is gated by its permission via [showWorkout] / [showNutrition]; the
/// feature cubits are provided by the shell above this screen. When only one
/// segment is available the control collapses to that single list.
///
/// When the coach has **no** plan permissions but does have a template
/// permission, both [showWorkout] and [showNutrition] are false — the screen
/// renders an "Open Templates" entry instead of a dead placeholder (F6) so the
/// Templates screen stays reachable (its app-bar action alone is not enough).
class PlansScreen extends StatefulWidget {
  final bool showWorkout;
  final bool showNutrition;

  const PlansScreen({
    super.key,
    required this.showWorkout,
    required this.showNutrition,
  });

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _index = 0;

  void _openTemplates() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final segments = <_PlanSegment>[
      if (widget.showWorkout)
        _PlanSegment(
          labelKey: 'workout_plans',
          builder: (host) =>
              WorkoutPlansListScreen(embedded: true, hostHeaderSlivers: host),
        ),
      if (widget.showNutrition)
        _PlanSegment(
          labelKey: 'nutrition_plans',
          builder: (host) =>
              NutritionPlansListScreen(embedded: true, hostHeaderSlivers: host),
        ),
    ];
    final safeIndex = segments.isEmpty
        ? 0
        : _index.clamp(0, segments.length - 1);

    // Templates entry point: shown only when the coach can access at least one
    // of the template libraries. Pushes the standalone Templates host (which
    // provides its own template cubits and gates its own segments).
    final session = context.read<SessionCubit>();
    final canTemplates =
        session.can(CoachPermissions.workoutPlanTemplates) ||
        session.can(CoachPermissions.nutritionPlanTemplates);
    final templatesActions = canTemplates
        ? <Widget>[
            IconButton(
              icon: const Icon(Icons.bookmarks_outlined),
              tooltip: 'templates'.tr(),
              onPressed: _openTemplates,
            ),
          ]
        : null;

    // Templates-only coach (no plan permissions): a single scrolling screen
    // with the "Plans" bar and an "Open Templates" call to action.
    if (segments.isEmpty) {
      return Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppSliverTopBar(title: 'plans'.tr(), actions: templatesActions),
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.bookmarks_outlined,
                title: 'plan_templates_only_title'.tr(),
                subtitle: 'plan_templates_only_subtitle'.tr(),
                iconColor: AppDesignSystem.primaryColor,
                action: AppButton(
                  text: 'open_templates'.tr(),
                  icon: Icons.bookmarks_outlined,
                  onPressed: _openTemplates,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // The shared "Plans" app bar + segmented control, built fresh per segment so
    // each IndexedStack child owns its own instances. They live at the top of
    // the selected segment's scroll view, so they scroll away with the list.
    List<Widget> sharedHeaderSlivers() => [
      AppSliverTopBar(title: 'plans'.tr(), actions: templatesActions),
      if (segments.length > 1)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              0,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
            ),
            child: ApexSegmented(
              labels: [for (final s in segments) s.labelKey.tr()],
              index: safeIndex,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      body: IndexedStack(
        index: safeIndex,
        children: [for (final s in segments) s.builder(sharedHeaderSlivers())],
      ),
    );
  }
}

class _PlanSegment {
  final String labelKey;
  final Widget Function(List<Widget> hostHeaderSlivers) builder;

  const _PlanSegment({required this.labelKey, required this.builder});
}
