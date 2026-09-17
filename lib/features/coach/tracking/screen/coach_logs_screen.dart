import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/apex/apex_segmented.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:coachappmobile/features/trainee/workout_logs/data/model/workout_log_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'logs'.tr(), subtitle: widget.traineeName),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
            child: ApexSegmented(
              labels: ['tab_workout'.tr(), 'tab_nutrition'.tr()],
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
          ? _empty(Icons.fitness_center_outlined, 'no_workout_logs'.tr())
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
          ? _empty(Icons.restaurant_outlined, 'no_nutrition_logs'.tr())
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

/// Empty state — now the shared [AppEmptyState] (was a bare centered Text), for
/// parity with the progress/notes screens.
Widget _empty(IconData icon, String title) => AppEmptyState(
  icon: icon,
  title: title,
  subtitle: 'no_logs_subtitle'.tr(),
  iconColor: AppDesignSystem.primaryColor,
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
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
              shape: const ChamferBorder(cut: 10),
            ),
            child: Icon(
              icon,
              color: AppDesignSystem.primaryStrong,
              size: AppDesignSystem.iconSizeSM.sp,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Technical date string — force LTR so digits/hyphens don't
                // visually reorder in Arabic.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    date,
                    style: AppDesignSystem.bodyLarge.copyWith(
                      color: AppDesignSystem.textPrimary,
                      fontWeight: AppDesignSystem.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                if ((notes ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Text(
                    notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppDesignSystem.textFaint,
            size: AppDesignSystem.iconSizeSM.sp,
          ),
        ],
      ),
    );
  }
}
