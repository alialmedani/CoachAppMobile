import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/auth/constants/coachapp_permissions.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/progress_cubit.dart';
import '../data/model/progress_entry_model.dart';
import '../data/params/progress_entry_params.dart';

/// Create/edit a trainee's progress entry (weight, body-fat, measurements,
/// notes). Delete is offered in edit mode. Saving is a POST (create) or
/// PUT (update).
class ProgressEditorScreen extends StatefulWidget {
  /// The entry to edit; `null` for a create flow.
  final ProgressEntryModel? entry;

  const ProgressEditorScreen({super.key, this.entry});

  bool get isEdit => entry != null;

  @override
  State<ProgressEditorScreen> createState() => _ProgressEditorScreenState();
}

class _ProgressEditorScreenState extends State<ProgressEditorScreen> {
  late DateTime _date;
  late final TextEditingController _weight;
  late final TextEditingController _bodyFat;
  late final TextEditingController _chest;
  late final TextEditingController _waist;
  late final TextEditingController _hips;
  late final TextEditingController _arm;
  late final TextEditingController _thigh;
  late final TextEditingController _notes;
  late final String _initialSnapshot;

  static String _s(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? v.toInt().toString() : '$v');

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _date = e?.date ?? DateTime.now();
    _weight = TextEditingController(text: _s(e?.weightKg));
    _bodyFat = TextEditingController(text: _s(e?.bodyFatPercent));
    _chest = TextEditingController(text: _s(e?.chestCm));
    _waist = TextEditingController(text: _s(e?.waistCm));
    _hips = TextEditingController(text: _s(e?.hipsCm));
    _arm = TextEditingController(text: _s(e?.armCm));
    _thigh = TextEditingController(text: _s(e?.thighCm));
    _notes = TextEditingController(text: e?.notes ?? '');
    _initialSnapshot = _snapshot();
  }

  /// Signature of the current draft across every field; the guard compares it
  /// against the initial snapshot to detect unsaved edits.
  String _snapshot() => [
    _weight.text,
    _bodyFat.text,
    _chest.text,
    _waist.text,
    _hips.text,
    _arm.text,
    _thigh.text,
    _notes.text,
    _date.toIso8601String(),
  ].join('|');

  @override
  void dispose() {
    for (final c in [
      _weight,
      _bodyFat,
      _chest,
      _waist,
      _hips,
      _arm,
      _thigh,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());

  CreateUpdateProgressEntryParams _build(ProgressCubit cubit) {
    return CreateUpdateProgressEntryParams(
      id: widget.entry?.id ?? '',
      traineeId: cubit.traineeId,
      date: _date.toIso8601String(),
      weightKg: _num(_weight),
      bodyFatPercent: _num(_bodyFat),
      chestCm: _num(_chest),
      waistCm: _num(_waist),
      hipsCm: _num(_hips),
      armCm: _num(_arm),
      thighCm: _num(_thigh),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _delete(ProgressCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_progress'.tr()),
        content: Text('delete_progress_confirm'.tr()),
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
    if (ok != true) return;
    final result = await cubit.deleteEntry(widget.entry?.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('progress_deleted'.tr()),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgressCubit>();
    final session = context.read<SessionCubit>();
    // F8: gate affordances on the granular permissions. A coach with only the
    // default (view) permission can read the entry but not save/delete it.
    final canEdit = widget.isEdit
        ? session.can(CoachPermissions.progressUpdate)
        : session.can(CoachPermissions.progressCreate);
    final canDelete = session.can(CoachPermissions.progressDelete);
    return UnsavedChangesGuard(
      isDirty: () => _snapshot() != _initialSnapshot,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: (widget.isEdit ? 'edit_progress' : 'add_progress').tr(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacingMD.h,
                  AppDesignSystem.spacingMD.w,
                  AppDesignSystem.spacing4XL.h,
                ),
                children: [
                  _DateTile(date: _date, onTap: _pickDate, enabled: canEdit),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('weight_kg'.tr(), _weight, canEdit)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(
                        child: _numField('body_fat_percent'.tr(), _bodyFat, canEdit),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('chest_cm'.tr(), _chest, canEdit)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(child: _numField('waist_cm'.tr(), _waist, canEdit)),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('hips_cm'.tr(), _hips, canEdit)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(child: _numField('arm_cm'.tr(), _arm, canEdit)),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('thigh_cm'.tr(), _thigh, canEdit)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  AppTextField(
                    label: 'notes'.tr(),
                    hint: 'progress_notes_hint'.tr(),
                    controller: _notes,
                    maxLines: 2,
                    enabled: canEdit,
                  ),
                  if (widget.isEdit && canDelete) ...[
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    AppButton(
                      text: 'delete_progress'.tr(),
                      icon: Icons.delete_outline,
                      variant: AppButtonVariant.danger,
                      fullWidth: true,
                      onPressed: () => _delete(cubit),
                    ),
                  ],
                ],
              ),
            ),
            if (canEdit)
              _SaveBar(
                onSubmit: () => widget.isEdit
                    ? cubit.updateEntry(_build(cubit))
                    : cubit.createEntry(_build(cubit)),
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('progress_saved'.tr()),
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

  Widget _numField(String label, TextEditingController c, bool enabled) =>
      AppTextField(
        label: label,
        controller: c,
        enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      );
}

class _DateTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final bool enabled;

  const _DateTile({required this.date, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'date'.tr(),
          style: AppDesignSystem.labelMedium.copyWith(
            color: AppDesignSystem.neutral700,
            fontWeight: AppDesignSystem.medium,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingXS.h),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
          child: Container(
            padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppDesignSystem.neutral300, width: 1.5),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMD.r),
              color: AppDesignSystem.surfaceWhite,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  size: AppDesignSystem.iconSizeSM.sp,
                  color: AppDesignSystem.neutral500,
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Text(
                  '${date.year}-$m-$d',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.neutral900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        child: CreateModel<Object>(
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
              'save'.tr(),
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
