import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/exercises/screen/exercises_list_screen.dart';
import 'package:coachappmobile/features/coach/foods/screen/foods_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Coach "Library" tab: a segmented host over the Exercises and Foods lists.
/// The two feature cubits are provided by the shell above this screen.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Shared "Library" app bar + segmented control, built fresh per segment so
    // each IndexedStack child owns its own instances. They sit at the top of the
    // selected segment's scroll view, so they scroll away with the list.
    List<Widget> sharedHeaderSlivers() => [
      AppSliverTopBar(title: 'library'.tr()),
      SliverToBoxAdapter(
        child: Container(
          color: AppDesignSystem.surfaceWhite,
          padding: EdgeInsets.fromLTRB(
            AppDesignSystem.spacingMD.w,
            0,
            AppDesignSystem.spacingMD.w,
            AppDesignSystem.spacingSM.h,
          ),
          child: _Segmented(
            index: _index,
            onChanged: (i) => setState(() => _index = i),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      body: IndexedStack(
        index: _index,
        children: [
          ExercisesListScreen(hostHeaderSlivers: sharedHeaderSlivers()),
          FoodsListScreen(hostHeaderSlivers: sharedHeaderSlivers()),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _Segmented({required this.index, required this.onChanged});

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
          _seg(0, 'exercises'.tr(), Icons.fitness_center),
          _seg(1, 'foods'.tr(), Icons.restaurant_outlined),
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
              Text(
                label,
                style: AppDesignSystem.labelMedium.copyWith(
                  color: selected
                      ? AppDesignSystem.primaryColor
                      : AppDesignSystem.neutral500,
                  fontWeight: AppDesignSystem.semiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
