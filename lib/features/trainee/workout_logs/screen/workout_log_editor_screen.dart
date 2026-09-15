import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/workout_log_cubit.dart';
import '../data/model/workout_log_model.dart';
import '../data/params/workout_log_params.dart';
import 'widgets/prescribed_vs_actual_row.dart';

/// Edit the trainee's **actual** performance for a workout log. Prescribed
/// values (from the plan snapshot) are shown read-only and never re-sent; the
/// server preserves them by `(exerciseId, order)`. Saving is a full-replace PUT.
///
/// When [createFromDay] is set the [log] is an unsaved draft ([WorkoutLogModel.
/// draftFromDay]): saving first POSTs from-day to create the log and then PUTs
/// the actuals, so backing out without saving leaves no phantom log.
class WorkoutLogEditorScreen extends StatefulWidget {
  final WorkoutLogModel log;
  final WorkoutLogFromDayParams? createFromDay;

  const WorkoutLogEditorScreen({
    super.key,
    required this.log,
    this.createFromDay,
  });

  @override
  State<WorkoutLogEditorScreen> createState() => _WorkoutLogEditorScreenState();
}

class _EntryEditor {
  final WorkoutLogEntryModel src;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController weight;

  _EntryEditor(this.src)
    : sets = TextEditingController(text: src.sets.toString()),
      reps = TextEditingController(text: src.reps ?? ''),
      weight = TextEditingController(
        text: src.weightKg == null ? '' : _trim(src.weightKg!),
      );

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void dispose() {
    sets.dispose();
    reps.dispose();
    weight.dispose();
  }
}

class _WorkoutLogEditorScreenState extends State<WorkoutLogEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<_EntryEditor> _entries;
  late final TextEditingController _notes;
  late final String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _entries = widget.log.entries.map((e) => _EntryEditor(e)).toList();
    _notes = TextEditingController(text: widget.log.notes ?? '');
    _initialSnapshot = _snapshot();
  }

  /// Signature of the current draft (each entry's actuals + notes); the guard
  /// compares it against the snapshot taken after the prescribed pre-fill to
  /// know whether the trainee has changed anything.
  String _snapshot() => [
    for (final e in _entries) '${e.sets.text}|${e.reps.text}|${e.weight.text}',
    _notes.text,
  ].join('§');

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  List<WorkoutLogEntryModel> _buildEntries() => _entries
      .map(
        (e) => WorkoutLogEntryModel(
          exerciseId: e.src.exerciseId,
          order: e.src.order,
          sets: int.tryParse(e.sets.text.trim()) ?? 0,
          reps: e.reps.text.trim().isEmpty ? null : e.reps.text.trim(),
          weightKg: double.tryParse(e.weight.text.trim()),
          notes: e.src.notes,
        ),
      )
      .toList();

  String? _notesOrNull() =>
      _notes.text.trim().isEmpty ? null : _notes.text.trim();

  UpdateWorkoutLogParams _build() {
    return UpdateWorkoutLogParams(
      id: widget.log.id ?? '',
      date: (widget.log.date ?? DateTime.now()).toIso8601String(),
      notes: _notesOrNull(),
      entries: _buildEntries(),
    );
  }

  /// Saves the log. For the from-day draft this creates it (POST from-day) then
  /// persists actuals (PUT); otherwise it's a plain PUT.
  Future<Result> _submit(WorkoutLogCubit cubit) {
    final create = widget.createFromDay;
    if (create != null) {
      return cubit.logFromDayThenUpdate(
        workoutDayId: create.workoutDayId,
        date: create.date,
        entries: _buildEntries(),
        notes: _notesOrNull(),
      );
    }
    return cubit.updateLog(_build());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkoutLogCubit>();
    return UnsavedChangesGuard(
      isDirty: () => _snapshot() != _initialSnapshot,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(title: 'log_workout'.tr()),
        body: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacingMD.h,
                    AppDesignSystem.spacingMD.w,
                    AppDesignSystem.spacing4XL.h,
                  ),
                  children: [
                    for (final e in _entries) ...[
                      _EntryCard(editor: e),
                      SizedBox(height: AppDesignSystem.spacingMD.h),
                    ],
                    AppTextField(
                      label: 'notes'.tr(),
                      hint: 'workout_log_notes_hint'.tr(),
                      controller: _notes,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              onSubmit: () => _submit(cubit),
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('workout_log_saved'.tr()),
                    backgroundColor: AppDesignSystem.successColor,
                  ),
                );
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final _EntryEditor editor;

  const _EntryCard({required this.editor});

  @override
  Widget build(BuildContext context) {
    final src = editor.src;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            src.exerciseName ?? 'exercise_entry'.tr(),
            style: AppDesignSystem.bodyLarge.copyWith(
              color: AppDesignSystem.neutral900,
              fontWeight: AppDesignSystem.semiBold,
            ),
          ),
          if (src.hasPrescribed) ...[
            SizedBox(height: AppDesignSystem.spacingXS.h),
            // Prescribed target shown read-only; the actuals are the fields below.
            PrescribedVsActualRow(entry: src, showActual: false),
          ],
          SizedBox(height: AppDesignSystem.spacingSM.h),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'sets'.tr(),
                  controller: editor.sets,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              Expanded(
                child: AppTextField(
                  label: 'reps'.tr(),
                  hint: 'reps_hint'.tr(),
                  controller: editor.reps,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: AppDesignSystem.spacingSM.w),
              Expanded(
                child: AppTextField(
                  label: 'weight_kg'.tr(),
                  controller: editor.weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final Future<Result> Function() onSubmit;
  final VoidCallback onSuccess;

  const _SaveBar({required this.onSubmit, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CreateModel<WorkoutLogModel>(
          withValidation: false,
          useCaseCallBack: (_) => onSubmit(),
          onSuccess: (_) => onSuccess(),
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: AppDesignSystem.errorColor,
              ),
            );
          },
          child: Container(
            height: 52.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppDesignSystem.primaryColor,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
            ),
            child: Text(
              'save_log'.tr(),
              style: AppDesignSystem.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: AppDesignSystem.semiBold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
