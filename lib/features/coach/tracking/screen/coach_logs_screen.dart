import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/coach_log_cubit.dart';
import 'coach_nutrition_log_detail_screen.dart';
import 'coach_workout_log_detail_screen.dart';

/// Coach view of a trainee's logs, segmented Workout / Nutrition. List rows are
/// headers (date only — the backend omits entries from the list); tapping opens
/// the enriched detail.
class CoachLogsScreen extends StatefulWidget {
  final String traineeId;
  final String? traineeName;

  const CoachLogsScreen({super.key, required this.traineeId, this.traineeName});

  @override
  State<CoachLogsScreen> createState() => _CoachLogsScreenState();
}

class _CoachLogsScreenState extends State<CoachLogsScreen> {
  int _index = 0; // 0 = workout, 1 = nutrition

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoachLogCubit>()..setTrainee(widget.traineeId);
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'logs'.tr(), subtitle: widget.traineeName),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
            child: _Segmented(
              labels: ['tab_workout'.tr(), 'tab_nutrition'.tr()],
              icons: const [Icons.fitness_center, Icons.restaurant],
              index: _index,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
          Expanded(
            child: _index == 0
                ? _WorkoutLogList(cubit: cubit, fmtDate: _fmtDate)
                : _NutritionLogList(cubit: cubit, fmtDate: _fmtDate),
          ),
        ],
      ),
    );
  }
}

class _WorkoutLogList extends StatelessWidget {
  final CoachLogCubit cubit;
  final String Function(DateTime?) fmtDate;

  const _WorkoutLogList({required this.cubit, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    return GetModel<List<WorkoutLogModel>>(
      useCaseCallBack: () => cubit.fetchWorkoutLogs(),
      modelBuilder: (logs) => logs.isEmpty
          ? _empty('no_workout_logs'.tr())
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                0,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacing4XL.h,
              ),
              itemCount: logs.length,
              itemBuilder: (context, i) => _LogRow(
                icon: Icons.fitness_center,
                date: fmtDate(logs[i].date),
                notes: logs[i].notes,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: CoachWorkoutLogDetailScreen(
                        logId: logs[i].id ?? '',
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _NutritionLogList extends StatelessWidget {
  final CoachLogCubit cubit;
  final String Function(DateTime?) fmtDate;

  const _NutritionLogList({required this.cubit, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    return GetModel<List<NutritionLogModel>>(
      useCaseCallBack: () => cubit.fetchNutritionLogs(),
      modelBuilder: (logs) => logs.isEmpty
          ? _empty('no_nutrition_logs'.tr())
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                0,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacing4XL.h,
              ),
              itemCount: logs.length,
              itemBuilder: (context, i) => _LogRow(
                icon: Icons.restaurant,
                date: fmtDate(logs[i].date),
                notes: logs[i].notes,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: CoachNutritionLogDetailScreen(
                        logId: logs[i].id ?? '',
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Inline segmented toggle (mirrors the Plans/Library tabs' segmented host).
class _Segmented extends StatelessWidget {
  final List<String> labels;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.labels,
    required this.icons,
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
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: AppDesignSystem.durationFast,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDesignSystem.spacingSM.h,
                  ),
                  decoration: BoxDecoration(
                    color: index == i
                        ? AppDesignSystem.surfaceWhite
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusSM.r,
                    ),
                    boxShadow: index == i ? AppDesignSystem.shadowSM : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        size: AppDesignSystem.iconSizeXS.sp,
                        color: index == i
                            ? AppDesignSystem.primaryColor
                            : AppDesignSystem.neutral500,
                      ),
                      SizedBox(width: AppDesignSystem.spacingXS.w),
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppDesignSystem.labelMedium.copyWith(
                            color: index == i
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
            ),
        ],
      ),
    );
  }
}

Widget _empty(String message) => ListView(
  children: [
    SizedBox(height: 80.h),
    Center(
      child: Text(
        message,
        style: AppDesignSystem.bodyMedium.copyWith(
          color: AppDesignSystem.neutral500,
        ),
      ),
    ),
  ],
);

class _LogRow extends StatelessWidget {
  final IconData icon;
  final String date;
  final String? notes;
  final VoidCallback onTap;

  const _LogRow({
    required this.icon,
    required this.date,
    required this.notes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppDesignSystem.primaryColor,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.neutral900,
                    fontWeight: AppDesignSystem.semiBold,
                  ),
                ),
                if ((notes ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.neutral400,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}
