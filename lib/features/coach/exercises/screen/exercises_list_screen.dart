import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/exercise_cubit.dart';
import '../data/model/exercise_enums.dart';
import '../data/model/exercise_model.dart';
import 'exercise_detail_screen.dart';
import 'save_exercise_screen.dart';
import 'widgets/exercise_card.dart';

/// Exercise library list: searchable, filter by muscle, paginated.
class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  State<ExercisesListScreen> createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
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

  /// Store the term immediately (keeps the clear button in sync) but debounce
  /// the backend re-fetch so it fires once the user pauses, not per keystroke.
  void _onSearchChanged(ExerciseCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  Future<void> _openCreate(ExerciseCubit cubit) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const SaveExerciseScreen()),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(ExerciseCubit cubit, ExerciseModel exercise) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ExerciseDetailScreen(exerciseId: exercise.id ?? ''),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('add_exercise'.tr()),
      ),
      body: Column(
        children: [
          BlocBuilder<ExerciseCubit, ExerciseState>(
            builder: (context, state) => Container(
              color: AppDesignSystem.surfaceWhite,
              padding: EdgeInsets.fromLTRB(
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
                AppDesignSystem.spacingMD.w,
                AppDesignSystem.spacingSM.h,
              ),
              child: Column(
                children: [
                  AppTextField(
                    hint: 'search_exercises'.tr(),
                    controller: _searchController,
                    onChanged: (v) => _onSearchChanged(cubit, v),
                    prefixIcon: Icon(
                      Icons.search,
                      size: AppDesignSystem.iconSizeSM.sp,
                      color: AppDesignSystem.neutral400,
                    ),
                    suffixIcon: cubit.searchTerm.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: AppDesignSystem.iconSizeSM.sp,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              cubit.setSearchTerm('');
                              _searchDebouncer.cancel();
                              _refresh();
                            },
                          )
                        : null,
                  ),
                  SizedBox(height: AppDesignSystem.spacingSM.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _MuscleFilterChip(
                      selected: cubit.filterMuscle,
                      onChanged: (v) {
                        cubit.setFilterMuscle(v);
                        _refresh();
                      },
                    ),
                  ),
                ],
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
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) => ExerciseCard(
                  exercise: list[index],
                  onTap: () => _openDetail(cubit, list[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleFilterChip extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;

  const _MuscleFilterChip({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected != null;
    final label = isSelected
        ? MuscleGroup.fromValue(selected).labelKey.tr()
        : 'target_muscle'.tr();
    return PopupMenuButton<int?>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<int?>(value: null, child: Text('all_muscles'.tr())),
        for (final m in MuscleGroup.values)
          PopupMenuItem<int?>(value: m.value, child: Text(m.labelKey.tr())),
      ],
      child: Chip(
        avatar: Icon(
          Icons.accessibility_new,
          size: AppDesignSystem.iconSizeXS.sp,
          color: isSelected
              ? AppDesignSystem.primaryDark
              : AppDesignSystem.neutral600,
        ),
        label: Text(label),
        labelStyle: AppDesignSystem.labelMedium.copyWith(
          color: isSelected
              ? AppDesignSystem.primaryDark
              : AppDesignSystem.neutral600,
        ),
        backgroundColor: isSelected
            ? AppDesignSystem.primarySurface
            : AppDesignSystem.neutral100,
        side: BorderSide.none,
      ),
    );
  }
}
