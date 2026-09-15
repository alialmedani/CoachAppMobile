import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/meal_item_model.dart';
import '../../data/model/meal_model.dart';
import 'meal_item_entry_sheet.dart';
import 'serving_display.dart';

/// Editable card for one [MealModel] in the builder: meal name and a reorderable
/// list of food-item rows. All edits are pushed up through [onChanged];
/// [dragHandle] is supplied by the parent [ReorderableListView] so the whole
/// meal can be dragged.
class MealEditorCard extends StatefulWidget {
  final MealModel meal;
  final int index;
  final Widget dragHandle;
  final ValueChanged<MealModel> onChanged;
  final VoidCallback onRemove;

  const MealEditorCard({
    super.key,
    required this.meal,
    required this.index,
    required this.dragHandle,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<MealEditorCard> createState() => _MealEditorCardState();
}

class _MealEditorCardState extends State<MealEditorCard> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.meal.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _emit({List<MealItemModel>? items}) {
    widget.onChanged(
      MealModel(
        id: widget.meal.id,
        name: _name.text.trim(),
        order: widget.meal.order,
        items: items ?? widget.meal.items,
      ),
    );
  }

  Future<void> _addItem() async {
    final entry = await showMealItemEntrySheet(context);
    if (entry != null) {
      _emit(items: [...widget.meal.items, entry]);
    }
  }

  Future<void> _editItem(int index) async {
    final entry = await showMealItemEntrySheet(
      context,
      initial: widget.meal.items[index],
    );
    if (entry != null) {
      final list = [...widget.meal.items];
      list[index] = entry;
      _emit(items: list);
    }
  }

  void _removeItem(int index) {
    final list = [...widget.meal.items]..removeAt(index);
    _emit(items: list);
  }

  void _moveItem(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= widget.meal.items.length) return;
    final list = [...widget.meal.items];
    final item = list.removeAt(index);
    list.insert(target, item);
    _emit(items: list);
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.meal.items;
    return AppCard(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingMD.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              widget.dragHandle,
              SizedBox(width: AppDesignSystem.spacingXS.w),
              Expanded(
                child: AppTextField(
                  hint: 'meal_name_hint'.tr(),
                  controller: _name,
                  onChanged: (v) =>
                      widget.onChanged(widget.meal.copyWith(name: v.trim())),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'field_required'.tr();
                    if (t.length > 64) return 'meal_name_max_error'.tr();
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.errorColor,
                ),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppDesignSystem.spacingSM.h,
              ),
              child: Text(
                'no_items_in_meal'.tr(),
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.neutral400,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++)
              _MealItemRow(
                key: ValueKey(items[i].id ?? 'item-$i'),
                item: items[i],
                isFirst: i == 0,
                isLast: i == items.length - 1,
                onEdit: () => _editItem(i),
                onRemove: () => _removeItem(i),
                onMoveUp: () => _moveItem(i, -1),
                onMoveDown: () => _moveItem(i, 1),
              ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          AppButton(
            text: 'add_item_to_meal'.tr(),
            icon: Icons.add,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            fullWidth: true,
            onPressed: _addItem,
          ),
        ],
      ),
    );
  }
}

class _MealItemRow extends StatelessWidget {
  final MealItemModel item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _MealItemRow({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDesignSystem.spacingXS.h),
      padding: EdgeInsets.all(AppDesignSystem.spacingSM.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutral50,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
        border: Border.all(color: AppDesignSystem.neutral200),
      ),
      child: Row(
        children: [
          Column(
            children: [
              _MoveButton(
                icon: Icons.keyboard_arrow_up,
                enabled: !isFirst,
                onTap: onMoveUp,
              ),
              _MoveButton(
                icon: Icons.keyboard_arrow_down,
                enabled: !isLast,
                onTap: onMoveDown,
              ),
            ],
          ),
          SizedBox(width: AppDesignSystem.spacingXS.w),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodName ?? 'meal_item_entry'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.neutral900,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacing2XS.h),
                  Wrap(
                    spacing: AppDesignSystem.spacingXS.w,
                    runSpacing: AppDesignSystem.spacing2XS.h,
                    children: _summaryChips(),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: AppDesignSystem.iconSizeXS.sp,
              color: AppDesignSystem.neutral400,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  List<Widget> _summaryChips() {
    return [
      AppBadge(
        text: ServingDisplay.compact(
          item.quantity,
          item.servingSize,
          item.servingUnit,
        ),
        variant: AppBadgeVariant.primary,
        size: AppBadgeSize.small,
      ),
      AppBadge(
        text: 'macro_calories_kcal'.tr(args: [_n(item.calories)]),
        variant: AppBadgeVariant.neutral,
        size: AppBadgeSize.small,
      ),
    ];
  }
}

class _MoveButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _MoveButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Icon(
        icon,
        size: AppDesignSystem.iconSizeSM.sp,
        color: enabled
            ? AppDesignSystem.neutral600
            : AppDesignSystem.neutral300,
      ),
    );
  }
}
