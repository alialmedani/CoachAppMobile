import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/meal_item_model.dart';
import 'food_picker_sheet.dart';

/// Opens a bottom sheet to add or edit a single [MealItemModel] entry: pick a
/// food, set a serving quantity, and preview the item's macros (food per-serving
/// × quantity — a client-side estimate; the server recomputes on save). Pass
/// [initial] to edit; returns the built entry, or `null` if dismissed.
Future<MealItemModel?> showMealItemEntrySheet(
  BuildContext context, {
  MealItemModel? initial,
}) {
  return showModalBottomSheet<MealItemModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignSystem.surfaceWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDesignSystem.radiusLG.r),
      ),
    ),
    builder: (_) => _MealItemEntrySheet(initial: initial),
  );
}

class _MealItemEntrySheet extends StatefulWidget {
  final MealItemModel? initial;

  const _MealItemEntrySheet({this.initial});

  @override
  State<_MealItemEntrySheet> createState() => _MealItemEntrySheetState();
}

class _MealItemEntrySheetState extends State<_MealItemEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantity;

  String? _foodId;
  String? _foodName;
  String? _servingUnit;
  // Per-serving macros for the picked food (drive the live estimate).
  double _perCalories = 0;
  double _perProteinG = 0;
  double _perCarbsG = 0;
  double _perFatG = 0;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _foodId = e?.foodId;
    _foodName = e?.foodName;
    _servingUnit = e?.servingUnit;
    _quantity = TextEditingController(
      text: e != null ? _trimNum(e.quantity) : '1',
    );
    // Recover per-serving macros from an existing item's computed totals.
    if (e != null && e.quantity > 0) {
      _perCalories = e.calories / e.quantity;
      _perProteinG = e.proteinG / e.quantity;
      _perCarbsG = e.carbsG / e.quantity;
      _perFatG = e.fatG / e.quantity;
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  double get _quantityValue => double.tryParse(_quantity.text.trim()) ?? 0;

  Future<void> _pickFood() async {
    final food = await showFoodPickerSheet(context);
    if (food != null) {
      setState(() {
        _foodId = food.id;
        _foodName = food.name;
        _servingUnit = food.servingUnit;
        _perCalories = food.calories;
        _perProteinG = food.proteinG;
        _perCarbsG = food.carbsG;
        _perFatG = food.fatG;
      });
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();
    final validForm = _formKey.currentState?.validate() ?? false;
    if (_foodId == null || _foodId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('pick_food_first'.tr()),
          backgroundColor: AppDesignSystem.errorColor,
        ),
      );
      return;
    }
    if (!validForm) return;

    final q = _quantityValue;
    final entry = MealItemModel(
      id: widget.initial?.id,
      foodId: _foodId,
      foodName: _foodName,
      servingUnit: _servingUnit,
      quantity: q,
      order: widget.initial?.order ?? 0,
      calories: _perCalories * q,
      proteinG: _perProteinG * q,
      carbsG: _perCarbsG * q,
      fatG: _perFatG * q,
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final q = _quantityValue;
    final hasFood = _foodId != null && _foodId!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppDesignSystem.spacingSM.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppDesignSystem.neutral300,
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusFull.r,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'meal_item_entry'.tr(),
                      style: AppDesignSystem.h5.copyWith(
                        color: AppDesignSystem.neutral900,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    _FoodSelectTile(name: _foodName, onTap: _pickFood),
                    SizedBox(height: AppDesignSystem.spacingMD.h),
                    AppTextField(
                      label: 'quantity_servings'.tr(),
                      hint: 'quantity_hint'.tr(),
                      controller: _quantity,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: _validateQuantity,
                    ),
                    if (_servingUnit != null && _servingUnit!.isNotEmpty) ...[
                      SizedBox(height: AppDesignSystem.spacingXS.h),
                      Text(
                        'serving_unit_hint'.tr(args: [_servingUnit!]),
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.neutral500,
                        ),
                      ),
                    ],
                    if (hasFood) ...[
                      SizedBox(height: AppDesignSystem.spacingMD.h),
                      _ItemMacroPreview(
                        calories: _perCalories * q,
                        proteinG: _perProteinG * q,
                        carbsG: _perCarbsG * q,
                        fatG: _perFatG * q,
                      ),
                    ],
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'cancel'.tr(),
                            variant: AppButtonVariant.outline,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingSM.w),
                        Expanded(
                          child: AppButton(
                            text: 'save_meal_item'.tr(),
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDesignSystem.spacingSM.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateQuantity(String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null || n <= 0 || n > 10000) return 'quantity_range_error'.tr();
    return null;
  }
}

class _ItemMacroPreview extends StatelessWidget {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const _ItemMacroPreview({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral50,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: AppDesignSystem.iconSizeXS.sp,
                color: AppDesignSystem.accentDark,
              ),
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Text(
                'item_macro_estimate'.tr(args: [_n(calories)]),
                style: AppDesignSystem.labelMedium.copyWith(
                  color: AppDesignSystem.neutral700,
                  fontWeight: AppDesignSystem.semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          Wrap(
            spacing: AppDesignSystem.spacingXS.w,
            runSpacing: AppDesignSystem.spacing2XS.h,
            children: [
              AppBadge(
                text: 'macro_protein_short_g'.tr(args: [_n(proteinG)]),
                variant: AppBadgeVariant.info,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_carbs_short_g'.tr(args: [_n(carbsG)]),
                variant: AppBadgeVariant.warning,
                size: AppBadgeSize.small,
              ),
              AppBadge(
                text: 'macro_fat_short_g'.tr(args: [_n(fatG)]),
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

class _FoodSelectTile extends StatelessWidget {
  final String? name;
  final VoidCallback onTap;

  const _FoodSelectTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasFood = name != null && name!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFood
                ? AppDesignSystem.primaryColor
                : AppDesignSystem.neutral300,
            width: hasFood ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          color: hasFood
              ? AppDesignSystem.primarySurface
              : AppDesignSystem.surfaceWhite,
        ),
        child: Row(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: AppDesignSystem.iconSizeSM.sp,
              color: hasFood
                  ? AppDesignSystem.primaryDark
                  : AppDesignSystem.neutral500,
            ),
            SizedBox(width: AppDesignSystem.spacingSM.w),
            Expanded(
              child: Text(
                hasFood ? name! : 'select_food'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: hasFood
                      ? AppDesignSystem.neutral900
                      : AppDesignSystem.neutral500,
                  fontWeight: AppDesignSystem.medium,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppDesignSystem.iconSizeSM.sp,
              color: AppDesignSystem.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
