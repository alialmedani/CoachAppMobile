import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/trainee_note_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_notes_cubit.dart';

/// Read-only list of the coach's notes about the trainee (newest first). The
/// list carries the full text, so each card renders it inline.
class MyNotesScreen extends StatelessWidget {
  const MyNotesScreen({super.key});

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyNotesCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'coach_notes'.tr()),
      body: GetModel<List<TraineeNoteModel>>(
        useCaseCallBack: () => cubit.fetchRecent(),
        modelBuilder: (notes) => notes.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: AppDesignSystem.spacing4XL.h),
                  AppEmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: 'no_coach_notes'.tr(),
                    subtitle: 'no_coach_notes_subtitle'.tr(),
                    iconColor: AppDesignSystem.primaryColor,
                  ),
                ],
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingMD.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: notes.length,
                itemBuilder: (context, i) => AppCard(
                  margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fmtDate(notes[i].date),
                        style: AppDesignSystem.labelMedium.copyWith(
                          color: AppDesignSystem.neutral500,
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacing2XS.h),
                      Text(
                        notes[i].text,
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: AppDesignSystem.neutral800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
