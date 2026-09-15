import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/trainee/nutrition_logs/data/model/nutrition_log_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/coach_log_cubit.dart';
import '../widgets/nutrition_log_view.dart';

/// Coach read-only view of one of a trainee's nutrition logs (server totals +
/// items). The full tree is fetched by id (the list omits entries/totals).
class CoachNutritionLogDetailScreen extends StatelessWidget {
  final String logId;

  const CoachNutritionLogDetailScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoachLogCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'nutrition_log'.tr()),
      body: GetModel<NutritionLogModel>(
        useCaseCallBack: () => cubit.fetchNutritionLogById(logId),
        modelBuilder: (log) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NutritionLogView(log: log),
              SizedBox(height: AppDesignSystem.spacingXL.h),
            ],
          ),
        ),
      ),
    );
  }
}
