import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/dialogs/dialogs.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/exercise_cubit.dart';
import '../data/model/exercise_model.dart';
import 'save_exercise_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseCubit>();
    // System/gesture back must carry `_changed` back to the list (like the
    // leading button does) so the list refreshes after an edit/delete;
    // a plain implicit pop returns null and would leave the list stale.
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: 'exercise_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<ExerciseModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchExerciseById(widget.exerciseId),
          modelBuilder: (exercise) => _Body(
            exercise: exercise,
            onEdit: () => _edit(cubit, exercise),
            onDelete: () => _confirmDelete(cubit, exercise),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(ExerciseCubit cubit, ExerciseModel exercise) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: SaveExerciseScreen(exercise: exercise),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _confirmDelete(
    ExerciseCubit cubit,
    ExerciseModel exercise,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_exercise'.tr()),
        content: Text(
          'delete_exercise_confirm'.tr(args: [exercise.name ?? '']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.errorColor,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await cubit.deleteExercise(exercise.id ?? widget.exerciseId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('exercise_deleted'.tr()),
          backgroundColor: AppDesignSystem.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'something_went_wrong'.tr()),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
    }
  }
}

class _Body extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _Body({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _hasMedia =>
      (exercise.imageUrl ?? '').trim().isNotEmpty ||
      (exercise.videoUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        exercise.name ?? '',
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
                    AppBadge(
                      text: (exercise.isActive ? 'active' : 'inactive').tr(),
                      variant: exercise.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                      dot: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_hasMedia) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            _MediaSection(
              imageUrl: exercise.imageUrl,
              videoUrl: exercise.videoUrl,
            ),
          ],
          if ((exercise.description ?? '').isNotEmpty) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            _TextSection(
              title: 'description'.tr(),
              body: exercise.description!,
            ),
          ],
          if ((exercise.instructions ?? '').isNotEmpty) ...[
            SizedBox(height: AppDesignSystem.spacingMD.h),
            _TextSection(
              title: 'instructions'.tr(),
              body: exercise.instructions!,
            ),
          ],
          SizedBox(height: AppDesignSystem.spacingXL.h),
          AppButton(
            text: 'edit_exercise'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: onEdit,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          AppButton(
            text: 'delete_exercise'.tr(),
            icon: Icons.delete_outline,
            variant: AppButtonVariant.danger,
            fullWidth: true,
            onPressed: onDelete,
          ),
          SizedBox(height: AppDesignSystem.spacingXL.h),
        ],
      ),
    );
  }
}

/// Read-only display of an exercise's image and/or a link to its video.
///
/// The URLs are free-form coach input (typically external hosts), so the image
/// is loaded WITHOUT the app's Bearer header — unlike [CachedImage], which is
/// for backend-hosted media. Actual in-app video playback is deferred (V1.1);
/// F21 only surfaces the media, opening the video link externally.
class _MediaSection extends StatelessWidget {
  final String? imageUrl;
  final String? videoUrl;

  const _MediaSection({this.imageUrl, this.videoUrl});

  bool get _hasImage => (imageUrl ?? '').trim().isNotEmpty;
  bool get _hasVideo => (videoUrl ?? '').trim().isNotEmpty;

  Future<void> _openVideo() async {
    final uri = Uri.tryParse(videoUrl!.trim());
    if (uri == null || !uri.hasScheme) {
      Dialogs.showSnackBar(
        message: 'could_not_open_video'.tr(),
        variant: AppToastVariant.error,
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        Dialogs.showSnackBar(
          message: 'could_not_open_video'.tr(),
          variant: AppToastVariant.error,
        );
      }
    } catch (_) {
      Dialogs.showSnackBar(
        message: 'could_not_open_video'.tr(),
        variant: AppToastVariant.error,
      );
    }
  }

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
            'media'.tr(),
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
        ),
        if (_hasImage)
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLG.r),
              child: _ExerciseImage(url: imageUrl!.trim()),
            ),
          ),
        if (_hasImage && _hasVideo)
          SizedBox(height: AppDesignSystem.spacingSM.h),
        if (_hasVideo)
          AppButton(
            text: 'watch_video'.tr(),
            icon: Icons.play_circle_outline,
            variant: AppButtonVariant.outline,
            fullWidth: true,
            onPressed: _openVideo,
          ),
      ],
    );
  }
}

/// Network image for exercise media — no auth header, with a shimmer while
/// loading and a graceful placeholder if the URL fails to load.
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
