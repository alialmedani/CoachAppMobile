import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/trainee_enums.dart';
import '../../data/model/trainee_profile_editable.dart';

/// Shared trainee-profile form body, editing a [TraineeProfileEditable] in place
/// (so both the create and edit screens reuse it). It mutates [params] directly;
/// text fields via `onChanged`, and the dropdowns / date / switch via local
/// `setState` mirroring (ephemeral display state — the submit is boilerplate).
class TraineeProfileForm extends StatefulWidget {
  final TraineeProfileEditable params;

  const TraineeProfileForm({super.key, required this.params});

  @override
  State<TraineeProfileForm> createState() => _TraineeProfileFormState();
}

class _TraineeProfileFormState extends State<TraineeProfileForm> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _height;
  late final TextEditingController _startWeight;
  late final TextEditingController _targetWeight;

  TraineeProfileEditable get p => widget.params;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: p.firstName);
    _lastName = TextEditingController(text: p.lastName);
    _email = TextEditingController(text: p.email ?? '');
    _phone = TextEditingController(text: p.phoneNumber ?? '');
    _height = TextEditingController(text: _num(p.heightCm));
    _startWeight = TextEditingController(text: _num(p.startWeightKg));
    _targetWeight = TextEditingController(text: _num(p.targetWeightKg));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _height.dispose();
    _startWeight.dispose();
    _targetWeight.dispose();
    super.dispose();
  }

  static String _num(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: 'personal_information'.tr(),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'first_name'.tr(),
                    hint: 'first_name_hint'.tr(),
                    controller: _firstName,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => p.firstName = v,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'field_required'.tr()
                        : null,
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'last_name'.tr(),
                    hint: 'last_name_hint'.tr(),
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => p.lastName = v,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'field_required'.tr()
                        : null,
                  ),
                ),
              ],
            ),
            AppDropdownField<int>(
              label: 'gender'.tr(),
              hint: 'select_gender'.tr(),
              value: p.gender,
              items: [
                for (final g in Gender.values)
                  DropdownMenuItem(value: g.value, child: Text(g.labelKey.tr())),
              ],
              onChanged: (v) => setState(() => p.gender = v ?? Gender.unspecified.value),
            ),
            _DateField(
              label: 'birth_date'.tr(),
              value: p.birthDate,
              onChanged: (d) => setState(() => p.birthDate = d),
            ),
          ],
        ),
        AppFormSection(
          title: 'contact_information'.tr(),
          children: [
            AppTextField(
              label: 'email'.tr(),
              hint: 'email_hint'.tr(),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (v) => p.email = v.trim().isEmpty ? null : v.trim(),
            ),
            AppTextField(
              label: 'phone'.tr(),
              hint: 'phone_hint'.tr(),
              controller: _phone,
              keyboardType: TextInputType.phone,
              onChanged: (v) => p.phoneNumber = v.trim().isEmpty ? null : v.trim(),
            ),
          ],
        ),
        AppFormSection(
          title: 'coaching_profile'.tr(),
          showDivider: false,
          children: [
            AppDropdownField<int>(
              label: 'training_goal'.tr(),
              hint: 'select_goal'.tr(),
              value: p.goal,
              items: [
                for (final g in TrainingGoal.values)
                  DropdownMenuItem(value: g.value, child: Text(g.labelKey.tr())),
              ],
              onChanged: (v) => setState(() => p.goal = v ?? TrainingGoal.general.value),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'height_cm'.tr(),
                    hint: '0',
                    controller: _height,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalFormatter],
                    onChanged: (v) => p.heightCm = double.tryParse(v),
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'start_weight_kg'.tr(),
                    hint: '0',
                    controller: _startWeight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalFormatter],
                    onChanged: (v) => p.startWeightKg = double.tryParse(v),
                  ),
                ),
                SizedBox(width: AppDesignSystem.spacingSM.w),
                Expanded(
                  child: AppTextField(
                    label: 'target_weight_kg'.tr(),
                    hint: '0',
                    controller: _targetWeight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [_decimalFormatter],
                    onChanged: (v) => p.targetWeightKg = double.tryParse(v),
                  ),
                ),
              ],
            ),
            AppCheckboxField(
              label: 'active_account'.tr(),
              subtitle: 'active_account_hint'.tr(),
              value: p.isActive,
              onChanged: (v) => setState(() => p.isActive = v ?? true),
            ),
          ],
        ),
      ],
    );
  }

  static final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'));
}

/// A read-only text-field-styled row that opens a date picker.
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? ''
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
    return AppTextField(
      label: label,
      hint: 'select_date'.tr(),
      readOnly: true,
      controller: TextEditingController(text: text),
      prefixIcon: Icon(
        Icons.calendar_today_outlined,
        size: AppDesignSystem.iconSizeSM.sp,
        color: AppDesignSystem.neutral500,
      ),
      suffixIcon: value != null
          ? IconButton(
              icon: Icon(Icons.clear, size: AppDesignSystem.iconSizeSM.sp),
              onPressed: () => onChanged(null),
            )
          : null,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(now.year - 20),
          firstDate: DateTime(1940),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
