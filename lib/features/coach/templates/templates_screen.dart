import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plan_templates/cubit/nutrition_plan_template_cubit.dart';
import 'package:coachappmobile/features/coach/nutrition_plan_templates/screen/nutrition_plan_templates_list_screen.dart';
import 'package:coachappmobile/features/coach/workout_plan_templates/cubit/workout_plan_template_cubit.dart';
import 'package:coachappmobile/features/coach/workout_plan_templates/screen/workout_plan_templates_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coach "Templates" screen: a segmented host over the Workout and Nutrition
/// plan-template lists (mirrors the Plans tab's segmented host). Pushed as a
/// full screen from the Plans tab's app-bar action, so it owns its own top bar
/// with a back button. Each segment is gated by its template permission; when
/// only one is granted the control collapses to that single list.
///
/// The feature cubits are provided here (both, unconditionally and lazily —
/// mirroring how the coach shell provides both plan cubits for the Plans tab),
/// so the nested list screens can `context.read` them.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>();
    final showWorkout = session.can(CoachPermissions.workoutPlanTemplates);
    final showNutrition = session.can(CoachPermissions.nutritionPlanTemplates);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<WorkoutPlanTemplateCubit>()),
        BlocProvider(create: (_) => getIt<NutritionPlanTemplateCubit>()),
      ],
      child: _TemplatesHost(
        showWorkout: showWorkout,
        showNutrition: showNutrition,
      ),
    );
  }
}

class _TemplatesHost extends StatefulWidget {
  final bool showWorkout;
  final bool showNutrition;

  const _TemplatesHost({
    required this.showWorkout,
    required this.showNutrition,
  });

  @override
  State<_TemplatesHost> createState() => _TemplatesHostState();
}

class _TemplatesHostState extends State<_TemplatesHost> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final segments = <_TemplateSegment>[
      if (widget.showWorkout)
        _TemplateSegment(
          labelKey: 'workout_templates',
          icon: Icons.fitness_center,
          screen: const WorkoutPlanTemplatesListScreen(embedded: true),
        ),
      if (widget.showNutrition)
        _TemplateSegment(
          labelKey: 'nutrition_templates',
          icon: Icons.restaurant_menu_outlined,
          screen: const NutritionPlanTemplatesListScreen(embedded: true),
        ),
    ];
    final safeIndex = segments.isEmpty ? 0 : _index.clamp(0, segments.length - 1);

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'templates'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (segments.length > 1)
            Container(
              color: AppDesignSystem.surfaceWhite,
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                0,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
              ),
              child: _Segmented(
                segments: segments,
                index: safeIndex,
                onChanged: (i) => setState(() => _index = i),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: [for (final s in segments) s.screen],
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateSegment {
  final String labelKey;
  final IconData icon;
  final Widget screen;

  const _TemplateSegment({
    required this.labelKey,
    required this.icon,
    required this.screen,
  });
}

class _Segmented extends StatelessWidget {
  final List<_TemplateSegment> segments;
  final int index;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.segments,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacing2XS.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral100,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            _seg(i, segments[i].labelKey.tr(), segments[i].icon),
        ],
      ),
    );
  }

  Widget _seg(int i, String label, IconData icon) {
    final selected = index == i;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: AppDesignSystem.durationFast,
          padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
          decoration: BoxDecoration(
            color: selected ? AppDesignSystem.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
            boxShadow: selected ? AppDesignSystem.shadowSM : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDesignSystem.iconSizeXS.sp,
                color: selected
                    ? AppDesignSystem.primaryColor
                    : AppDesignSystem.neutral500,
              ),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: selected
                        ? AppDesignSystem.primaryColor
                        : AppDesignSystem.neutral500,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
