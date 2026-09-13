import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onTap;

  const FoodCard({super.key, required this.food, required this.onTap});

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
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppDesignSystem.accentSurface,
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
                ),
                child: Icon(
                  Icons.restaurant_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
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
                      'per_serving_label'.tr(args: [
                        _n(food.servingSize),
                        food.servingUnit,
                      ]),
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
                    style: AppDesignSystem.h5.copyWith(
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
          Row(
            children: [
              _Macro(label: 'protein_short'.tr(), value: _n(food.proteinG)),
              _Macro(label: 'carbs_short'.tr(), value: _n(food.carbsG)),
              _Macro(label: 'fat_short'.tr(), value: _n(food.fatG)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final String value;

  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsetsDirectional.only(end: AppDesignSystem.spacingXS.w),
        padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingXS.h),
        decoration: BoxDecoration(
          color: AppDesignSystem.neutral50,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusSM.r),
        ),
        child: Column(
          children: [
            Text(
              '$value g',
              style: AppDesignSystem.labelMedium.copyWith(
                color: AppDesignSystem.neutral900,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
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
