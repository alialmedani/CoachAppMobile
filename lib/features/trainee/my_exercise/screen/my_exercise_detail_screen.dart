import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/muscle_atlas/muscle_atlas.dart';
import 'package:coachappmobile/core/ui/widgets/muscle_atlas/muscle_atlas_mapping.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../cubit/my_exercise_cubit.dart';

/// Read-only detail of a single exercise the trainee tapped inside their workout
/// plan: photo, target-muscle + equipment badges, and the numbered instructions.
/// Boilerplate-driven — [GetModel] owns Loading/Success/Error from the cubit's
/// returned `Result`; this screen only displays.
class MyExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;

  const MyExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyExerciseCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'exercise_details'.tr()),
      body: GetModel<ExerciseModel>(
        loadingWidget: AppSkeleton.detail(),
        useCaseCallBack: () => cubit.fetchExerciseById(exerciseId),
        modelBuilder: (exercise) => _Body(exercise: exercise),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ExerciseModel exercise;

  const _Body({required this.exercise});

  bool get _hasImage => (exercise.imageUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    // Show the Arabic how-to when the app is in Arabic and it exists; otherwise
    // fall back to the English instructions.
    final locale = context.locale.languageCode;
    final instr = (locale == 'ar' && exercise.hasArInstructions)
        ? exercise.instructionsAr!.trim()
        : (exercise.instructions ?? '').trim();
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasImage) ...[
            AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
                child: _ExerciseImage(url: exercise.imageUrl!.trim()),
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingMD.h),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppDesignSystem.primarySurface,
                        borderRadius: BorderRadius.circular(
                          AppDesignSystem.radiusMD.r,
                        ),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: AppDesignSystem.primaryDark,
                        size: AppDesignSystem.iconSizeMD.sp,
                      ),
                    ),
                    SizedBox(width: AppDesignSystem.spacingMD.w),
                    Expanded(
                      child: Text(
                        exercise.name ?? 'exercise'.tr(),
                        style: AppDesignSystem.h5.copyWith(
                          color: AppDesignSystem.neutral900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDesignSystem.spacingMD.h),
                Wrap(
                  spacing: AppDesignSystem.spacingXS.w,
                  runSpacing: AppDesignSystem.spacingXS.h,
                  children: [
                    AppBadge(
                      text: exercise.targetMuscle.labelKey.tr(),
                      variant: AppBadgeVariant.info,
                      icon: Icons.accessibility_new,
                    ),
                    AppBadge(
                      text: exercise.equipment.labelKey.tr(),
                      variant: AppBadgeVariant.neutral,
                      icon: Icons.sports_gymnastics,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (MuscleAtlasMapping.hasMuscles(exercise.targetMuscle)) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppDesignSystem.spacingXS.w,
                bottom: AppDesignSystem.spacingXS.h,
              ),
              child: Text(
                'muscle_map'.tr(),
                style: AppDesignSystem.labelMedium.copyWith(
                  color: AppDesignSystem.neutral500,
                ),
              ),
            ),
            AppCard(
              child: MuscleAtlas(selected: exercise.targetMuscle),
            ),
          ],
          if (instr.isNotEmpty) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            _TextSection(title: 'instructions'.tr(), body: instr),
          ],
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }
}

/// Network image for exercise media — no auth header (the URLs are free-form,
/// typically external CDN hosts, so [CachedImage]'s Bearer would break them),
/// with a shimmer while loading and a graceful placeholder if the URL fails.
class _ExerciseImage extends StatelessWidget {
  final String url;

  const _ExerciseImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final height = 200.h;
    return ExtendedImage.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      printError: false,
      cacheMaxAge: const Duration(days: 30),
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Shimmer.fromColors(
              baseColor: AppDesignSystem.neutral200,
              highlightColor: AppDesignSystem.neutral100,
              child: Container(
                width: double.infinity,
                height: height,
                color: AppDesignSystem.neutral200,
              ),
            );
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return Container(
              width: double.infinity,
              height: height,
              color: AppDesignSystem.neutral100,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: AppDesignSystem.iconSizeLG.sp,
                    color: AppDesignSystem.neutral400,
                  ),
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Text(
                    'image_unavailable'.tr(),
                    style: AppDesignSystem.bodySmall.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final String body;

  const _TextSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppDesignSystem.spacingXS.w,
            bottom: AppDesignSystem.spacingXS.h,
          ),
          child: Text(
            title,
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
        ),
        AppCard(
          child: Text(
            body,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral800,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
