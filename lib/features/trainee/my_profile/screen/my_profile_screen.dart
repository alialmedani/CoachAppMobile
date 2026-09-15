import 'package:coachappmobile/core/boilerplate/get_model/cubits/get_model_cubit.dart';
import 'package:coachappmobile/core/boilerplate/get_model/widgets/get_model.dart';
import 'package:coachappmobile/core/constant/app_design_system.dart';
import 'package:coachappmobile/core/di/injection.dart';
import 'package:coachappmobile/core/ui/widgets/modern/modern_components.dart';
import 'package:coachappmobile/features/auth/cubit/session_cubit.dart';
import 'package:coachappmobile/features/auth/screen/change_password_screen.dart';
import 'package:coachappmobile/features/coach/tracking/data/model/progress_entry_model.dart';
import 'package:coachappmobile/features/coach/trainees/data/model/trainee_model.dart';
import 'package:coachappmobile/features/trainee/my_notes/cubit/my_notes_cubit.dart';
import 'package:coachappmobile/features/trainee/my_notes/screen/my_notes_screen.dart';
import 'package:coachappmobile/features/trainee/my_progress/cubit/my_progress_cubit.dart';
import 'package:coachappmobile/features/trainee/my_progress/data/params/create_my_progress_params.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/my_profile_cubit.dart';
import 'my_profile_edit_screen.dart';

/// The trainee's "Profile" tab: their own profile with a restricted self-edit
/// (phone/email/birth date), plus entries into coach notes, change-password,
/// and logout.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  GetModelCubit? _getModel;

  static String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _num(double? v, String unit) {
    if (v == null) return '—';
    final n = v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    return '$n $unit';
  }

  Future<void> _edit(MyProfileCubit cubit, TraineeModel p) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MyProfileEditScreen(profile: p),
        ),
      ),
    );
    if (changed == true) _getModel?.getModel();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProfileCubit>();
    return Scaffold(
      backgroundColor: AppDesignSystem.surfaceLight,
      appBar: AppTopBar(title: 'tab_profile'.tr()),
      body: GetModel<TraineeModel>(
        onCubitCreated: (c) => _getModel = c,
        useCaseCallBack: () => cubit.fetchProfile(),
        modelBuilder: (p) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppDesignSystem.spacingMD.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppDesignSystem.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        p.initial,
                        style: AppDesignSystem.h4.copyWith(
                          color: AppDesignSystem.primaryDark,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDesignSystem.spacingMD.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.fullName,
                            style: AppDesignSystem.h5.copyWith(
                              color: AppDesignSystem.neutral900,
                            ),
                          ),
                          if ((p.email ?? '').isNotEmpty) ...[
                            SizedBox(height: AppDesignSystem.spacing2XS.h),
                            Text(
                              p.email!,
                              style: AppDesignSystem.bodySmall.copyWith(
                                color: AppDesignSystem.neutral500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              _Section(
                rows: [
                  _row(
                    Icons.flag_outlined,
                    'training_goal'.tr(),
                    p.goal.labelKey.tr(),
                  ),
                  _row(
                    Icons.wc_outlined,
                    'gender'.tr(),
                    p.gender.labelKey.tr(),
                  ),
                  _row(
                    Icons.cake_outlined,
                    'birth_date'.tr(),
                    _fmtDate(p.birthDate),
                  ),
                  _row(
                    Icons.height_outlined,
                    'height_cm'.tr(),
                    _num(p.heightCm, 'unit_cm'.tr()),
                  ),
                  _row(
                    Icons.monitor_weight_outlined,
                    'start_weight_kg'.tr(),
                    _num(p.startWeightKg, 'unit_kg'.tr()),
                  ),
                  _row(
                    Icons.flag_circle_outlined,
                    'target_weight_kg'.tr(),
                    _num(p.targetWeightKg, 'unit_kg'.tr()),
                  ),
                  _row(
                    Icons.phone_outlined,
                    'phone'.tr(),
                    p.phoneNumber ?? '—',
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingMD.h),
              // Derived current weight (latest progress entry) + quick record.
              const _CurrentWeightSection(),
              SizedBox(height: AppDesignSystem.spacingLG.h),
              AppButton(
                text: 'edit_profile'.tr(),
                icon: Icons.edit_outlined,
                fullWidth: true,
                onPressed: () => _edit(cubit, p),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              AppButton(
                text: 'coach_notes'.tr(),
                icon: Icons.sticky_note_2_outlined,
                variant: AppButtonVariant.outline,
                fullWidth: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => getIt<MyNotesCubit>(),
                      child: const MyNotesScreen(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              AppButton(
                text: 'change_password'.tr(),
                icon: Icons.lock_reset_outlined,
                variant: AppButtonVariant.outline,
                fullWidth: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              AppButton(
                text: 'logout'.tr(),
                icon: Icons.logout,
                variant: AppButtonVariant.danger,
                fullWidth: true,
                onPressed: () => context.read<SessionCubit>().logout(),
              ),
              SizedBox(height: AppDesignSystem.spacingXL.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) =>
      _InfoRow(icon: icon, label: label, value: value);
}

class _Section extends StatelessWidget {
  final List<Widget> rows;

  const _Section({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: AppDesignSystem.spacingLG.h,
                color: AppDesignSystem.neutral100,
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDesignSystem.iconSizeSM.sp,
          color: AppDesignSystem.neutral400,
        ),
        SizedBox(width: AppDesignSystem.spacingMD.w),
        Expanded(
          child: Text(
            label,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutral600,
            ),
          ),
        ),
        Text(
          value,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.neutral900,
            fontWeight: AppDesignSystem.medium,
          ),
        ),
      ],
    );
  }
}

/// Read-only "Current weight" stat derived from the trainee's OWN progress
/// entries (latest one with a weight), plus a quick "record today's weight"
/// action. There is no stored current-weight field — a [ProgressEntry] is the
/// single source of truth. Loaded from [MyProgressCubit]; the boilerplate
/// [GetModel] drives its state (no manual emit).
class _CurrentWeightSection extends StatefulWidget {
  const _CurrentWeightSection();

  @override
  State<_CurrentWeightSection> createState() => _CurrentWeightSectionState();
}

class _CurrentWeightSectionState extends State<_CurrentWeightSection> {
  GetModelCubit? _model;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  /// Entries are Date-desc, so the first with a non-null weight is the latest.
  static double? _latestWeight(List<ProgressEntryModel> entries) {
    for (final e in entries) {
      if (e.weightKg != null) return e.weightKg;
    }
    return null;
  }

  static bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _snack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Logs today's weight: updates the trainee's OWN entry for today if one
  /// exists (preserving its other measurements), otherwise creates a new entry
  /// for today. A coach-authored today-entry is never edited (F4 blocks it).
  Future<void> _record(List<ProgressEntryModel> entries) async {
    final cubit = context.read<MyProgressCubit>();
    final value = await showDialog<double>(
      context: context,
      builder: (_) => _RecordWeightDialog(initial: _latestWeight(entries)),
    );
    if (value == null || !mounted) return;
    final now = DateTime.now();
    final ownToday = entries
        .where((e) => !e.isCoachAuthored && _isToday(e.date))
        .toList();
    final result = ownToday.isNotEmpty
        ? await cubit.updateEntry(
            UpdateMyProgressParams(
              id: ownToday.first.id ?? '',
              date: (ownToday.first.date ?? now).toIso8601String(),
              weightKg: value,
              bodyFatPercent: ownToday.first.bodyFatPercent,
              chestCm: ownToday.first.chestCm,
              waistCm: ownToday.first.waistCm,
              hipsCm: ownToday.first.hipsCm,
              armCm: ownToday.first.armCm,
              thighCm: ownToday.first.thighCm,
              notes: ownToday.first.notes,
            ),
          )
        : await cubit.createEntry(
            CreateMyProgressParams(
              date: DateTime(now.year, now.month, now.day).toIso8601String(),
              weightKg: value,
            ),
          );
    if (!mounted) return;
    if (result.hasDataOnly) {
      _model?.getModel();
      _snack('weight_saved'.tr(), AppDesignSystem.successColor);
    } else {
      _snack(
        result.error ?? 'something_went_wrong'.tr(),
        AppDesignSystem.errorColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProgressCubit>();
    return GetModel<List<ProgressEntryModel>>(
      onCubitCreated: (c) => _model = c,
      useCaseCallBack: () => cubit.fetchRecent(),
      loadingWidget: SizedBox(
        height: 72.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      modelBuilder: (entries) {
        final w = _latestWeight(entries);
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monitor_weight_outlined,
                    size: AppDesignSystem.iconSizeSM.sp,
                    color: AppDesignSystem.primaryColor,
                  ),
                  SizedBox(width: AppDesignSystem.spacingMD.w),
                  Expanded(
                    child: Text(
                      'current_weight_kg'.tr(),
                      style: AppDesignSystem.bodyMedium.copyWith(
                        color: AppDesignSystem.neutral600,
                      ),
                    ),
                  ),
                  Text(
                    w == null
                        ? 'no_weight_logged'.tr()
                        : '${_n(w)} ${'unit_kg'.tr()}',
                    style: AppDesignSystem.bodyLarge.copyWith(
                      color: w == null
                          ? AppDesignSystem.neutral400
                          : AppDesignSystem.neutral900,
                      fontWeight: AppDesignSystem.semiBold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingSM.h),
              AppButton(
                text: 'record_current_weight'.tr(),
                icon: Icons.add,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.small,
                fullWidth: true,
                onPressed: () => _record(entries),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Minimal numeric weight input (kg) for the quick "record today's weight"
/// flow. Returns the entered value via `Navigator.pop`, or `null` if cancelled.
class _RecordWeightDialog extends StatefulWidget {
  final double? initial;

  const _RecordWeightDialog({this.initial});

  @override
  State<_RecordWeightDialog> createState() => _RecordWeightDialogState();
}

class _RecordWeightDialogState extends State<_RecordWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    _controller = TextEditingController(
      text: v == null
          ? ''
          : (v == v.roundToDouble() ? v.toInt().toString() : '$v'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, double.parse(_controller.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDesignSystem.surfaceWhite,
      title: Text('record_current_weight'.tr()),
      content: Form(
        key: _formKey,
        child: AppTextField(
          label: 'weight_kg'.tr(),
          hint: '0',
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (v) {
            final n = double.tryParse((v ?? '').trim());
            if (n == null || n <= 0 || n > 500) return 'weight_range_error'.tr();
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(onPressed: _save, child: Text('save'.tr())),
      ],
    );
  }
}
