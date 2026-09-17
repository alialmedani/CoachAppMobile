import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/constant/app_icons/app_icons.dart';
import 'package:coachappmobile/core/ui/shapes/chamfer.dart';
import 'package:coachappmobile/core/ui/widgets/app_icon.dart';
import 'package:coachappmobile/core/ui/widgets/apex/apex_segmented.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/trainee_cubit.dart';
import '../data/model/trainee_enums.dart';
import '../data/model/trainee_model.dart';
import 'create_trainee_screen.dart';
import 'trainee_detail_screen.dart';
import 'widgets/trainee_card.dart';

/// Coach "Trainees" tab: searchable, filterable, paginated list of trainees.
class TraineesListScreen extends StatefulWidget {
  const TraineesListScreen({super.key});

  @override
  State<TraineesListScreen> createState() => _TraineesListScreenState();
}

class _TraineesListScreenState extends State<TraineesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  PaginationCubit? _pagination;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() => _pagination?.getList();

  void _onSearchChanged(String value) {
    context.read<TraineeCubit>().setSearchTerm(value);
    _refresh();
  }

  Future<void> _openCreate(TraineeCubit cubit) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const CreateTraineeScreen(),
        ),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(TraineeCubit cubit, TraineeModel trainee) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: TraineeDetailScreen(traineeId: trainee.id ?? ''),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceCanvas,
      appBar: AppTopBar(title: 'trainees'.tr()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_trainees',
        onPressed: () => _openCreate(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: AppDesignSystem.onPrimary,
        shape: const ChamferBorder(cut: 16),
        icon: AppIcon(
          AppIcons.plus,
          size: AppDesignSystem.iconSizeSM,
          color: AppDesignSystem.onPrimary,
        ),
        label: Text('add_trainee'.tr()),
      ),
      body: Column(
        children: [
          BlocBuilder<TraineeCubit, TraineeState>(
            builder: (context, state) => _SearchAndFilters(
              controller: _searchController,
              searchTerm: cubit.searchTerm,
              filterActive: cubit.filterActive,
              filterGoal: cubit.filterGoal,
              onSearchChanged: _onSearchChanged,
              onClearSearch: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              onStatusChanged: (v) {
                cubit.setFilterActive(v);
                _refresh();
              },
              onGoalChanged: (v) {
                cubit.setFilterGoal(v);
                _refresh();
              },
            ),
          ),
          Expanded(
            child: PaginationList<TraineeModel>(
              withPagination: true,
              onCubitCreated: (c) => _pagination = c,
              repositoryCallBack: (data) => cubit.fetchTraineeList(data),
              noDataWidget: AppEmptyState(
                icon: Icons.people_outline,
                title: 'no_trainees'.tr(),
                subtitle: 'no_trainees_subtitle'.tr(),
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
                itemBuilder: (context, index) => TraineeCard(
                  trainee: list[index],
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

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final String searchTerm;
  final bool? filterActive;
  final int? filterGoal;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<bool?> onStatusChanged;
  final ValueChanged<int?> onGoalChanged;

  const _SearchAndFilters({
    required this.controller,
    required this.searchTerm,
    required this.filterActive,
    required this.filterGoal,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStatusChanged,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            hint: 'search_trainees'.tr(),
            controller: controller,
            onChanged: onSearchChanged,
            prefixIcon: Icon(
              Icons.search,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.neutral400,
            ),
            suffixIcon: searchTerm.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: AppDesignSystem.iconSizeSM.sp),
                    onPressed: onClearSearch,
                  )
                : null,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Row(
            children: [
              Expanded(
                child: ApexSegmented(
                  labels: ['active'.tr(), 'inactive'.tr(), 'all'.tr()],
                  index: filterActive == true
                      ? 0
                      : filterActive == false
                      ? 1
                      : 2,
                  onChanged: (i) =>
                      onStatusChanged(const [true, false, null][i]),
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              _GoalFilterChip(
                selectedGoal: filterGoal,
                onChanged: onGoalChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Goal filter — an Apex pill that opens a popup of training goals. Reads as
/// selected (Volt) when a goal is set, neutral otherwise.
class _GoalFilterChip extends StatelessWidget {
  final int? selectedGoal;
  final ValueChanged<int?> onChanged;

  const _GoalFilterChip({required this.selectedGoal, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = selectedGoal != null;
    final label = selected
        ? TrainingGoal.fromValue(selectedGoal).labelKey.tr()
        : 'goal'.tr();
    final color = selected
        ? AppDesignSystem.primaryStrong
        : AppDesignSystem.textMuted;
    return PopupMenuButton<int?>(
      onSelected: onChanged,
      color: AppDesignSystem.surfaceOverlay,
      itemBuilder: (context) => [
        PopupMenuItem<int?>(value: null, child: Text('all_goals'.tr())),
        for (final g in TrainingGoal.values)
          PopupMenuItem<int?>(value: g.value, child: Text(g.labelKey.tr())),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.spacingSM.w,
          vertical: AppDesignSystem.spacingSM.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppDesignSystem.primaryColor.withValues(alpha: 0.10)
              : AppDesignSystem.surfaceSunken,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          border: Border.all(
            color: selected
                ? AppDesignSystem.primaryColor.withValues(alpha: 0.35)
                : AppDesignSystem.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: AppDesignSystem.iconSizeXS.sp, color: color),
            SizedBox(width: AppDesignSystem.spacing2XS.w),
            Text(
              label,
              style: AppDesignSystem.labelMedium.copyWith(
                color: color,
                fontWeight: AppDesignSystem.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: AppDesignSystem.iconSizeSM.sp, color: color),
          ],
        ),
      ),
    );
  }
}
