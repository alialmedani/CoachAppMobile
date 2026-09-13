import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/nutrition_plans/screen/nutrition_plans_list_screen.dart';
import 'package:coachappmobile/features/coach/workout_plans/screen/workout_plans_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coach "Plans" tab: a segmented host over the Workout and Nutrition plan
/// lists (mirrors the Library tab's Exercises|Foods segmented host). Each
/// segment is gated by its permission via [showWorkout] / [showNutrition]; the
/// feature cubits are provided by the shell above this screen. When only one
/// segment is available the control collapses to that single list.
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

  @override
  Widget build(BuildContext context) {
    final segments = <_PlanSegment>[
      if (widget.showWorkout)
        _PlanSegment(
          labelKey: 'workout_plans',
          icon: Icons.fitness_center,
          screen: const WorkoutPlansListScreen(embedded: true),
        ),
      if (widget.showNutrition)
        _PlanSegment(
          labelKey: 'nutrition_plans',
          icon: Icons.restaurant_menu_outlined,
          screen: const NutritionPlansListScreen(embedded: true),
        ),
    ];
    final safeIndex = _index.clamp(0, segments.length - 1);

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'plans'.tr()),
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

class _PlanSegment {
  final String labelKey;
  final IconData icon;
  final Widget screen;

  const _PlanSegment({
    required this.labelKey,
    required this.icon,
    required this.screen,
  });
}

class _Segmented extends StatelessWidget {
  final List<_PlanSegment> segments;
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
