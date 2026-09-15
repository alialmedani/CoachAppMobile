import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/coach_dashboard_cubit.dart';
import '../data/model/trainee_dashboard_model.dart';
import '../widgets/dashboard_cards.dart';

/// Coach dashboard for one trainee: nutrition adherence for the anchor day
/// (today) plus range aggregates (weekly/28-day nutrition adherence + workout
/// completion), read-only. A range selector (Today / This week / Last 28 days)
/// lets the coach pick the window; changing it re-fetches (F5/PD5).
class CoachDashboardScreen extends StatefulWidget {
  final String traineeId;
  final String? traineeName;

  const CoachDashboardScreen({
    super.key,
    required this.traineeId,
    this.traineeName,
  });

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoachDashboardCubit>()
      ..setTrainee(widget.traineeId);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(
        title: 'coach_dashboard'.tr(),
        subtitle: widget.traineeName,
      ),
      body: Column(
        children: [
          Container(
            color: AppDesignSystem.surfaceWhite,
            padding: EdgeInsets.fromLTRB(
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
              AppDesignSystem.spacingMD.w,
              AppDesignSystem.spacingSM.h,
            ),
            child: _RangeSelector(
              selected: cubit.range,
              onChanged: (value) {
                if (value == cubit.range) return;
                setState(() => cubit.setRange(value));
              },
            ),
          ),
          Expanded(
            child: GetModel<TraineeDashboardModel>(
              // Re-fetch when the window changes: a key derived from the
              // selected range rebuilds GetModel and re-runs the use case.
              key: ValueKey(cubit.range),
              useCaseCallBack: () => cubit.fetchSummary(),
              modelBuilder: (d) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardCards(
                      adherence: d.nutritionAdherence,
                      // The single-day card is the anchor day; hide the range
                      // card when the window is a single day (redundant).
                      range: cubit.range == CoachDashboardRange.today
                          ? null
                          : d.nutritionAdherenceRange,
                      completion: d.workoutCompletion,
                      showNotLoggedState: true,
                    ),
                    SizedBox(height: AppDesignSystem.spacingXL.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented window picker for the dashboard adherence range.
class _RangeSelector extends StatelessWidget {
  final CoachDashboardRange selected;
  final ValueChanged<CoachDashboardRange> onChanged;

  const _RangeSelector({required this.selected, required this.onChanged});

  static const _options = <CoachDashboardRange, String>{
    CoachDashboardRange.today: 'range_today',
    CoachDashboardRange.thisWeek: 'range_this_week',
    CoachDashboardRange.last28Days: 'range_last_28_days',
  };

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
          for (final entry in _options.entries)
            _seg(entry.key, entry.value.tr()),
        ],
      ),
    );
  }

  Widget _seg(CoachDashboardRange value, String label) {
    final isSelected = value == selected;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: AppDesignSystem.durationFast,
          padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppDesignSystem.surfaceWhite
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
            boxShadow: isSelected ? AppDesignSystem.shadowSM : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppDesignSystem.labelMedium.copyWith(
              color: isSelected
                  ? AppDesignSystem.primaryColor
                  : AppDesignSystem.neutral500,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}
