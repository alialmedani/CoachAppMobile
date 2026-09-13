import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/workout_day_model.dart';
import '../../data/model/workout_enums.dart';
import '../../data/model/workout_exercise_model.dart';
import 'exercise_entry_sheet.dart';

/// Editable card for one [WorkoutDayModel] in the builder: day name, a weekday
/// chip (with an "unscheduled" option) and a reorderable list of exercise rows.
/// All edits are pushed up through [onChanged]; [dragHandle] is supplied by the
/// parent [ReorderableListView] so the whole day can be dragged.
class DayEditorCard extends StatefulWidget {
  final WorkoutDayModel day;
  final int index;
  final Widget dragHandle;
  final ValueChanged<WorkoutDayModel> onChanged;
  final VoidCallback onRemove;

  const DayEditorCard({
    super.key,
    required this.day,
    required this.index,
    required this.dragHandle,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<DayEditorCard> createState() => _DayEditorCardState();
}

class _DayEditorCardState extends State<DayEditorCard> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.day.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _emit({List<WorkoutExerciseModel>? exercises, Weekday? scheduledDay}) {
    widget.onChanged(
      WorkoutDayModel(
        id: widget.day.id,
        name: _name.text.trim(),
        order: widget.day.order,
        scheduledDay: scheduledDay,
        exercises: exercises ?? widget.day.exercises,
      ),
    );
  }

  Future<void> _addExercise() async {
    final entry = await showExerciseEntrySheet(context);
    if (entry != null) {
      _emit(
        exercises: [...widget.day.exercises, entry],
        scheduledDay: widget.day.scheduledDay,
      );
    }
  }

  Future<void> _editExercise(int index) async {
    final entry = await showExerciseEntrySheet(
      context,
      initial: widget.day.exercises[index],
    );
    if (entry != null) {
      final list = [...widget.day.exercises];
      list[index] = entry;
      _emit(exercises: list, scheduledDay: widget.day.scheduledDay);
    }
  }

  void _removeExercise(int index) {
    final list = [...widget.day.exercises]..removeAt(index);
    _emit(exercises: list, scheduledDay: widget.day.scheduledDay);
  }

  void _moveExercise(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= widget.day.exercises.length) return;
    final list = [...widget.day.exercises];
    final item = list.removeAt(index);
    list.insert(target, item);
    _emit(exercises: list, scheduledDay: widget.day.scheduledDay);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.day.exercises;
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
                  hint: 'day_name_hint'.tr(),
                  controller: _name,
                  onChanged: (v) => widget.onChanged(
                    widget.day.copyWith(name: v.trim()),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'field_required'.tr();
                    if (t.length > 64) return 'day_name_max_error'.tr();
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
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Text(
            'scheduled_day'.tr(),
            style: AppDesignSystem.labelMedium.copyWith(
              color: AppDesignSystem.neutral500,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          _WeekdaySelector(
            selected: widget.day.scheduledDay,
            onChanged: (day) => _emit(scheduledDay: day),
          ),
          SizedBox(height: AppDesignSystem.spacingMD.h),
          if (exercises.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppDesignSystem.spacingSM.h),
              child: Text(
                'no_exercises_in_day'.tr(),
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.neutral400,
                ),
              ),
            )
          else
            for (var i = 0; i < exercises.length; i++)
              _ExerciseRow(
                key: ValueKey(exercises[i].id ?? 'ex-$i'),
                exercise: exercises[i],
                isFirst: i == 0,
                isLast: i == exercises.length - 1,
                onEdit: () => _editExercise(i),
                onRemove: () => _removeExercise(i),
                onMoveUp: () => _moveExercise(i, -1),
                onMoveDown: () => _moveExercise(i, 1),
              ),
          SizedBox(height: AppDesignSystem.spacingXS.h),
          AppButton(
            text: 'add_exercise_to_day'.tr(),
            icon: Icons.add,
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            fullWidth: true,
            onPressed: _addExercise,
          ),
        ],
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final Weekday? selected;
  final ValueChanged<Weekday?> onChanged;

  const _WeekdaySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            label: 'unscheduled'.tr(),
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
          for (final d in Weekday.values)
            _chip(
              label: d.labelKey.tr(),
              isSelected: selected == d,
              onTap: () => onChanged(d),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: AppDesignSystem.spacingXS.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        labelStyle: AppDesignSystem.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppDesignSystem.neutral600,
        ),
        selectedColor: AppDesignSystem.primaryColor,
        backgroundColor: AppDesignSystem.neutral100,
        side: BorderSide.none,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final WorkoutExerciseModel exercise;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _ExerciseRow({
    super.key,
    required this.exercise,
    required this.isFirst,
    required this.isLast,
    required this.onEdit,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

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
              _MoveButton(icon: Icons.keyboard_arrow_up, enabled: !isFirst, onTap: onMoveUp),
              _MoveButton(icon: Icons.keyboard_arrow_down, enabled: !isLast, onTap: onMoveDown),
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
                    exercise.exerciseName ?? 'exercise_entry'.tr(),
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
    final chips = <Widget>[];
    final reps = exercise.reps;
    chips.add(
      AppBadge(
        text: reps != null && reps.isNotEmpty
            ? 'sets_x_reps'.tr(args: ['${exercise.sets}', reps])
            : 'sets_count'.tr(args: ['${exercise.sets}']),
        variant: AppBadgeVariant.primary,
        size: AppBadgeSize.small,
      ),
    );
    if (exercise.weightKg != null) {
      chips.add(
        AppBadge(
          text: '${_trimNum(exercise.weightKg!)} ${'unit_kg'.tr()}',
          variant: AppBadgeVariant.neutral,
          size: AppBadgeSize.small,
        ),
      );
    }
    if (exercise.restSeconds != null) {
      chips.add(
        AppBadge(
          text: 'rest_value'.tr(args: ['${exercise.restSeconds}']),
          variant: AppBadgeVariant.neutral,
          size: AppBadgeSize.small,
        ),
      );
    }
    return chips;
  }

  static String _trimNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
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
        color: enabled ? AppDesignSystem.neutral600 : AppDesignSystem.neutral300,
      ),
    );
  }
}
