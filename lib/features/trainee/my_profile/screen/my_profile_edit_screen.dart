import 'dart:convert';

import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:coachappmobile/features/coach/trainees/screen/widgets/trainee_submit_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_profile_cubit.dart';

/// Restricted trainee self-edit of their profile: **phone, email and birth date
/// only**. Username is shown read-only (immutable); goals/targets/height/weights
/// are coach-owned and not editable here. Current weight is not a profile field
/// — it's recorded as a progress entry from the Profile screen.
class MyProfileEditScreen extends StatefulWidget {
  final TraineeModel profile;

  const MyProfileEditScreen({super.key, required this.profile});

  @override
  State<MyProfileEditScreen> createState() => _MyProfileEditScreenState();
}

class _MyProfileEditScreenState extends State<MyProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _phone;
  DateTime? _birthDate;
  late final String _initialJson;

  MyProfileCubit get _cubit => context.read<MyProfileCubit>();

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _email = TextEditingController(text: p.email ?? '');
    _phone = TextEditingController(text: p.phoneNumber ?? '');
    _birthDate = p.birthDate;
    // Seed the cubit's edit params from the current profile.
    _cubit.editParams
      ..email = p.email
      ..phoneNumber = p.phoneNumber
      ..birthDate = p.birthDate?.toIso8601String();
    _initialJson = jsonEncode(_cubit.editParams.toJson());
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String? _validateEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null; // optional
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
    return ok ? null : 'invalid_email'.tr();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _cubit.editParams.birthDate = picked.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return UnsavedChangesGuard(
      isDirty: () => jsonEncode(_cubit.editParams.toJson()) != _initialJson,
      child: Scaffold(
        backgroundColor: AppDesignSystem.surfaceLight,
        appBar: AppTopBar(title: 'edit_profile'.tr()),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: AppDesignSystem.spacingMD.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormSection(
                        title: 'contact_information'.tr(),
                        children: [
                          AppTextField(
                            label: 'username'.tr(),
                            controller: TextEditingController(
                              text: p.userName ?? '',
                            ),
                            enabled: false,
                            readOnly: true,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: AppDesignSystem.iconSizeSM.sp,
                              color: AppDesignSystem.neutral400,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: AppDesignSystem.spacingSM.h,
                            ),
                            child: Text(
                              'username_immutable_hint'.tr(),
                              style: AppDesignSystem.bodySmall.copyWith(
                                color: AppDesignSystem.neutral500,
                              ),
                            ),
                          ),
                          AppTextField(
                            label: 'email'.tr(),
                            hint: 'email_hint'.tr(),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) => _cubit.editParams.email =
                                v.trim().isEmpty ? null : v.trim(),
                            validator: _validateEmail,
                          ),
                          AppTextField(
                            label: 'phone'.tr(),
                            hint: 'phone_hint'.tr(),
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            onChanged: (v) => _cubit.editParams.phoneNumber =
                                v.trim().isEmpty ? null : v.trim(),
                          ),
                          _BirthDateField(
                            value: _birthDate,
                            text: _fmtDate(_birthDate),
                            onTap: _pickBirthDate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TraineeSubmitBar(
              formKey: _formKey,
              label: 'save'.tr(),
              useCaseCallBack: (_) => _cubit.updateProfile(),
              successMessage: 'profile_saved'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A read-only text-field-styled row that opens a date picker for birth date.
class _BirthDateField extends StatelessWidget {
  final DateTime? value;
  final String text;
  final VoidCallback onTap;

  const _BirthDateField({
    required this.value,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'birth_date'.tr(),
      hint: 'select_date'.tr(),
      readOnly: true,
      controller: TextEditingController(text: text),
      prefixIcon: Icon(
        Icons.calendar_today_outlined,
        size: AppDesignSystem.iconSizeSM.sp,
        color: AppDesignSystem.neutral500,
      ),
      onTap: onTap,
    );
  }
}
