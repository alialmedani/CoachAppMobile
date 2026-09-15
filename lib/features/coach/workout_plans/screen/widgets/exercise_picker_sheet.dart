import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:coachappmobile/features/coach/exercises/cubit/exercise_cubit.dart';
import 'package:coachappmobile/features/coach/exercises/data/model/exercise_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens a searchable bottom sheet over the coach exercise library and returns
/// the picked [ExerciseModel] (or `null` if dismissed). Runs on its own fresh
/// [ExerciseCubit] so it never touches the plan feature's state.
Future<ExerciseModel?> showExercisePickerSheet(BuildContext context) {
  return showModalBottomSheet<ExerciseModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<ExerciseCubit>(),
      child: const _ExercisePickerSheet(),
    ),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  PaginationCubit? _pagination;

  @override
  void dispose() {
    _searchDebouncer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => _pagination?.getList();

  /// Store the term immediately but debounce the re-fetch so it fires once the
  /// user pauses, not per keystroke.
  void _onSearchChanged(ExerciseCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseCubit>();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            _SheetHandle(title: 'select_exercise'.tr()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacingMD.w,
                vertical: AppDesignSystem.spacingSM.h,
              ),
              child: AppTextField(
                hint: 'search_exercises'.tr(),
                controller: _searchController,
                onChanged: (v) => _onSearchChanged(cubit, v),
                prefixIcon: Icon(
                  Icons.search,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.neutral400,
                ),
              ),
            ),
            Expanded(
              child: PaginationList<ExerciseModel>(
                withPagination: true,
                onCubitCreated: (c) => _pagination = c,
                repositoryCallBack: (data) => cubit.fetchExerciseList(data),
                noDataWidget: AppEmptyState(
                  icon: Icons.fitness_center,
                  title: 'no_exercises'.tr(),
                  subtitle: 'no_exercises_subtitle'.tr(),
                  iconColor: AppDesignSystem.primaryColor,
                ),
                listBuilder: (list) => ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacingSM.h,
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacing2XL.h,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _ExercisePickRow(
                    exercise: list[index],
                    onTap: () => Navigator.pop(context, list[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePickRow extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const _ExercisePickRow({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primarySurface,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Icon(
              Icons.fitness_center,
              size: AppDesignSystem.iconSizeXS.sp,
              color: AppDesignSystem.primaryDark,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesignSystem.h6.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacing2XS.h),
                Text(
                  exercise.targetMuscle.labelKey.tr(),
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.add_circle_outline,
            color: AppDesignSystem.primaryColor,
            size: AppDesignSystem.iconSizeMD.sp,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final String title;

  const _SheetHandle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppDesignSystem.spacingSM.h),
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppDesignSystem.neutral300,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull.r),
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingSM.h),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.spacingMD.w,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppDesignSystem.h5.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: AppDesignSystem.iconSizeSM.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppDesignSystem.neutral200),
      ],
    );
  }
}
