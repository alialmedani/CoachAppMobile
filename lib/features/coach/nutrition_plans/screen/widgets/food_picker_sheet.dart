import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:coachappmobile/features/coach/foods/cubit/food_cubit.dart';
import 'package:coachappmobile/features/coach/foods/data/model/food_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens a searchable bottom sheet over the coach food library and returns the
/// picked [FoodModel] (or `null` if dismissed). Each row shows the food's
/// per-serving macros so the coach can size a portion at a glance. Runs on its
/// own fresh [FoodCubit] so it never touches the plan feature's state.
Future<FoodModel?> showFoodPickerSheet(BuildContext context) {
  return showModalBottomSheet<FoodModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => BlocProvider(
      create: (_) => getIt<FoodCubit>(),
      child: const _FoodPickerSheet(),
    ),
  );
}

class _FoodPickerSheet extends StatefulWidget {
  const _FoodPickerSheet();

  @override
  State<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends State<_FoodPickerSheet> {
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
  void _onSearchChanged(FoodCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FoodCubit>();
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            _SheetHandle(title: 'select_food'.tr()),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignSystem.spacingMD.w,
                vertical: AppDesignSystem.spacingSM.h,
              ),
              child: AppTextField(
                hint: 'search_foods'.tr(),
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
              child: PaginationList<FoodModel>(
                withPagination: true,
                onCubitCreated: (c) => _pagination = c,
                repositoryCallBack: (data) => cubit.fetchFoodList(data),
                noDataWidget: AppEmptyState(
                  icon: Icons.restaurant_outlined,
                  title: 'no_foods'.tr(),
                  subtitle: 'no_foods_subtitle'.tr(),
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
                  itemBuilder: (context, index) => _FoodPickRow(
                    food: list[index],
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

class _FoodPickRow extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onTap;

  const _FoodPickRow({required this.food, required this.onTap});

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingSM.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesignSystem.accentSurface,
                  borderRadius: BorderRadius.circular(
                    AppDesignSystem.radiusMD.r,
                  ),
                ),
                child: Icon(
                  Icons.restaurant_outlined,
                  size: AppDesignSystem.iconSizeXS.sp,
                  color: AppDesignSystem.accentDark,
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppDesignSystem.h6.copyWith(
                        color: AppDesignSystem.neutral900,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacing2XS.h),
                    Text(
                      'per_serving_label'.tr(
                        args: [_n(food.servingSize), food.servingUnit],
                      ),
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _n(food.calories),
                    style: AppDesignSystem.h6.copyWith(
                      color: AppDesignSystem.accentDark,
                    ),
                  ),
                  Text(
                    'kcal'.tr(),
                    style: AppDesignSystem.labelSmall.copyWith(
                      color: AppDesignSystem.neutral400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Wrap(
            spacing: AppDesignSystem.spacingXS.w,
            runSpacing: AppDesignSystem.spacing2XS.h,
            children: [
              AppBadge(
                text: 'macro_protein_short_g'.tr(args: [_n(food.proteinG)]),
                variant: AppBadgeVariant.info,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_carbs_short_g'.tr(args: [_n(food.carbsG)]),
                variant: AppBadgeVariant.warning,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_fat_short_g'.tr(args: [_n(food.fatG)]),
                variant: AppBadgeVariant.success,
                size: AppBadgeSize.small,
              ),
            ],
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
