import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_progress_cubit.dart';
import '../data/params/create_my_progress_params.dart';

/// The trainee logs or edits their OWN progress measurement. Edit is offered
/// only for trainee-authored entries (passed via [entry]); [entry] `null` is a
/// create flow.
class MyProgressEditorScreen extends StatefulWidget {
  final ProgressEntryModel? entry;

  const MyProgressEditorScreen({super.key, this.entry});

  bool get isEdit => entry != null;

  @override
  State<MyProgressEditorScreen> createState() => _MyProgressEditorScreenState();
}

class _MyProgressEditorScreenState extends State<MyProgressEditorScreen> {
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
  /// against the initial (empty) snapshot to detect unsaved edits.
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

  CreateMyProgressParams _build() => CreateMyProgressParams(
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

  UpdateMyProgressParams _buildUpdate() => UpdateMyProgressParams(
    id: widget.entry?.id ?? '',
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProgressCubit>();
    final m = _date.month.toString().padLeft(2, '0');
    final d = _date.day.toString().padLeft(2, '0');
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
                  Text(
                    'date'.tr(),
                    style: AppDesignSystem.labelMedium.copyWith(
                      color: AppDesignSystem.neutral700,
                      fontWeight: AppDesignSystem.medium,
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacingXS.h),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(
                      AppDesignSystem.radiusMD.r,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppDesignSystem.neutral300,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDesignSystem.radiusMD.r,
                        ),
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
                            '${_date.year}-$m-$d',
                            style: AppDesignSystem.bodyMedium.copyWith(
                              color: AppDesignSystem.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('weight_kg'.tr(), _weight)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(
                        child: _numField('body_fat_percent'.tr(), _bodyFat),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('chest_cm'.tr(), _chest)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(child: _numField('waist_cm'.tr(), _waist)),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('hips_cm'.tr(), _hips)),
                      SizedBox(width: AppDesignSystem.spacingSM.w),
                      Expanded(child: _numField('arm_cm'.tr(), _arm)),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  Row(
                    children: [
                      Expanded(child: _numField('thigh_cm'.tr(), _thigh)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: AppDesignSystem.spacingMD.h),
                  AppTextField(
                    label: 'notes'.tr(),
                    hint: 'progress_notes_hint'.tr(),
                    controller: _notes,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            _SaveBar(
              onSubmit: () => widget.isEdit
                  ? cubit.updateEntry(_buildUpdate())
                  : cubit.createEntry(_build()),
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

  Widget _numField(String label, TextEditingController c) => AppTextField(
    label: label,
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
  );
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
