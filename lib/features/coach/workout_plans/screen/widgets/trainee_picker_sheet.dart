import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:coachappmobile/features/coach/trainees/cubit/trainee_cubit.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens a searchable bottom sheet over the coach's trainees and returns the
/// picked [TraineeModel] (or `null` if dismissed). Runs on its own fresh
/// [TraineeCubit].
Future<TraineeModel?> showTraineePickerSheet(BuildContext context) {
  return showModalBottomSheet<TraineeModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<TraineeCubit>(),
      child: const _TraineePickerSheet(),
    ),
  );
}

class _TraineePickerSheet extends StatefulWidget {
  const _TraineePickerSheet();

  @override
  State<_TraineePickerSheet> createState() => _TraineePickerSheetState();
}

class _TraineePickerSheetState extends State<_TraineePickerSheet> {
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
  void _onSearchChanged(TraineeCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TraineeCubit>();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            _SheetHandle(title: 'select_trainee'.tr()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacingMD.w,
                vertical: AppDesignSystem.spacingSM.h,
              ),
              child: AppTextField(
                hint: 'search_trainees'.tr(),
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
                    AppDesignSystem.spacing2XL.h,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _TraineePickRow(
                    trainee: list[index],
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

class _TraineePickRow extends StatelessWidget {
  final TraineeModel trainee;
  final VoidCallback onTap;

  const _TraineePickRow({required this.trainee, required this.onTap});

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
            decoration: const BoxDecoration(
              color: AppDesignSystem.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              trainee.initial,
              style: AppDesignSystem.h6.copyWith(
                color: AppDesignSystem.primaryDark,
              ),
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingMD.w),
          Expanded(
            child: Text(
              trainee.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppDesignSystem.h6.copyWith(
                color: AppDesignSystem.neutral900,
              ),
            ),
          ),
          Icon(
            Icons.check_circle_outline,
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
