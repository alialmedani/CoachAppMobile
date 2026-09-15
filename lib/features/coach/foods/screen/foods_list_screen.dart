import 'package:coachappmobile/core/boilerplate/pagination/cubits/pagination_cubit.dart';
import 'package:coachappmobile/core/boilerplate/pagination/widgets/pagination_list.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/utils/functions/debouncer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/food_cubit.dart';
import '../data/model/food_model.dart';
import 'food_detail_screen.dart';
import 'save_food_screen.dart';
import 'widgets/food_card.dart';

/// Food library list: searchable, paginated.
class FoodsListScreen extends StatefulWidget {
  const FoodsListScreen({super.key});

  @override
  State<FoodsListScreen> createState() => _FoodsListScreenState();
}

class _FoodsListScreenState extends State<FoodsListScreen> {
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
  void _onSearchChanged(FoodCubit cubit, String value) {
    cubit.setSearchTerm(value);
    _searchDebouncer.run(() {
      if (mounted) _refresh();
    });
  }

  Future<void> _openCreate(FoodCubit cubit) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const SaveFoodScreen()),
      ),
    );
    if (created == true) _refresh();
  }

  Future<void> _openDetail(FoodCubit cubit, FoodModel food) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: FoodDetailScreen(foodId: food.id ?? ''),
        ),
      ),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FoodCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(cubit),
        backgroundColor: AppDesignSystem.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('add_food'.tr()),
      ),
      body: Column(
        children: [
          BlocBuilder<FoodCubit, FoodState>(
            builder: (context, state) => Container(
              color: AppDesignSystem.surfaceWhite,
              padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
              child: AppTextField(
                hint: 'search_foods'.tr(),
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
                  AppDesignSystem.spacing4XL.h,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) => FoodCard(
                  food: list[index],
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
