import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/food_cubit.dart';
import '../data/model/food_model.dart';
import 'save_food_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  GetModelCubit? _getModel;
  bool _changed = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FoodCubit>();
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
          title: 'food_details'.tr(),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _changed),
          ),
        ),
        body: GetModel<FoodModel>(
          onCubitCreated: (c) => _getModel = c,
          useCaseCallBack: () => cubit.fetchFoodById(widget.foodId),
          modelBuilder: (food) => _Body(
            food: food,
            onEdit: () => _edit(cubit, food),
            onDelete: () => _confirmDelete(cubit, food),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(FoodCubit cubit, FoodModel food) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: SaveFoodScreen(food: food),
        ),
      ),
    );
    if (result == true) {
      _changed = true;
      _getModel?.getModel();
    }
  }

  Future<void> _confirmDelete(FoodCubit cubit, FoodModel food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_food'.tr()),
        content: Text('delete_food_confirm'.tr(args: [food.name ?? ''])),
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

    final result = await cubit.deleteFood(food.id ?? widget.foodId);
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('food_deleted'.tr()),
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
  final FoodModel food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _Body({
    required this.food,
    required this.onEdit,
    required this.onDelete,
  });

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

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
              children: [
                Text(
                  food.name ?? '',
                  textAlign: TextAlign.center,
                  style: AppDesignSystem.h4.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
                if ((food.description ?? '').isNotEmpty) ...[
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  Text(
                    food.description!,
                    textAlign: TextAlign.center,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral500,
                    ),
                  ),
                ],
                SizedBox(height: AppDesignSystem.spacingMD.h),
                AppBadge(
                  text: 'per_serving_label'.tr(
                    args: [_n(food.servingSize), food.servingUnit],
                  ),
                  variant: AppBadgeVariant.neutral,
                  icon: Icons.straighten,
                ),
                SizedBox(height: AppDesignSystem.spacingLG.h),
                Text(
                  _n(food.calories),
                  style: AppDesignSystem.h1.copyWith(
                    color: AppDesignSystem.accentDark,
                  ),
                ),
                Text(
                  'calories'.tr(),
                  style: AppDesignSystem.labelMedium.copyWith(
                    color: AppDesignSystem.neutral500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          Row(
            children: [
              _MacroCard(
                label: 'protein'.tr(),
                value: _n(food.proteinG),
                color: AppDesignSystem.infoColor,
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              _MacroCard(
                label: 'carbs'.tr(),
                value: _n(food.carbsG),
                color: AppDesignSystem.warningColor,
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              _MacroCard(
                label: 'fat'.tr(),
                value: _n(food.fatG),
                color: AppDesignSystem.successColor,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingXL.h),
          AppButton(
            text: 'edit_food'.tr(),
            icon: Icons.edit_outlined,
            fullWidth: true,
            onPressed: onEdit,
          ),
          SizedBox(height: AppDesignSystem.spacingSM.h),
          AppButton(
            text: 'delete_food'.tr(),
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

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingMD.h),
        child: Column(
          children: [
            Text('$value g', style: AppDesignSystem.h5.copyWith(color: color)),
            SizedBox(height: AppDesignSystem.spacing2XS.h),
            Text(
              label,
              style: AppDesignSystem.labelSmall.copyWith(
                color: AppDesignSystem.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
