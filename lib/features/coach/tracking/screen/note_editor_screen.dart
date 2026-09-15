import 'package:coachappmobile/core/boilerplate/create_model/widgets/create_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/results/result.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/notes_cubit.dart';
import '../data/model/trainee_note_model.dart';
import '../data/params/trainee_note_params.dart';

/// Create/edit a trainee note (date + text, max 2000). Delete in edit mode.
class NoteEditorScreen extends StatefulWidget {
  final TraineeNoteModel? note;

  const NoteEditorScreen({super.key, this.note});

  bool get isEdit => note != null;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late DateTime _date;
  late final TextEditingController _text;
  late final String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _date = widget.note?.date ?? DateTime.now();
    _text = TextEditingController(text: widget.note?.text ?? '');
    _initialSnapshot = _snapshot();
  }

  /// Signature of the current draft; the guard compares it against the initial
  /// snapshot to detect unsaved edits (text or date).
  String _snapshot() => '${_text.text}|${_date.toIso8601String()}';

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
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

  String? _validate() {
    if (_text.text.trim().isEmpty) return 'field_required'.tr();
    if (_text.text.trim().length > 2000) return 'note_text_max_error'.tr();
    return null;
  }

  CreateUpdateTraineeNoteParams _build(NotesCubit cubit) =>
      CreateUpdateTraineeNoteParams(
        id: widget.note?.id ?? '',
        traineeId: cubit.traineeId,
        date: _date.toIso8601String(),
        text: _text.text.trim(),
      );

  Future<void> _delete(NotesCubit cubit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_note'.tr()),
        content: Text('delete_note_confirm'.tr()),
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
    final result = await cubit.deleteNote(widget.note?.id ?? '');
    if (!mounted) return;
    if (result.hasDataOnly) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('note_deleted'.tr()),
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
    final cubit = context.read<NotesCubit>();
    final m = _date.month.toString().padLeft(2, '0');
    final d = _date.day.toString().padLeft(2, '0');
    return UnsavedChangesGuard(
      isDirty: () => _snapshot() != _initialSnapshot,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(
          title: (widget.isEdit ? 'edit_note' : 'add_note').tr(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
                children: [
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
                  AppTextField(
                    label: 'note_text'.tr(),
                    hint: 'note_text_hint'.tr(),
                    controller: _text,
                    maxLines: 8,
                    minLines: 4,
                  ),
                  if (widget.isEdit) ...[
                    SizedBox(height: AppDesignSystem.spacingLG.h),
                    AppButton(
                      text: 'delete_note'.tr(),
                      icon: Icons.delete_outline,
                      variant: AppButtonVariant.danger,
                      fullWidth: true,
                      onPressed: () => _delete(cubit),
                    ),
                  ],
                ],
              ),
            ),
            _SaveBar(
              onValidate: _validate,
              onSubmit: () => widget.isEdit
                  ? cubit.updateNote(_build(cubit))
                  : cubit.createNote(_build(cubit)),
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('note_saved'.tr()),
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

class _SaveBar extends StatelessWidget {
  final String? Function() onValidate;
  final Future<Result> Function() onSubmit;
  final VoidCallback onSuccess;

  const _SaveBar({
    required this.onValidate,
    required this.onSubmit,
    required this.onSuccess,
  });

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
          withValidation: true,
          onTap: () async {
            final error = onValidate();
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: AppDesignSystem.errorColor,
                ),
              );
              return false;
            }
            return true;
          },
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
