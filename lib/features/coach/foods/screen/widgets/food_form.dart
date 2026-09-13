import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/usecase/create_food_usecase.dart';

/// Shared food create/edit form, editing [params] in place.
class FoodForm extends StatefulWidget {
  final SaveFoodParams params;

  const FoodForm({super.key, required this.params});

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _servingSize;
  late final TextEditingController _servingUnit;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;

  SaveFoodParams get p => widget.params;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: p.name);
    _description = TextEditingController(text: p.description ?? '');
    _servingSize = TextEditingController(text: _num(p.servingSize));
    _servingUnit = TextEditingController(text: p.servingUnit);
    _calories = TextEditingController(text: _num(p.calories));
    _protein = TextEditingController(text: _num(p.proteinG));
    _carbs = TextEditingController(text: _num(p.carbsG));
    _fat = TextEditingController(text: _num(p.fatG));
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _servingSize.dispose();
    _servingUnit.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static final _decimal =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: 'basic_information'.tr(),
          children: [
            AppTextField(
              label: 'food_name'.tr(),
              hint: 'food_name_hint'.tr(),
              controller: _name,
              textInputAction: TextInputAction.next,
              onChanged: (v) => p.name = v,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'field_required'.tr() : null,
            ),
            AppTextField(
              label: 'description'.tr(),
              hint: 'food_description_hint'.tr(),
              controller: _description,
              maxLines: 2,
              onChanged: (v) => p.description = v.trim().isEmpty ? null : v,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: 'serving_size'.tr(),
                    hint: '100',
                    controller: _servingSize,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    onChanged: (v) => p.servingSize = double.tryParse(v) ?? 0,
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'serving_unit'.tr(),
                    hint: 'g',
                    controller: _servingUnit,
                    onChanged: (v) => p.servingUnit = v.trim().isEmpty ? 'g' : v.trim(),
                  ),
                ),
              ],
            ),
          ],
        ),
        AppFormSection(
          title: 'nutrition_per_serving'.tr(),
          showDivider: false,
          children: [
            AppTextField(
              label: 'calories'.tr(),
              hint: '0',
              controller: _calories,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimal],
              prefixIcon: Icon(
                Icons.local_fire_department_outlined,
                size: AppDesignSystem.iconSizeSM.sp,
                color: AppDesignSystem.accentColor,
              ),
              onChanged: (v) => p.calories = double.tryParse(v) ?? 0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'protein_g'.tr(),
                    hint: '0',
                    controller: _protein,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    onChanged: (v) => p.proteinG = double.tryParse(v) ?? 0,
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'carbs_g'.tr(),
                    hint: '0',
                    controller: _carbs,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    onChanged: (v) => p.carbsG = double.tryParse(v) ?? 0,
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'fat_g'.tr(),
                    hint: '0',
                    controller: _fat,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimal],
                    onChanged: (v) => p.fatG = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            AppCheckboxField(
              label: 'active_food'.tr(),
              subtitle: 'active_food_hint'.tr(),
              value: p.isActive,
              onChanged: (v) => setState(() => p.isActive = v ?? true),
            ),
          ],
        ),
      ],
    );
  }
}
